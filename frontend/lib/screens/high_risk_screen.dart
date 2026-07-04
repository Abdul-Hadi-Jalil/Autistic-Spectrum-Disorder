import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'result_widgets.dart';

class HighRiskScreen extends StatelessWidget {
  final int concernPercent;
  const HighRiskScreen({super.key, this.concernPercent = 78});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.highGradient,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const RiskPill(label: 'High Risk', withIcon: true),
                const SizedBox(height: 18),
                PercentDisplay(percent: '$concernPercent'),
                const SizedBox(height: 4),
                const Text(
                  'Screening Concern Level',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 28),
                const RiskCard(
                  pillLabel: 'HIGH RISK',
                  pillColor: AppColors.highRisk,
                  message:
                      "Your child's responses suggest several behavioral patterns associated with Autism Spectrum Disorder.",
                  noteIcon: Icons.info_outline,
                  note:
                      'This screening is not a medical diagnosis, but it indicates that prompt professional evaluation is strongly recommended.',
                ),
                const SizedBox(height: 18),
                ResultListCard(
                  sectionTitle: 'RECOMMENDED NEXT STEPS',
                  accent: AppColors.highRisk,
                  items: const [
                    ResultItem(
                      icon: Icons.event_available_outlined,
                      title: 'Schedule a Comprehensive Assessment',
                      body:
                          'Book an appointment with a qualified psychologist or pediatric specialist as soon as possible.',
                    ),
                    ResultItem(
                      icon: Icons.description_outlined,
                      title: 'Document & Share Observations',
                      body:
                          "Share your child's responses and observations with the specialist to support the evaluation.",
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
