import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/app_flow_handle_screens/auth_state_screen.dart';
import 'package:frontend/navigation/app_navigator.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/user_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/app_bottom_nav.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        onTap: (_) => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        bottom: false,
        child: StreamBuilder(
          stream: UserService.instance.watchProfile(),
          builder: (context, snapshot) {
            final profile = snapshot.data;
            final user = FirebaseAuth.instance.currentUser;
            final name = profile?.fullName ?? user?.displayName ?? 'User';
            final email = profile?.email ?? user?.email ?? '';
            final initials = AuthService.initials(name);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const BrandHeader(),
                  const SizedBox(height: 18),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: AppColors.heading,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.selectedFill,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: AppColors.heading,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                email,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.selectedFill,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _ToggleRow(
                          color: const Color(0xFFFBF0CF),
                          label: 'Push Notifications',
                          value: profile?.pushNotifications ?? true,
                          onChanged: (v) => UserService.instance
                              .updateSettings(pushNotifications: v),
                        ),
                        _divider(),
                        _ToggleRow(
                          color: const Color(0xFFE7EEFB),
                          label: 'Email Alerts',
                          value: profile?.emailAlerts ?? true,
                          onChanged: (v) =>
                              UserService.instance.updateSettings(emailAlerts: v),
                        ),
                        _divider(),
                        _ToggleRow(
                          color: const Color(0xFFFBE0E0),
                          label: 'High Risk Alerts',
                          value: profile?.highRiskAlerts ?? true,
                          onChanged: (v) => UserService.instance
                              .updateSettings(highRiskAlerts: v),
                        ),
                        _divider(),
                        _ToggleRow(
                          color: const Color(0xFFDDF0E6),
                          label: 'Screening Reminders',
                          value: profile?.screeningReminders ?? false,
                          onChanged: (v) => UserService.instance
                              .updateSettings(screeningReminders: v),
                        ),
                        _divider(),
                        const _LinkRow(
                          color: Color(0xFFE7EEFB),
                          label: 'Help & FAQ',
                        ),
                        _divider(),
                        const _LinkRow(
                          color: Color(0xFFDDF0E6),
                          label: 'Contact Support',
                        ),
                        _divider(),
                        const _LinkRow(
                          color: Color(0xFFEDE3FB),
                          label: 'Privacy & Data',
                          subtitle: 'Data usage, encryption',
                        ),
                        _divider(),
                        const _LinkRow(
                          color: Color(0xFFF1F2F4),
                          label: 'Terms & Privacy Policy',
                        ),
                        _divider(),
                        const _CenterAction(label: 'Delete Account'),
                        _divider(),
                        _CenterAction(
                          label: 'Log Out',
                          onTap: () async {
                            try {
                              await AuthService.instance.signOut();
                              rootNavigatorKey.currentState?.pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const AuthStateScreen(),
                                ),
                                (route) => false,
                              );
                            } catch (_) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Logout failed. Please try again.',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget _divider() => const Divider(
        height: 1,
        color: AppColors.border,
        indent: 14,
        endIndent: 14,
      );
}

class _ToggleRow extends StatelessWidget {
  final Color color;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.color,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _IconBox(color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.heading,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: _FakeSwitch(value: value),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final Color color;
  final String label;
  final String? subtitle;
  const _LinkRow({required this.color, required this.label, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _IconBox(color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.heading,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
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
    );
  }
}

class _CenterAction extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _CenterAction({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final Color color;
  const _IconBox({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _FakeSwitch extends StatelessWidget {
  final bool value;
  const _FakeSwitch({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 26,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: value ? AppColors.primary : const Color(0xFFCBD2DC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Align(
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
