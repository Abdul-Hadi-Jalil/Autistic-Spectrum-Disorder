import 'package:flutter/material.dart';
import '../services/child_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'developmental_question_screen.dart';

class ChildProfileScreen extends StatefulWidget {
  const ChildProfileScreen({super.key});

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  static const _ages = [
    '3 yrs', '4 yrs', '5 yrs', '6 yrs',
    '7 yrs', '8 yrs', '9 yrs', '10 yrs',
    '11 yrs', '12 yrs', '13 yrs',
  ];

  final _nameController = TextEditingController();
  String? _selectedAge;
  String? _selectedGender;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  int? _parseAge(String? label) {
    if (label == null) return null;
    return int.tryParse(label.split(' ').first);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _startScreening() async {
    final name = _nameController.text.trim();
    final age = _parseAge(_selectedAge);

    if (name.isEmpty) {
      _showMessage("Please enter your child's name.");
      return;
    }
    if (age == null) {
      _showMessage("Please select your child's age.");
      return;
    }

    setState(() => _loading = true);
    try {
      final childId = await ChildService.instance.addChild(
        name: name,
        ageYears: age,
        gender: _selectedGender,
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DevelopmentalQuestionScreen(
            childId: childId,
            childName: name,
            age: age,
            gender: _selectedGender,
          ),
        ),
      );
    } catch (e) {
      _showMessage('Could not save child profile. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const CircleBackButton(),
                    const SizedBox(height: 8),
                    const Center(child: BrandLogo(size: 56)),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Child Profile',
                        style: TextStyle(
                          color: AppColors.heading,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'This helps calibrate age-appropriate milestones',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 26),
                    const SectionLabel("Child's Name"),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(color: AppColors.heading),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter child's name",
                          hintStyle: TextStyle(color: AppColors.textFaint),
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const SectionLabel("Child's Age"),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final age in _ages)
                          GestureDetector(
                            onTap: () => setState(() => _selectedAge = age),
                            child: _AgeChip(
                              label: age,
                              selected: _selectedAge == age,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Gender ',
                            style: TextStyle(
                              color: AppColors.heading,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          TextSpan(
                            text: '(Optional)',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _GenderOption(
                      label: 'Male',
                      selected: _selectedGender == 'Male',
                      onTap: () => setState(() => _selectedGender = 'Male'),
                    ),
                    const SizedBox(height: 12),
                    _GenderOption(
                      label: 'Female',
                      selected: _selectedGender == 'Female',
                      onTap: () => setState(() => _selectedGender = 'Female'),
                    ),
                    const SizedBox(height: 12),
                    _GenderOption(
                      label: 'Prefer not to say',
                      selected: _selectedGender == 'Prefer not to say',
                      onTap: () =>
                          setState(() => _selectedGender = 'Prefer not to say'),
                    ),
                    const SizedBox(height: 24),
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
              child: PrimaryButton(
                label: 'Start Screening',
                loading: _loading,
                onTap: _startScreening,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _AgeChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 48 - 36) / 4;
    return Container(
      width: width,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.selectedFill : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.selectedBorder : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.heading,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _GenderOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.selectedFill : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.selectedBorder : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.heading,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
