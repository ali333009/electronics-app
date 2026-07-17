import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:elct/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/router/routes.dart';
import '../providers/auth_provider.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const CompleteProfileScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      final uid = repo.currentUserUid;
      if (uid == null) throw Exception('المستخدم غير مسجل الدخول');

      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final displayName = '$firstName $lastName';
      final email = _emailController.text.trim();

      await repo.saveUserProfile(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        email: email, // Could be empty, backend should handle or we enforce it
        phoneNumber: widget.phoneNumber,
        displayName: displayName,
        phoneVerified: true,
      );

      await repo.updateDisplayName(displayName);

      if (mounted) {
        context.go(Routes.home);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'أهلاً بك معنا!',
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'يرجى استكمال بياناتك لنتمكن من توصيل طلباتك بنجاح',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: AppSpacing.xxl),
                
                AppTextField(
                  controller: _firstNameController,
                  label: t.firstName,
                  validator: (v) {
                    if (v == null || v.isEmpty) return t.firstNameRequired;
                    return null;
                  },
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: AppSpacing.md),
                
                AppTextField(
                  controller: _lastNameController,
                  label: t.lastName,
                  validator: (v) {
                    if (v == null || v.isEmpty) return t.lastNameRequired;
                    return null;
                  },
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                const SizedBox(height: AppSpacing.md),
                
                AppTextField(
                  controller: _emailController,
                  label: t.email,
                  hint: 'اختياري',
                  keyboardType: TextInputType.emailAddress,
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  height: 56,
                  child: AppButton(
                    text: 'حفظ ومتابعة',
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
