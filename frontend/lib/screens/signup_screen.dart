import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/auth_widgets.dart';
import 'mode_selection_screen.dart';

class SignupScreen extends StatefulWidget {
  /// Called when the user taps the "Log In" link (used by PreferenceScreen
  /// to toggle to the login screen). May be null when shown stand-alone.
  final VoidCallback? onToggle;

  const SignupScreen({super.key, this.onToggle});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _continueToConsent() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }
    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ModeSelectionScreen(
          signupData: SignupData(
            fullName: name,
            email: email,
            password: password,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Center(child: BrandLogo(size: 60)),
              const SizedBox(height: 16),
              const Text(
                'A S D   C A R E',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Create Your Account',
                        style: TextStyle(
                          color: AppColors.heading,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Sign up to continue your journey',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AuthField(
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 18),
                    AuthField(
                      label: 'Email Address',
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),
                    AuthField(
                      label: 'Password',
                      hint: 'Create a password',
                      obscure: true,
                      showEye: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(height: 4, color: AppColors.border),
                    ),
                    const SizedBox(height: 22),
                    PrimaryButton(
                      label: 'Create Account',
                      onTap: _continueToConsent,
                    ),
                    const SizedBox(height: 18),
                    const OrDivider(),
                    const SizedBox(height: 18),
                    Row(
                      children: const [
                        Expanded(
                          child: SocialButton(
                            label: 'Google',
                            icon: Icons.g_mobiledata,
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: SocialButton(
                            label: 'Apple',
                            icon: Icons.apple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: widget.onToggle,
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Log In',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}
