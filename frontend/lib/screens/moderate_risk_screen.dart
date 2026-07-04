import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'result_widgets.dart';

class ModerateRiskScreen extends StatelessWidget {
  final int concernPercent;
  const ModerateRiskScreen({super.key, this.concernPercent = 54});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.moderateGradient,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const RiskPill(label: 'Moderate Risk', withIcon: true),
                const SizedBox(height: 18),
                PercentDisplay(percent: '$concernPercent'),
                const SizedBox(height: 4),
                const Text(
                  'Screening Concern Level',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 28),
                const RiskCard(
                  pillLabel: 'MODERATE RISK',
                  pillColor: AppColors.moderateRisk,
                  message:
                      "Your child's responses suggest some behavioral patterns that may be associated with Autism Spectrum Disorder.",
                  noteIcon: Icons.info_outline,
                  note:
                      'This is a screening indicator only. Consult a qualified professional for diagnosis.',
                ),
                const SizedBox(height: 18),
                ResultListCard(
                  sectionTitle: 'RECOMMENDED NEXT STEPS',
                  accent: AppColors.moderateRisk,
                  items: const [
                    ResultItem(
                      icon: Icons.people_alt_outlined,
                      title: 'Schedule a Follow-up Consultation',
                      body:
                          'Book an appointment with a qualified psychologist or pediatric specialist for a comprehensive evaluation.',
                    ),
                    ResultItem(
                      icon: Icons.assignment_outlined,
                      title: 'Early Observation & Support',
                      body:
                          "Early professional evaluation can help provide tailored support strategies for your child's development.",
                    ),
                  ],
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
