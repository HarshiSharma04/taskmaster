import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_config.dart';
import '../../providers/providers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/app_snackbar.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
          _emailController.text.trim(),
          _usernameController.text.trim(),
          _passwordController.text,
        );

    if (!success && mounted) {
      final error = ref.read(authProvider).error ?? 'Registration failed';
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
                const SizedBox(height: 20),
                // Back button
                GestureDetector(
                  onTap: () => context.go('/auth/login'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.sand,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.arrow_back_rounded,
                        color: AppColors.charcoal, size: 20),
                  ),
                ),
                const SizedBox(height: 28),
                Text('Create account.', style: AppTextStyles.displayLarge)
                    .animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Start organizing your life today',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.charcoal.withOpacity(0.6)),
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 36),

                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'your@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: 14),

                CustomTextField(
                  controller: _usernameController,
                  label: 'Username',
                  hint: 'your_username',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Username is required';
                    if (v.length < 3) return 'Min 3 characters';
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v)) {
                      return 'Only letters, numbers, underscores';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 280.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: 14),

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
                    if (v.length < 8) return 'Min 8 characters';
                    return null;
                  },
                ).animate().fadeIn(delay: 360.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: 14),

                CustomTextField(
                  controller: _confirmController,
                  label: 'Confirm Password',
                  hint: '••••••••',
                  obscureText: _obscureConfirm,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.charcoal.withOpacity(0.5),
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _register(),
                ).animate().fadeIn(delay: 440.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _register,
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text('CREATE ACCOUNT', style: AppTextStyles.button),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 24),

                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/auth/login'),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: AppTextStyles.bodyMedium,
                        children: [
                          TextSpan(
                            text: 'Sign in',
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
                ).animate().fadeIn(delay: 580.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
