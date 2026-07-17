import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:elct/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/error_formatter.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _sent = false;
  bool _isLoading = false;
  String? _errorMessage;

  String get _emailForDisplay => '\u202A${_emailController.text.trim()}\u202C';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.sendPasswordResetEmail(email: _emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _sent = true;
      });
    } catch (e) {
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = userErrorMessage(e, t);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        leading: IconButton(
          icon: Icon(
            isRtl ? Icons.arrow_forward : Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: _sent
              ? () => setState(() {
                  _sent = false;
                  _errorMessage = null;
                })
              : () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - AppSpacing.xxl,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSpacing.xl),
                      Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.gold.withValues(alpha: 0.2),
                                  AppColors.gold.withValues(alpha: 0.08),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withValues(alpha: 0.18),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              _sent
                                  ? Icons.mark_email_unread_outlined
                                  : Icons.lock_reset_outlined,
                              size: 40,
                              color: AppColors.gold,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1, 1),
                            duration: 400.ms,
                            curve: Curves.easeOutBack,
                          ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        _sent ? t.resetLinkSent : t.forgotPasswordTitle,
                        style: AppTypography.displayMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _sent
                            ? '${t.checkYourEmail}\n$_emailForDisplay'
                            : t.forgotPasswordSubtitle,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                      const SizedBox(height: AppSpacing.xl),
                      if (!_sent)
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.email],
                                onFieldSubmitted: (_) => _sendResetEmail(),
                                validator: (v) {
                                  final email = v?.trim() ?? '';
                                  if (email.isEmpty) return t.emailRequired;
                                  if (!RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+$',
                                  ).hasMatch(email)) {
                                    return t.emailInvalid;
                                  }
                                  return null;
                                },
                                style: AppTypography.bodyLarge,
                                decoration: InputDecoration(
                                  labelText: t.email,
                                  hintText: 'name@example.com',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  floatingLabelStyle: const TextStyle(
                                    color: AppColors.gold,
                                  ),
                  labelStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.gold,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.error,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.error,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(
                                delay: 300.ms,
                                duration: 400.ms,
                              ),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  _errorMessage!,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ).animate().fadeIn(
                                  delay: 350.ms,
                                  duration: 300.ms,
                                ),
                              ],
                              const SizedBox(height: AppSpacing.lg),
                              AppButton(
                                text: t.sendResetLink,
                                onPressed: _sendResetEmail,
                                isLoading: _isLoading,
                              ).animate().fadeIn(
                                delay: 400.ms,
                                duration: 400.ms,
                              ),
                            ],
                          ),
                        ),
                      if (_sent) ...[
                        const SizedBox(height: AppSpacing.md),
                        AppButton(
                          text: t.backToLogin,
                          onPressed: () => context.pop(),
                        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
