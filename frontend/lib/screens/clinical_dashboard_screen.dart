import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../services/child_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/header_actions.dart';
import 'child_profile_screen.dart';

class ClinicalDashboardScreen extends StatelessWidget {
  const ClinicalDashboardScreen({super.key});

  static String _formatDate(DateTime? date) {
    if (date == null) return 'Not screened';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static (String, Color) _riskInfo(String? risk) {
    switch (risk) {
      case 'high':
        return ('High Risk', AppColors.highRisk);
      case 'moderate':
        return ('Moderate Risk', AppColors.moderateRisk);
      case 'low':
        return ('Low Risk', AppColors.lowRisk);
      default:
        return ('No results', AppColors.textMuted);
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
                  actions: const [
                    SettingsIconButton(backgroundColor: AppColors.selectedFill),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: AppColors.textFaint),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Search by child name or code',
                          style: TextStyle(color: AppColors.textFaint),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SectionLabel('Quick Actions'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChildProfileScreen(),
                        ),
                      ),
                      child: const _QuickPill(
                        icon: Icons.assignment_outlined,
                        label: 'Start Screening',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              StreamBuilder<List<ChildProfile>>(
                stream: ChildService.instance.watchChildren(),
                builder: (context, snapshot) {
                  final children = snapshot.data ?? [];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Child Profiles',
                          style: TextStyle(
                            color: AppColors.heading,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${children.length} records',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              StreamBuilder<List<ChildProfile>>(
                stream: ChildService.instance.watchChildren(),
                builder: (context, snapshot) {
                  final children = snapshot.data ?? [];
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (children.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'No child profiles yet. Add a child to get started.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        for (final child in children) ...[
                          _ProfileCard(
                            name: child.name,
                            info:
                                '${child.ageYears} yrs \u2022 ${child.gender ?? 'N/A'}   ${child.code}',
                            date: _formatDate(child.lastScreeningDate),
                            risk: _riskInfo(child.lastRiskLevel).$1,
                            riskColor: _riskInfo(child.lastRiskLevel).$2,
                          ),
                          const SizedBox(height: 14),
                        ],
                      ],
                    ),
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

class _QuickPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String info;
  final String date;
  final String risk;
  final Color riskColor;

  const _ProfileCard({
    required this.name,
    required this.info,
    required this.date,
    required this.risk,
    required this.riskColor,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.heading,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFDDF0E6),
                child: Icon(Icons.person, color: AppColors.lowRisk, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.border),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Last Screening',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  risk,
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
