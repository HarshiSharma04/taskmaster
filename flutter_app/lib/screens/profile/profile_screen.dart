import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_config.dart';
import '../../providers/providers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/app_snackbar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.linen,
      appBar: AppBar(
        backgroundColor: AppColors.linen,
        title: Text('Profile', style: AppTextStyles.headingLarge),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Profile header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.sand),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.terracotta,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      user?.username.substring(0, 1).toUpperCase() ?? 'U',
                      style: AppTextStyles.displayMedium.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.username ?? '', style: AppTextStyles.headingLarge),
                      const SizedBox(height: 2),
                      Text(user?.email ?? '', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1, end: 0),

          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.sand.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: AppTextStyles.labelLarge.copyWith(fontSize: 12),
              unselectedLabelStyle:
                  AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
              labelColor: AppColors.terracotta,
              unselectedLabelColor: AppColors.charcoal.withOpacity(0.5),
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: 'EDIT PROFILE'),
                Tab(text: 'SECURITY'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _EditProfileTab(user: user),
                const _ChangePasswordTab(),
              ],
            ),
          ),

          // Logout button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                label: Text(
                  'SIGN OUT',
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.error.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out', style: AppTextStyles.headingMedium),
        content: Text('Are you sure you want to sign out?',
            style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
    }
  }
}

class _EditProfileTab extends ConsumerStatefulWidget {
  final dynamic user;
  const _EditProfileTab({this.user});

  @override
  ConsumerState<_EditProfileTab> createState() => _EditProfileTabState();
}

class _EditProfileTabState extends ConsumerState<_EditProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user?.username);
    _emailController = TextEditingController(text: widget.user?.email);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(apiServiceProvider).updateProfile(
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
          );
      if (mounted) AppSnackbar.showSuccess(context, 'Profile updated!');
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, 'Failed to update profile');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 8),
            CustomTextField(
              controller: _usernameController,
              label: 'Username',
              prefixIcon: Icons.person_outline_rounded,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v.length < 3) return 'Min 3 chars';
                return null;
              },
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.mail_outline_rounded,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (!v.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text('SAVE CHANGES', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordTab extends ConsumerStatefulWidget {
  const _ChangePasswordTab();

  @override
  ConsumerState<_ChangePasswordTab> createState() => _ChangePasswordTabState();
}

class _ChangePasswordTabState extends ConsumerState<_ChangePasswordTab> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(apiServiceProvider).changePassword(
            currentPassword: _currentController.text,
            newPassword: _newController.text,
          );
      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
      if (mounted) AppSnackbar.showSuccess(context, 'Password changed!');
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, 'Failed to change password');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 8),
            CustomTextField(
              controller: _currentController,
              label: 'Current Password',
              obscureText: true,
              prefixIcon: Icons.lock_outline_rounded,
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _newController,
              label: 'New Password',
              obscureText: true,
              prefixIcon: Icons.lock_outline_rounded,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v.length < 8) return 'Min 8 chars';
                return null;
              },
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _confirmController,
              label: 'Confirm New Password',
              obscureText: true,
              prefixIcon: Icons.lock_outline_rounded,
              validator: (v) {
                if (v != _newController.text) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text('CHANGE PASSWORD', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
