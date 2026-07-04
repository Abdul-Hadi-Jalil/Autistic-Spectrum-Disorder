import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../navigation/app_navigator.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

class ConsentScreen extends StatefulWidget {
  /// When provided (from the signup flow), the account is created here once
  /// the user agrees. When null, the screen simply continues to the app.
  final SignupData? signupData;

  const ConsentScreen({super.key, this.signupData});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _agreed = false;
  bool _loading = false;

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _agreeAndContinue() async {
    if (!_agreed) {
      _showMessage('Please confirm you understand and consent to continue.');
      return;
    }

    final data = widget.signupData;
    setState(() => _loading = true);
    try {
      if (data != null) {
        await AuthService.instance.signUp(
          fullName: data.fullName,
          email: data.email,
          password: data.password,
          mode: data.mode,
        );
      }
      if (!mounted) return;
      // Root navigator clears the signup → mode → consent stack.
      navigateToMain(initialIndex: 0);
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Unable to create your account.');
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _InfoCard(
                          title: 'Screening Purpose',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'ASD CARE provides AI-assisted preliminary developmental screening to help identify potential areas of concern in your child\'s development.',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'This screening tool is not a medical diagnosis and should not replace professional medical evaluation or consultation with healthcare providers.',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _InfoCard(
                          title: 'Use of AI Technology',
                          child: _Bullets(const [
                            'Evidence-based developmental milestone assessments',
                            'Pattern recognition algorithms reviewed by clinical professionals',
                            'Standardized screening protocols adapted for digital use',
                          ]),
                        ),
                        _InfoCard(
                          title: 'Data Collection & Storage',
                          child: _Bullets(const [
                            'Your account information is stored securely with industry-standard encryption',
                            'Child screening responses are encrypted and stored confidentially',
                            'Data is shared only by your explicit choice and consent',
                            'No data is sold to third parties or used for marketing purposes',
                          ]),
                        ),
                        _InfoCard(
                          title: 'Your Rights',
                          child: _Bullets(const [
                            'Delete your account and all associated data at any time',
                            'Download and export your screening reports',
                            'Withdraw consent and stop data collection',
                            'Request data corrections or updates',
                          ]),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => setState(() => _agreed = !_agreed),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: _agreed
                                        ? AppColors.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _agreed
                                          ? AppColors.primary
                                          : AppColors.textFaint,
                                    ),
                                  ),
                                  child: _agreed
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'I understand this screening tool does not provide a medical diagnosis and I consent to secure storage of my information as outlined above.',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SafeArea(
              top: false,
              child: PrimaryButton(
                label: 'Agree and Continue',
                loading: _loading,
                onTap: _agreeAndContinue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A6AB0), Color(0xFF6E8FC6)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.chevron_left, color: Colors.white),
              ),
              const Text(
                'Consent & Transparency',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white70),
                ),
                child: const Icon(Icons.help_outline, color: Colors.white),
              ),
              const SizedBox(height: 14),
              const Text(
                'Your Privacy Matters',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We want you to clearly understand how this screening works and how your information is protected before you continue.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  final List<String> items;
  const _Bullets(this.items);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6, right: 10),
                    child: CircleAvatar(
                      radius: 3,
                      backgroundColor: AppColors.textMuted,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      t,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
