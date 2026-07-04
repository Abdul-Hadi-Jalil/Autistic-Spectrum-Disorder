import 'package:flutter/material.dart';
import '../data/developmental_scale.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'processing_screen.dart';

class DevelopmentalQuestionScreen extends StatefulWidget {
  final String? childId;
  final String? childName;
  final int? age;
  final String? gender;

  const DevelopmentalQuestionScreen({
    super.key,
    this.childId,
    this.childName,
    this.age,
    this.gender,
  });

  @override
  State<DevelopmentalQuestionScreen> createState() =>
      _DevelopmentalQuestionScreenState();
}

class _DevelopmentalQuestionScreenState
    extends State<DevelopmentalQuestionScreen> {
  int _currentIndex = 0;
  final List<int?> _answers = List.filled(developmentalQuestions.length, null);

  DevelopmentalQuestion get _question => developmentalQuestions[_currentIndex];

  // ignore: unused_element
  bool get _isFirst => _currentIndex == 0;
  bool get _isLast => _currentIndex == developmentalQuestions.length - 1;

  bool get _showSectionHeader {
    if (_currentIndex == 0) return true;
    return developmentalQuestions[_currentIndex - 1].section !=
        _question.section;
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _selectAnswer(int index) {
    setState(() => _answers[_currentIndex] = index);
  }

  void _goBack() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    } else {
      Navigator.maybePop(context);
    }
  }

  void _goNext() {
    if (_answers[_currentIndex] == null) {
      _showMessage('Please select an answer before continuing.');
      return;
    }

    if (_isLast) {
      final answers = _answers.map((a) => a ?? 0).toList();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProcessingScreen(
            answers: answers,
            childId: widget.childId,
            childName: widget.childName,
            age: widget.age,
            gender: widget.gender,
          ),
        ),
      );
      return;
    }

    setState(() => _currentIndex++);
  }

  @override
  Widget build(BuildContext context) {
    final total = developmentalQuestions.length;
    final progress = (_currentIndex + 1) / total;
    final selected = _answers[_currentIndex];

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
                    GestureDetector(
                      onTap: _goBack,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: AppColors.heading,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Question ${_currentIndex + 1} of $total',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    if (_showSectionHeader) ...[
                      const SizedBox(height: 18),
                      SectionLabel(_question.section.toUpperCase()),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      _question.text,
                      style: const TextStyle(
                        color: AppColors.heading,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    for (
                      int i = 0;
                      i < developmentalScaleOptions.length;
                      i++
                    ) ...[
                      _RadioOption(
                        label: developmentalScaleOptions[i],
                        selected: selected == i,
                        onTap: () => _selectAnswer(i),
                      ),
                      if (i != developmentalScaleOptions.length - 1)
                        const SizedBox(height: 14),
                    ],
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
                label: _isLast ? 'Submit' : 'Next',
                onTap: _goNext,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioOption({
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
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? AppColors.selectedFill : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.selectedBorder : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                color: selected ? AppColors.primary : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.circle, size: 10, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: AppColors.heading,
                fontSize: 15,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
