import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'consent_screen.dart';

class ModeSelectionScreen extends StatefulWidget {
  final SignupData signupData;
  const ModeSelectionScreen({super.key, required this.signupData});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  String _selected = 'parent';

  void _continue() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConsentScreen(
          signupData: widget.signupData.copyWith(mode: _selected),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const Center(child: BrandLogo(size: 56)),
                    const SizedBox(height: 20),
                    const Text(
                      'Select Your Mode',
                      style: TextStyle(
                        color: AppColors.heading,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose how you would like to access ASD CARE.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: () => setState(() => _selected = 'parent'),
                      child: _ModeCard(
                        icon: Icons.people_alt_rounded,
                        title: 'Parent',
                        description:
                            'Access developmental screening for your child with personalized guidance and support.',
                        selected: _selected == 'parent',
                      ),
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: () => setState(() => _selected = 'clinical'),
                      child: _ModeCard(
                        icon: Icons.medical_information_rounded,
                        title: 'Clinical Professional',
                        description:
                            'Use clinical tools to monitor and track developmental screenings for your patients.',
                        selected: _selected == 'clinical',
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: PrimaryButton(label: 'Continue', onTap: _continue),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool selected;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: selected ? AppColors.selectedFill : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AppColors.selectedBorder : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFC2D3EC) : AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.heading, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.heading,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, height: 1.4),
          ),
        ],
      ),
    );
  }
}
