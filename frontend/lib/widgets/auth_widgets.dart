import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Labeled text field used on the login / signup screens.
class AuthField extends StatefulWidget {
  final String label;
  final String hint;
  final bool obscure;
  final bool showEye;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.showEye = false,
    this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  late bool _obscured = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  obscureText: _obscured,
                  keyboardType: widget.keyboardType,
                  style: const TextStyle(color: AppColors.heading),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: const TextStyle(color: AppColors.textFaint),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (widget.showEye)
                GestureDetector(
                  onTap: () => setState(() => _obscured = !_obscured),
                  child: Icon(
                    _obscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textFaint,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "OR" divider with horizontal lines.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('OR', style: TextStyle(color: AppColors.textMuted)),
        ),
        Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

/// Google / Apple social sign-in button.
class SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  const SocialButton({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.heading, size: 22),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.heading,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
