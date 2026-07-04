import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data/developmental_scale.dart';
import '../services/child_service.dart';
import '../services/prediction_service.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';
import 'clinical_summary_screen.dart';
import 'high_risk_screen.dart';
import 'low_risk_screen.dart';
import 'moderate_risk_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final List<int> answers;
  final String? childId;
  final String? childName;
  final int? age;
  final String? gender;

  const ProcessingScreen({
    super.key,
    required this.answers,
    this.childId,
    this.childName,
    this.age,
    this.gender,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _runPrediction();
  }

  Future<void> _runPrediction() async {
    setState(() => _error = null);
    try {
      final profile = await UserService.instance.getProfile();
      final isClinical = profile?.isClinical ?? false;

      final prediction = await Future.wait([
        PredictionService.instance.predict(
          answers: widget.answers,
          age: widget.age,
          gender: widget.gender,
          includeShap: isClinical,
        ),
        Future<void>.delayed(const Duration(milliseconds: 1500)),
      ]);

      final screening = prediction.first as ScreeningPrediction;
      final result = screening.result;
      final explanation = screening.explanation;

      if (!mounted) return;

      if (isClinical && explanation == null) {
        throw Exception(
          screening.shapError ??
              'SHAP explanation unavailable. Redeploy the backend with the latest code.',
        );
      }

      final Widget resultScreen = isClinical
          ? ClinicalSummaryScreen(
              childName: widget.childName ?? 'Child',
              age: widget.age,
              gender: widget.gender,
              answers: widget.answers,
              result: result,
              explanation: explanation!,
            )
          : switch (result.riskLevel) {
              'low' => LowRiskScreen(concernPercent: result.concernPercent),
              'high' => HighRiskScreen(concernPercent: result.concernPercent),
              _ => ModerateRiskScreen(concernPercent: result.concernPercent),
            };

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => resultScreen),
      );

      final childId = widget.childId;
      final childName = widget.childName;
      if (childId != null && childName != null) {
        unawaited(
          ChildService.instance.recordScreening(
            childId: childId,
            childName: childName,
            riskLevel: result.riskLevel,
            summary: summaryForRiskLevel(result.riskLevel),
            screeningType: 'Developmental Screening',
          ),
        );
      }
    } catch (e, st) {
      debugPrint('Screening prediction failed: $e\n$st');
      if (!mounted) return;
      setState(() => _error =
          'We could not reach the screening service.\n'
          'Please check your connection and try again.\n\n'
          'Details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8FA9CC), Color(0xFFE5EBF2)],
          ),
        ),
        child: SafeArea(
          child: _error == null ? _buildProcessing() : _buildError(),
        ),
      ),
    );
  }

  Widget _buildProcessing() {
    return Column(
      children: [
        const Spacer(flex: 3),
        Stack(
          alignment: Alignment.center,
          children: [
            _ring(110, 0.18),
            _ring(86, 0.28),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.explore,
                color: AppColors.primary,
                size: 34,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        _Dots(),
        const SizedBox(height: 26),
        const Text(
          'Processing Your Screening',
          style: TextStyle(
            color: AppColors.heading,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Please wait while we analyze the responses',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ),
        const Spacer(flex: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.lock_outline, size: 14, color: AppColors.lowRisk),
            SizedBox(width: 6),
            Text(
              'Your data is securely encrypted and confidential.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.primary),
          const SizedBox(height: 20),
          const Text(
            'Something went wrong',
            style: TextStyle(
              color: AppColors.heading,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _error ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _runPrediction,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Try Again'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _ring(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: i == 0
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
