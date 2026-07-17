import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:elct/l10n/app_localizations.dart';
import '../../../../core/utils/log.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/widgets/google_sign_in_button.dart';
import '../../../../core/widgets/apple_sign_in_button.dart';
import '../../../../core/providers/pending_redirect_provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/presentation/providers/guest_cart_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/error_formatter.dart';
import 'package:elct/features/auth/utils/merge_guest_cart.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoading || _isGoogleLoading) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final currentUserId = ref.read(authRepositoryProvider).currentUserUid;

      if (currentUserId == null) {
        throw StateError('USER_NULL');
      }

      if (!mounted) return;

      final userData = await ref.read(userProfileProvider(currentUserId).future);
      if (!mounted) return;
      final isEmailVerified = userData?['emailVerified'] ?? false;
      final emailVerifiedRequired = userData?['emailVerifiedRequired'] ?? false;
      final emailVerifiedRequiredLocked =
          userData?['emailVerifiedRequiredLocked'] ?? false;

      if (emailVerifiedRequired && !isEmailVerified) {
        final t = AppLocalizations.of(context)!;
        setState(() {
          _isLoading = false;
          _errorMessage = emailVerifiedRequiredLocked
              ? t.emailAlreadyInUse
              : t.emailNotRegistered;
        });
        return;
      }

      if (!mounted) return;
      await ref
          .read(guestCartProvider.notifier)
          .mergeToFirestore(ref.read(cartRepositoryProvider), currentUserId);
      try {
        await NotificationService.instance.onUserLogin();
      } catch (e) {
        logDebug('[Login] Notification init failed: $e');
      }
      if (!mounted) return;
      _navigateAfterLogin();
    } on StateError catch (e) {
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      _handleAuthError(e, t);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleAuthError(StateError e, AppLocalizations t) {
    setState(() => _errorMessage = userErrorMessage(e, t));
  }

  void _navigateAfterLogin() {
    final currentUserId = ref.read(authRepositoryProvider).currentUserUid;
    if (currentUserId == null) {
      throw StateError('USER_NULL');
    }

    final pending = ref.read(pendingRedirectProvider);
    if (pending != null) {
      ref.read(pendingRedirectProvider.notifier).state = null;
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go(pending);
      }
    } else {
      final redirectTo = GoRouterState.of(
        context,
      ).uri.queryParameters['redirect'];
      context.go(
        Routes.isSafeRedirect(redirectTo)
            ? redirectTo!
            : Routes.home,
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    if (_isLoading || _isGoogleLoading) return;
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithGoogle();
      final currentUserId = ref.read(authRepositoryProvider).currentUserUid;

      if (currentUserId == null) {
        throw StateError('USER_NULL');
      }

      if (!mounted) return;
      await mergeGuestCartAndNotify(ref, currentUserId);
      if (!mounted) return;
      _navigateAfterLogin();
    } on StateError catch (e) {
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      _handleAuthError(e, t);
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _loginWithApple() async {
    if (_isLoading || _isGoogleLoading || _isAppleLoading) return;
    setState(() {
      _isAppleLoading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithApple();
      final currentUserId = ref.read(authRepositoryProvider).currentUserUid;

      if (currentUserId == null) {
        throw StateError('USER_NULL');
      }

      if (!mounted) return;
      await mergeGuestCartAndNotify(ref, currentUserId);
      if (!mounted) return;
      _navigateAfterLogin();
    } on StateError catch (e) {
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      _handleAuthError(e, t);
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
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
          onPressed: () => context.pop(),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                                    color: AppColors.gold.withValues(
                                      alpha: 0.18,
                                    ),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.login_outlined,
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
                          t.loginTitle,
                          style: AppTypography.displayMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          t.loginSubtitle,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                        const SizedBox(height: AppSpacing.xl),
                        AppTextField(
                          controller: _emailController,
                          label: t.email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
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
                        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _passwordController,
                          label: t.password,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return t.passwordRequired;
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _errorMessage!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        Align(
                          alignment: isRtl
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () =>
                                context.push(Routes.resetPasswordPhone),
                            child: Text(
                              t.forgotPassword,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppButton(
                          text: t.login,
                          onPressed: _login,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppButton(
                          text: 'الدخول برقم الهاتف (OTP)',
                          isOutlined: true,
                          icon: Icons.phone_android,
                          onPressed: () async {
                            final result = await context.push<bool>(Routes.phoneLogin);
                            if (result == true && context.mounted) {
                              context.pop(true);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                t.orDivider,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        GoogleSignInButton(
                          label: t.continueWithGoogle,
                          isLoading: _isGoogleLoading,
                          onPressed: _loginWithGoogle,
                        ),
                        if (!kIsWeb && Platform.isIOS) ...[
                          const SizedBox(height: AppSpacing.md),
                          AppleSignInButton(
                            label: 'الدخول بواسطة Apple',
                            isLoading: _isAppleLoading,
                            onPressed: _loginWithApple,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              t.noAccount,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                final redirectTo = GoRouterState.of(
                                  context,
                                ).uri.queryParameters['redirect'];
                                if (redirectTo != null &&
                                    redirectTo.isNotEmpty) {
                                  ref
                                          .read(
                                            pendingRedirectProvider.notifier,
                                          )
                                          .state =
                                      redirectTo;
                                }
                                context.replace(Routes.register);
                              },
                              child: Text(
                                t.createAccount,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
