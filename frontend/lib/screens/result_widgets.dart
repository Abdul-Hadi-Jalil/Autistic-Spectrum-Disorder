import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A single recommended-step / support-activity item.
class ResultItem {
  final IconData? icon;
  final String title;
  final String? body;
  const ResultItem({this.icon, required this.title, this.body});
}

/// Pill badge shown at the top of a risk result and inside the white card.
class RiskPill extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? background;
  final bool withIcon;
  const RiskPill({
    super.key,
    required this.label,
    this.color,
    this.background,
    this.withIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: background ?? Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (withIcon) ...[
            Icon(Icons.info_outline, size: 15, color: color ?? Colors.white),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Big serif percentage shown on risk result screens.
class PercentDisplay extends StatelessWidget {
  final String percent;
  const PercentDisplay({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          percent,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 88,
            fontWeight: FontWeight.w700,
            fontFamily: 'serif',
            height: 1,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 14),
          child: Text(
            '%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w500,
              fontFamily: 'serif',
            ),
          ),
        ),
      ],
    );
  }
}

/// White detail card describing the risk level.
class RiskCard extends StatelessWidget {
  final String pillLabel;
  final Color pillColor;
  final String message;
  final IconData noteIcon;
  final String note;

  const RiskCard({
    super.key,
    required this.pillLabel,
    required this.pillColor,
    required this.message,
    required this.noteIcon,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RiskPill(
            label: pillLabel,
            color: pillColor,
            background: pillColor.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 19,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(noteIcon, size: 18, color: pillColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  note,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// White card listing recommended next steps or support activities.
class ResultListCard extends StatelessWidget {
  final String sectionTitle;
  final Color accent;
  final List<ResultItem> items;
  final bool bulletStyle;

  const ResultListCard({
    super.key,
    required this.sectionTitle,
    required this.accent,
    required this.items,
    this.bulletStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitle,
            style: TextStyle(
              color: accent,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < items.length; i++) ...[
            if (bulletStyle)
              _bulletRow(items[i])
            else
              _iconRow(items[i], accent),
            if (i != items.length - 1) const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }

  Widget _bulletRow(ResultItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, right: 12),
          child: CircleAvatar(radius: 4, backgroundColor: accent),
        ),
        Expanded(
          child: Text(
            item.title,
            style: const TextStyle(
              color: Color(0xFF333333),
              height: 1.4,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconRow(ResultItem item, Color accent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, size: 18, color: accent),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: Color(0xFF222222),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              if (item.body != null) ...[
                const SizedBox(height: 4),
                Text(
                  item.body!,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
