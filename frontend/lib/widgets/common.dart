import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The navy rounded-square heart logo used throughout the app.
class BrandLogo extends StatelessWidget {
  final double size;
  const BrandLogo({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(Icons.favorite, color: Colors.white, size: size * 0.5),
    );
  }
}

/// "ASD CARE" header with the logo and (optional) trailing actions.
class BrandHeader extends StatelessWidget {
  final List<Widget> actions;
  const BrandHeader({super.key, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const BrandLogo(size: 40),
        const SizedBox(width: 10),
        const Text(
          'ASD CARE',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),
        ...actions,
      ],
    );
  }
}

/// Full-width primary (filled) button.
class PrimaryButton extends StatelessWidget {
  final String label;
  final Widget? trailing;
  final Color color;
  final VoidCallback? onTap;
  final bool loading;
  const PrimaryButton({
    super.key,
    required this.label,
    this.trailing,
    this.color = AppColors.primary,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 10),
                    trailing!,
                  ],
                ],
              ),
      ),
    );
  }
}

/// Full-width outlined (secondary) button.
class OutlineButton extends StatelessWidget {
  final String label;
  final Color textColor;
  final VoidCallback? onTap;
  const OutlineButton({
    super.key,
    required this.label,
    this.textColor = AppColors.textMuted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Small rounded circular back button used on top-left of screens.
/// Pops the current route when tapped.
class CircleBackButton extends StatelessWidget {
  const CircleBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.maybePop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.chevron_left, color: AppColors.heading),
      ),
    );
  }
}

/// Section label in uppercase muted text.
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}
