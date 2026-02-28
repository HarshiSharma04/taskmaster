import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_config.dart';
import '../../providers/providers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/app_snackbar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    final success = await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (!success && mounted) {
      final error = ref.read(authProvider).error ?? 'Login failed';
      AppSnackbar.showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.linen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Header
                _buildHeader(),
                const SizedBox(height: 48),

                // Email field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'your@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: 16),

                // Password field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.charcoal.withOpacity(0.5),
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    return null;
                  },
                  onFieldSubmitted: (_) => _login(),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: 32),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text('SIGN IN', style: AppTextStyles.button),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 24),

                // Register link
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/auth/register'),
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: AppTextStyles.bodyMedium,
                        children: [
                          TextSpan(
                            text: 'Create one',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.terracotta,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.terracotta,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.terracotta,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 20),
        Text('Welcome back.', style: AppTextStyles.displayLarge)
            .animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 8),
        Text(
          'Sign in to manage your tasks',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.charcoal.withOpacity(0.6),
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }
}
