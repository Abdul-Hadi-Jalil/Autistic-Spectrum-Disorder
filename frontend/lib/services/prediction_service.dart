import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/developmental_scale.dart';

/// Result returned by the screening prediction backend.
class ScreeningResult {
  final String riskLevel;
  final int concernPercent;
  final int totalScore;
  final String summary;
  final double? confidence;
  final String? modelPrediction;

  const ScreeningResult({
    required this.riskLevel,
    required this.concernPercent,
    required this.totalScore,
    required this.summary,
    this.confidence,
    this.modelPrediction,
  });

  factory ScreeningResult.fromJson(Map<String, dynamic> json) {
    final totalScore = (json['total_score'] as num?)?.toInt() ?? 0;
    // Risk is always derived from the score bands (0–30 / 31–70 / 71+),
    // not from the ML model's class label.
    final riskLevel = riskLevelFromScore(totalScore);
    return ScreeningResult(
      riskLevel: riskLevel,
      concernPercent: concernPercentFromScore(totalScore),
      totalScore: totalScore,
      summary: summaryForRiskLevel(riskLevel),
      confidence: (json['confidence'] as num?)?.toDouble(),
      modelPrediction: json['model_prediction'] as String?,
    );
  }
}

/// Parses screening result + optional SHAP block from `/predict`.
class ScreeningPrediction {
  final ScreeningResult result;
  final ShapExplanation? explanation;
  final String? shapError;

  const ScreeningPrediction({
    required this.result,
    this.explanation,
    this.shapError,
  });

  factory ScreeningPrediction.fromJson(Map<String, dynamic> json) {
    final shapJson = json['shap'] as Map<String, dynamic>?;
    return ScreeningPrediction(
      result: ScreeningResult.fromJson(json),
      explanation: shapJson != null ? ShapExplanation.fromJson(shapJson) : null,
      shapError: json['shap_error'] as String?,
    );
  }
}

/// One SHAP feature contribution for clinical explainability.
class ShapFeature {
  final String feature;
  final int questionIndex;
  final int answer;
  final double shapValue;
  final double impact;

  const ShapFeature({
    required this.feature,
    required this.questionIndex,
    required this.answer,
    required this.shapValue,
    required this.impact,
  });

  factory ShapFeature.fromJson(Map<String, dynamic> json) {
    return ShapFeature(
      feature: (json['feature'] as String?) ?? '',
      questionIndex: (json['question_index'] as num?)?.toInt() ?? 0,
      answer: (json['answer'] as num?)?.toInt() ?? 0,
      shapValue: (json['shap_value'] as num?)?.toDouble() ?? 0,
      impact: (json['impact'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// SHAP explanation from the backend `/explain` endpoint.
class ShapExplanation {
  final String predictedClass;
  final List<ShapFeature> topFeatures;

  const ShapExplanation({
    required this.predictedClass,
    required this.topFeatures,
  });

  factory ShapExplanation.fromJson(Map<String, dynamic> json) {
    final list = (json['top_features'] as List<dynamic>?) ?? [];
    return ShapExplanation(
      predictedClass: (json['predicted_class'] as String?) ?? 'moderate',
      topFeatures: list
          .map((e) => ShapFeature.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Talks to the FastAPI backend that serves the Random Forest model.
class PredictionService {
  PredictionService._();
  static final PredictionService instance = PredictionService._();

  static String get baseUrl {
    return 'https://autistic-spectrum-disorder-app.onrender.com';

    // Local testing — uncomment block below and comment Render line above:
    // if (kIsWeb) return 'http://127.0.0.1:8000';
    // if (Platform.isAndroid) return 'http://192.168.18.251:8000';
    // return 'http://127.0.0.1:8000';
  }

  Map<String, dynamic> _body({
    required List<int> answers,
    int? age,
    String? gender,
    String? relationship,
    bool includeShap = false,
  }) => {
    'answers': answers,
    if (age != null) 'age': age,
    if (gender != null && gender.isNotEmpty) 'gender': gender,
    if (relationship != null && relationship.isNotEmpty)
      'relationship': relationship,
    if (includeShap) 'include_shap': true,
  };

  Future<ScreeningPrediction> predict({
    required List<int> answers,
    int? age,
    String? gender,
    String? relationship,
    bool includeShap = false,
  }) async {
    final uri = Uri.parse('$baseUrl/predict');
    debugPrint('POST $uri (includeShap=$includeShap)');

    try {
      final response = await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(
              _body(
                answers: answers,
                age: age,
                gender: gender,
                relationship: relationship,
                includeShap: includeShap,
              ),
            ),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      return ScreeningPrediction.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } on SocketException catch (e) {
      throw Exception('Cannot connect to $baseUrl ($e)');
    } on http.ClientException catch (e) {
      throw Exception('Network error calling $baseUrl ($e)');
    }
  }

  /// Legacy separate endpoint — prefer [predict] with `includeShap: true`.
  @Deprecated('Use predict(includeShap: true)')
  Future<ShapExplanation> explain({
    required List<int> answers,
    int? age,
    String? gender,
    String? relationship,
  }) async {
    final uri = Uri.parse('$baseUrl/explain');
    debugPrint('POST $uri');

    try {
      final response = await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(
              _body(
                answers: answers,
                age: age,
                gender: gender,
                relationship: relationship,
              ),
            ),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      return ShapExplanation.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } on SocketException catch (e) {
      throw Exception('Cannot connect to $baseUrl ($e)');
    } on http.ClientException catch (e) {
      throw Exception('Network error calling $baseUrl ($e)');
    }
  }
}
