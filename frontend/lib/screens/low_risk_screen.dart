import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'result_widgets.dart';

class LowRiskScreen extends StatelessWidget {
  final int concernPercent;
  const LowRiskScreen({super.key, this.concernPercent = 18});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.lowGradient,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const RiskPill(label: 'Low Risk'),
                const SizedBox(height: 18),
                PercentDisplay(percent: '$concernPercent'),
                const SizedBox(height: 4),
                const Text(
                  'Screening Concern Level',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 28),
                const RiskCard(
                  pillLabel: 'LOW RISK',
                  pillColor: AppColors.lowRisk,
                  message:
                      'Your child is displaying typical developmental patterns for their age group.',
                  noteIcon: Icons.warning_amber_rounded,
                  note:
                      'This is a screening indicator only. Consult a qualified professional for diagnosis.',
                ),
                const SizedBox(height: 18),
                ResultListCard(
                  sectionTitle: 'SUPPORT ACTIVITIES',
                  accent: AppColors.lowRisk,
                  bulletStyle: true,
                  items: const [
                    ResultItem(
                      title:
                          'Continue encouraging language rich play and storytelling.',
                    ),
                    ResultItem(
                      title:
                          'Engage in simple group games or cooperative tasks to build social skills.',
                    ),
                    ResultItem(
                      title:
                          'Practice fine motor activities like drawing or puzzles together.',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const OutlineButton(label: 'Return to Dashboard'),
                const SizedBox(height: 12),
                const PrimaryButton(
                  label: 'View Detailed Report',
                  color: Color(0xFFE0B400),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
