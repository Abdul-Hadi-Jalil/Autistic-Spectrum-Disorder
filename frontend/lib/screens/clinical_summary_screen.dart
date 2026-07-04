import 'package:flutter/material.dart';
import '../data/developmental_scale.dart';
import '../services/prediction_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

class ClinicalSummaryScreen extends StatelessWidget {
  final String childName;
  final int? age;
  final String? gender;
  final ScreeningResult result;
  final ShapExplanation explanation;
  final List<int> answers;

  const ClinicalSummaryScreen({
    super.key,
    required this.childName,
    required this.result,
    required this.explanation,
    required this.answers,
    this.age,
    this.gender,
  });

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String _riskLabel(String level) {
    switch (level) {
      case 'low':
        return 'Low Risk';
      case 'high':
        return 'High Risk';
      default:
        return 'Moderate Risk';
    }
  }

  static Color _riskColor(String level) {
    switch (level) {
      case 'low':
        return AppColors.lowRisk;
      case 'high':
        return AppColors.highRisk;
      default:
        return AppColors.moderateRisk;
    }
  }

  Map<String, List<String>> _sectionObservations() {
    final grouped = <String, List<String>>{};
    for (int i = 0; i < developmentalQuestions.length; i++) {
      final q = developmentalQuestions[i];
      final score = answers[i];
      final label = developmentalScaleOptions[score];
      grouped.putIfAbsent(q.section, () => []);
      grouped[q.section]!.add('${q.text}: $label ($score/4)');
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final observations = _sectionObservations();
    final maxImpact = explanation.topFeatures.isEmpty
        ? 1.0
        : explanation.topFeatures.first.impact;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Clinical Summary',
                        style: TextStyle(
                          color: AppColors.heading,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Center(
                      child: Text(
                        'Model prediction with SHAP explainability',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ChildInfoCard(
                      childName: childName,
                      age: age,
                      gender: gender,
                      date: _formatDate(DateTime.now()),
                      riskLabel: _riskLabel(result.riskLevel),
                      riskColor: _riskColor(result.riskLevel),
                      scoreRiskLevel: result.riskLevel,
                      totalScore: result.totalScore,
                      concernPercent: result.concernPercent,
                      modelPrediction: result.modelPrediction,
                      confidence: result.confidence,
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'SHAP Feature Importance',
                      style: TextStyle(
                        color: AppColors.heading,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Top factors driving the model prediction for this screening.',
                      style: TextStyle(color: AppColors.textMuted, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          for (final f in explanation.topFeatures) ...[
                            _ShapBar(
                              label: f.questionIndex < developmentalQuestions.length
                                  ? developmentalQuestions[f.questionIndex].text
                                  : f.feature,
                              impact: f.impact,
                              shapValue: f.shapValue,
                              maxImpact: maxImpact,
                              answerLabel: developmentalScaleOptions[f.answer],
                            ),
                            if (f != explanation.topFeatures.last)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Behavioral Observations',
                      style: TextStyle(
                        color: AppColors.heading,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final entry in observations.entries) ...[
                      _ObservationCard(
                        title: entry.key,
                        items: entry.value,
                      ),
                      const SizedBox(height: 14),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlineButton(
                          label: 'Return to Dashboard',
                          onTap: () => Navigator.of(context).popUntil(
                            (route) => route.isFirst,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildInfoCard extends StatelessWidget {
  final String childName;
  final int? age;
  final String? gender;
  final String date;
  final String riskLabel;
  final Color riskColor;
  final String scoreRiskLevel;
  final int totalScore;
  final int concernPercent;
  final String? modelPrediction;
  final double? confidence;

  const _ChildInfoCard({
    required this.childName,
    required this.date,
    required this.riskLabel,
    required this.riskColor,
    required this.scoreRiskLevel,
    required this.totalScore,
    required this.concernPercent,
    this.age,
    this.gender,
    this.modelPrediction,
    this.confidence,
  });

  static String _modelRiskLabel(String? level) {
    switch (level) {
      case 'low':
        return 'Low';
      case 'high':
        return 'High';
      default:
        return 'Moderate';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _InfoCell(label: 'CHILD NAME', value: childName),
              ),
              Expanded(
                child: _InfoCell(
                  label: 'AGE',
                  value: age != null ? '$age years' : 'N/A',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _InfoCell(
                  label: 'GENDER',
                  value: gender ?? 'N/A',
                ),
              ),
              Expanded(
                child: _InfoCell(label: 'SCREENING DATE', value: date),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _InfoCell(
                  label: 'TOTAL SCORE',
                  value: '$totalScore / 120',
                ),
              ),
              Expanded(
                child: _InfoCell(
                  label: 'CONCERN LEVEL',
                  value: '$concernPercent%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$riskLabel (score-based)',
                  style: TextStyle(
                    color: riskColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (modelPrediction != null &&
                    modelPrediction != scoreRiskLevel) ...[
                  const SizedBox(height: 6),
                  Text(
                    'ML model predicted: ${_modelRiskLabel(modelPrediction)}'
                    '${confidence != null ? ' (${(confidence! * 100).round()}% confidence)' : ''}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ShapBar extends StatelessWidget {
  final String label;
  final double impact;
  final double shapValue;
  final double maxImpact;
  final String answerLabel;

  const _ShapBar({
    required this.label,
    required this.impact,
    required this.shapValue,
    required this.maxImpact,
    required this.answerLabel,
  });

  @override
  Widget build(BuildContext context) {
    final widthFactor = maxImpact > 0 ? (impact / maxImpact).clamp(0.05, 1.0) : 0.05;
    final barColor = shapValue >= 0 ? AppColors.highRisk : AppColors.lowRisk;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 13,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Response: $answerLabel',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 8,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 8,
                  width: constraints.maxWidth * widthFactor,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ObservationCard extends StatelessWidget {
  final String title;
  final List<String> items;
  const _ObservationCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6, right: 10),
                    child: CircleAvatar(
                      radius: 3.5,
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        height: 1.4,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
