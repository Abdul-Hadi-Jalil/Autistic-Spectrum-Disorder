import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../services/child_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/header_actions.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static String _formatFollowUp(DateTime? date) {
    if (date == null) return '—';
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    if (diff <= 0) return 'Due now';
    if (diff < 30) return '${diff}d';
    final months = (diff / 30).round();
    return '$months mo';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<ChildProfile>>(
          stream: ChildService.instance.watchChildren(),
          builder: (context, childrenSnap) {
            final children = childrenSnap.data ?? [];

            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: ChildService.instance.watchRecentScreenings(limit: 200),
              builder: (context, screeningsSnap) {
                final screenings = screeningsSnap.data ?? [];
                final riskFlags = screenings
                    .where((s) =>
                        s['riskLevel'] == 'high' ||
                        s['riskLevel'] == 'moderate')
                    .length;

                DateTime? nextFollowUp;
                for (final child in children) {
                  final d = child.nextScreeningDate;
                  if (d == null) continue;
                  if (nextFollowUp == null || d.isBefore(nextFollowUp)) {
                    nextFollowUp = d;
                  }
                }

                final loading = (childrenSnap.connectionState ==
                            ConnectionState.waiting &&
                        !childrenSnap.hasData) ||
                    (screeningsSnap.connectionState ==
                            ConnectionState.waiting &&
                        !screeningsSnap.hasData);

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const BrandHeader(
                        actions: [SettingsIconButton()],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Reports',
                        style: TextStyle(
                          color: AppColors.heading,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Your screening data overview',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 20),
                      if (loading)
                        const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else ...[
                        const SectionLabel('Overview'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                value: '${screenings.length}',
                                label: 'Screenings done',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                value: '${children.length}',
                                label: 'Children tracked',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                value: '$riskFlags',
                                label: 'Risk flags',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                value: _formatFollowUp(nextFollowUp),
                                label: 'Next follow-up',
                              ),
                            ),
                          ],
                        ),
                        if (screenings.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          const SectionLabel('Recent Screenings'),
                          const SizedBox(height: 12),
                          for (final s in screenings.take(5)) ...[
                            _ScreeningRow(
                              childName: (s['childName'] as String?) ?? '—',
                              riskLevel: (s['riskLevel'] as String?) ?? 'moderate',
                              date: s['createdAt'] as DateTime?,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ],
                      const SizedBox(height: 22),
                      const SectionLabel('Requires Pro'),
                      const SizedBox(height: 12),
                      const _ProRow(
                        icon: Icons.timeline,
                        title: 'Progress timeline',
                        subtitle: 'Month-by-month trends',
                      ),
                      const SizedBox(height: 12),
                      const _ProRow(
                        icon: Icons.picture_as_pdf_outlined,
                        title: 'PDF Export',
                        subtitle: 'Download your report',
                      ),
                      const SizedBox(height: 12),
                      const _ProRow(
                        icon: Icons.description_outlined,
                        title: 'Clinical Summaries',
                        subtitle: 'Full assessment history',
                      ),
                      const SizedBox(height: 12),
                      const _ProRow(
                        icon: Icons.notifications_active_outlined,
                        title: 'Risk Alerts',
                        subtitle: 'Priority Notifications',
                      ),
                      const SizedBox(height: 26),
                      const PrimaryButton(
                        label: 'Upgrade to pro',
                        trailing: Icon(Icons.arrow_forward, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.heading,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ScreeningRow extends StatelessWidget {
  final String childName;
  final String riskLevel;
  final DateTime? date;

  const _ScreeningRow({
    required this.childName,
    required this.riskLevel,
    this.date,
  });

  Color get _riskColor {
    switch (riskLevel) {
      case 'high':
        return AppColors.highRisk;
      case 'low':
        return AppColors.lowRisk;
      default:
        return AppColors.moderateRisk;
    }
  }

  String get _riskLabel {
    switch (riskLevel) {
      case 'high':
        return 'High';
      case 'low':
        return 'Low';
      default:
        return 'Moderate';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = date == null
        ? '—'
        : '${date!.month}/${date!.day}/${date!.year}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  childName,
                  style: const TextStyle(
                    color: AppColors.heading,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _riskColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _riskLabel,
              style: TextStyle(
                color: _riskColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _ProRow({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
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
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, color: AppColors.textFaint, size: 20),
        ],
      ),
    );
  }
}
