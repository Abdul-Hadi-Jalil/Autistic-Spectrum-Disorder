import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../services/child_service.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/header_actions.dart';
import 'child_profile_screen.dart';
import 'developmental_question_screen.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  static String _formatDate(DateTime? date) {
    if (date == null) return 'Not yet screened';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static Color _riskColor(String? risk) {
    switch (risk) {
      case 'high':
        return AppColors.highRisk;
      case 'moderate':
        return AppColors.moderateRisk;
      case 'low':
        return AppColors.lowRisk;
      default:
        return AppColors.textMuted;
    }
  }

  static String _riskLabel(String? risk) {
    switch (risk) {
      case 'high':
        return 'High Risk';
      case 'moderate':
        return 'Moderate Risk';
      case 'low':
        return 'Low Risk';
      default:
        return 'No results';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: BrandHeader(
                  actions: [
                    NotificationIconButton(
                      unreadStream:
                          NotificationService.instance.watchUnreadCount(),
                    ),
                    const SizedBox(width: 10),
                    const SettingsIconButton(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Your Children',
                  style: TextStyle(
                    color: AppColors.heading,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              StreamBuilder<List<ChildProfile>>(
                stream: ChildService.instance.watchChildren(),
                builder: (context, snapshot) {
                  final children = snapshot.data ?? [];
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const SizedBox(
                      height: 225,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return SizedBox(
                    height: 225,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        if (children.isEmpty)
                          _AddChildCard(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ChildProfileScreen(),
                              ),
                            ),
                          )
                        else ...[
                          for (final child in children) ...[
                            _ChildCard(
                              child: child,
                              formatDate: _formatDate,
                              onStartScreening: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => DevelopmentalQuestionScreen(
                                    childId: child.id,
                                    childName: child.name,
                                    age: child.ageYears,
                                    gender: child.gender,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                          ],
                          _AddChildCard(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ChildProfileScreen(),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 26),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: AppColors.heading,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.assignment_outlined,
                        label: 'Start New\nScreening',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ChildProfileScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: _QuickAction(
                        icon: Icons.show_chart_rounded,
                        label: 'View\nReports',
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: _QuickAction(
                        icon: Icons.event_available_outlined,
                        label: 'Book\nConsultation',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Recent Results',
                      style: TextStyle(
                        color: AppColors.heading,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'View All',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: ChildService.instance.watchRecentScreenings(),
                builder: (context, snapshot) {
                  final results = snapshot.data ?? [];
                  if (results.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'No screening results yet.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final r in results) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _ResultCard(
                            name: r['childName'] as String? ?? '',
                            date: _formatDate(r['createdAt'] as DateTime?),
                            badge: _riskLabel(r['riskLevel'] as String?),
                            badgeColor:
                                _riskColor(r['riskLevel'] as String?),
                            type: r['type'] as String? ?? 'Screening',
                            summary: r['summary'] as String? ?? '',
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddChildCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddChildCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: Container(
          width: 200,
          margin: const EdgeInsets.only(right: 14),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.selectedFill,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 14),
              const Text(
                'Add New Child',
                style: TextStyle(
                  color: AppColors.heading,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Track multiple profiles',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const dash = 6.0;
    const gap = 4.0;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final len = (dist + dash > metric.length) ? metric.length - dist : dash;
        canvas.drawPath(metric.extractPath(dist, dist + len), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChildCard extends StatelessWidget {
  final ChildProfile child;
  final String Function(DateTime?) formatDate;
  final VoidCallback onStartScreening;

  const _ChildCard({
    required this.child,
    required this.formatDate,
    required this.onStartScreening,
  });

  @override
  Widget build(BuildContext context) {
    final gender = child.gender ?? 'Not specified';
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFE2E8F0),
                child: Icon(Icons.child_care, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: const TextStyle(
                        color: AppColors.heading,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${child.ageLabel} \u2022 $gender',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Last Screening',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  formatDate(child.lastScreeningDate),
                  style: const TextStyle(
                    color: AppColors.heading,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (child.nextScreeningDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Next recommended: ${formatDate(child.nextScreeningDate)}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onStartScreening,
                  child: Container(
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Start Screening',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.selectedFill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'View Results',
                    style: TextStyle(color: AppColors.primary, fontSize: 13),
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

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _QuickAction({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 96,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String name;
  final String date;
  final String badge;
  final Color badgeColor;
  final String type;
  final String summary;

  const _ResultCard({
    required this.name,
    required this.date,
    required this.badge,
    required this.badgeColor,
    required this.type,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFE2E8F0),
                child: Icon(
                  Icons.child_care,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.heading,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _Badge(label: badge, color: badgeColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            type,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            summary,
            style: const TextStyle(color: Color(0xFF374151), height: 1.4),
          ),
          const SizedBox(height: 8),
          const Text(
            'View Details',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
