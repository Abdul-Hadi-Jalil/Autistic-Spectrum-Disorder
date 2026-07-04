import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<UserProfile?>(
          stream: UserService.instance.watchProfile(),
          builder: (context, profileSnap) {
            final profile = profileSnap.data;
            final user = FirebaseAuth.instance.currentUser;
            final name = profile?.fullName ??
                user?.displayName ??
                'User';
            final email = profile?.email ?? user?.email ?? '';
            final initials = AuthService.initials(name);
            final modeLabel =
                profile?.isClinical == true ? 'Clinical' : 'Parent';

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Text(
                      'About',
                      style: TextStyle(
                        color: AppColors.heading,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ProfileHeader(
                    initials: initials,
                    name: name,
                    email: email,
                    modeLabel: modeLabel,
                    planLabel: _planLabel(profile?.plan),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _PlanCard(profile: profile),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SectionLabel('Your Plan'),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SectionLabel('Personal Information'),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            color: const Color(0xFFE7EEFB),
                            title: 'Full name',
                            value: name,
                          ),
                          const Divider(height: 1, color: AppColors.border),
                          _InfoRow(
                            color: const Color(0xFFE7EEFB),
                            title: 'Email address',
                            value: email,
                          ),
                          const Divider(height: 1, color: AppColors.border),
                          _InfoRow(
                            color: const Color(0xFFDDF0E6),
                            title: 'Phone number',
                            value: profile?.phoneNumber ?? 'Not set',
                          ),
                          const Divider(height: 1, color: AppColors.border),
                          _InfoRow(
                            color: const Color(0xFFF1F2F4),
                            title: 'Mode',
                            subtitle: 'Switch between Parent & Clinician',
                            value: modeLabel,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SectionLabel('Security'),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static String _planLabel(String? plan) {
    if (plan == null || plan == 'free') return 'Free Plan';
    return plan[0].toUpperCase() + plan.substring(1);
  }
}

class _ProfileHeader extends StatelessWidget {
  final String initials;
  final String name;
  final String email;
  final String modeLabel;
  final String planLabel;

  const _ProfileHeader({
    required this.initials,
    required this.name,
    required this.email,
    required this.modeLabel,
    required this.planLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFF49619E),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(color: Color(0xFFAFC1E8)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MiniBadge(label: modeLabel, color: const Color(0xFF49619E)),
              const SizedBox(width: 8),
              _MiniBadge(label: planLabel, color: const Color(0xFFCBA85A)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF6E84BB)),
            ),
            child: const Text(
              'Edit Profile',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

class _PlanCard extends StatefulWidget {
  final UserProfile? profile;
  const _PlanCard({this.profile});

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  int _children = 0;
  int _screenings = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final children = await UserService.instance.childrenCount();
    final screenings = await UserService.instance.screeningsCount();
    if (mounted) {
      setState(() {
        _children = children;
        _screenings = screenings;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.profile?.plan ?? 'free';
    final planLabel = plan == 'free' ? 'Free Plan' : plan;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                planLabel,
                style: const TextStyle(
                  color: AppColors.heading,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _UsageBar(
            label: 'Screenings',
            value: (_screenings / 5).clamp(0.0, 1.0),
            trailing: '$_screenings / 5',
          ),
          const SizedBox(height: 12),
          _UsageBar(
            label: 'Children',
            value: (_children / 5).clamp(0.0, 1.0),
            trailing: '$_children / 5',
          ),
          const SizedBox(height: 12),
          const _UsageBar(
            label: 'Reports',
            value: 1,
            trailing: 'Locked',
            color: AppColors.danger,
            trailingColor: AppColors.danger,
          ),
          const SizedBox(height: 18),
          const PrimaryButton(label: 'Upgrade to Pro'),
        ],
      ),
    );
  }
}

class _UsageBar extends StatelessWidget {
  final String label;
  final double value;
  final String trailing;
  final Color color;
  final Color trailingColor;

  const _UsageBar({
    required this.label,
    required this.value,
    required this.trailing,
    this.color = AppColors.primary,
    this.trailingColor = AppColors.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.heading, fontSize: 13),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 56,
          child: Text(
            trailing,
            textAlign: TextAlign.right,
            style: TextStyle(color: trailingColor, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final Color color;
  final String title;
  final String? subtitle;
  final String value;
  const _InfoRow({
    required this.color,
    required this.title,
    this.subtitle,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
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
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  )
                else
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          if (subtitle != null)
            Text(
              value,
              style: const TextStyle(color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}
