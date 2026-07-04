import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: CircleBackButton(),
                    ),
                    const SizedBox(height: 8),
                    const BrandLogo(size: 52),
                    const SizedBox(height: 14),
                    const Text(
                      'Medical History',
                      style: TextStyle(
                        color: AppColors.heading,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Does the child have a known medical or developmental history?',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.heading, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    _OptionCard(
                      title: 'Yes',
                      description:
                          'The child has a diagnosed medical condition or developmental concern',
                      selected: true,
                    ),
                    const SizedBox(height: 16),
                    _OptionCard(
                      title: 'No',
                      description:
                          'No known medical or developmental concerns at this time',
                      selected: false,
                    ),
                    const SizedBox(height: 16),
                    _OptionCard(
                      title: 'Not sure',
                      description:
                          'Unsure about medical history or have questions about development',
                      selected: false,
                    ),
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
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: SafeArea(
              top: false,
              child: const PrimaryButton(label: 'Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String description;
  final bool selected;

  const _OptionCard({
    required this.title,
    required this.description,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: selected ? AppColors.selectedFill : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppColors.selectedBorder : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.textMuted, width: 2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.heading,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    height: 1.4,
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
