import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../navigation/app_navigator.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  /// Called when the user taps the "sign up" link (used by PreferenceScreen
  /// to toggle to the signup screen). May be null when shown stand-alone.
  final VoidCallback? onToggle;

  const LoginScreen({super.key, this.onToggle});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter your email and password.');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.instance.signIn(email: email, password: password);
      if (!mounted) return;
      navigateToMain(initialIndex: 1);
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Unable to sign in.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Enter your email above to reset your password.');
      return;
    }
    try {
      await AuthService.instance.sendPasswordReset(email);
      _showMessage('Password reset email sent.');
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Unable to send reset email.');
    }
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
              const SizedBox(height: 16),
              const Center(child: BrandLogo(size: 64)),
              const SizedBox(height: 18),
              const Text(
                'A S D   C A R E',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 28),
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
                        'Welcome Back',
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
                        'Sign in to continue your journey',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AuthField(
                      label: 'Email or Phone',
                      hint: 'Enter your email or phone',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),
                    AuthField(
                      label: 'Password',
                      hint: 'Enter your password',
                      obscure: true,
                      showEye: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 22),
                    PrimaryButton(
                      label: 'Log In',
                      loading: _loading,
                      onTap: _login,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: _resetPassword,
                        child: const Text(
                          'Forgot your password?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
                              TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: 'sign up',
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
