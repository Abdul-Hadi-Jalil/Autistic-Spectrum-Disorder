import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/header_actions.dart';
import 'child_profile_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              BrandHeader(
                actions: const [SettingsIconButton()],
              ),
              const SizedBox(height: 30),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9D4EC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.child_care,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Welcome to ASD CARE!',
                  style: TextStyle(
                    color: AppColors.heading,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Let's set up your first child's profile to get started.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, height: 1.4),
                ),
              ),
              const SizedBox(height: 36),
              PrimaryButton(
                label: 'Add Your Child',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ChildProfileScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'You can add more children later from the Dashboard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
              const SizedBox(height: 30),
              const SectionLabel('Tips for Parents'),
              const SizedBox(height: 12),
              _Tip(
                title: 'Screen between 18 \u2013 24 months',
                body:
                    'Early screening leads to better long-term outcomes for your child.',
              ),
              const Divider(color: AppColors.border),
              _Tip(
                title: 'Trust what you observe',
                body:
                    'Parents notice changes first. A screening takes less than 10 minutes.',
              ),
              const Divider(color: AppColors.border),
              _Tip(
                title: '1 in 36 children has ASD',
                body:
                    "You're not alone \u2014 ASD CARE is here to support you every step.",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final String title;
  final String body;
  const _Tip({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 12),
            child: CircleAvatar(radius: 4, backgroundColor: AppColors.primary),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.heading,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
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
