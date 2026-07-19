import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:elct/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/utils/error_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/providers/pending_redirect_provider.dart';
import '../providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/presentation/providers/guest_cart_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class PhoneVerificationScreen extends ConsumerStatefulWidget {
  final String? phoneNumber;

  const PhoneVerificationScreen({super.key, this.phoneNumber});

  @override
  ConsumerState<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState
    extends ConsumerState<PhoneVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _codeSent = false;
  bool _resendEnabled = false;
  String? _errorMessage;
  String? _verificationId;
  int _resendSeconds = 30;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 30;
    _resendEnabled = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendSeconds--;
        if (_resendSeconds <= 0) {
          _resendEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  void _sendOtp() {
    setState(() {
      _errorMessage = null;
      _codeSent = false;
    });
    final repo = ref.read(authRepositoryProvider);
    repo.sendOtp(
      phoneNumber: _phoneNumber,
      onCodeSent: (verificationId, resendToken) {
        if (!mounted) return;
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
        });
        _startResendTimer();
      },
      onError: (error) {
        if (!mounted) return;
        final t = AppLocalizations.of(context)!;
        setState(() => _errorMessage = userErrorMessage(StateError(error), t));
      },
      onVerificationCompleted: (credential) async {
        if (!mounted || _isVerifying) return;
        setState(() => _isVerifying = true);
        try {
          await _linkAndContinue(credential);
        } catch (e) {
          if (!mounted) return;
          final t = AppLocalizations.of(context)!;
          setState(() => _errorMessage = userErrorMessage(e, t));
        } finally {
          if (mounted) setState(() => _isVerifying = false);
        }
      },
    );
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    }
  }

  Future<void> _verifyAndSubmit() async {
    final code = _otpControllers.map((c) => c.text).join();
    if (code.length != 6) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.otpInvalid;
      });
      return;
    }
    if (_verificationId == null) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });
    try {
      await _linkAndContinue(code);
    } catch (e) {
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      setState(() => _errorMessage = userErrorMessage(e, t));
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  String get _phoneNumber {
    if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
      return widget.phoneNumber!;
    }
    return ref.read(registrationDataProvider)?.phoneNumber ?? '';
  }

  String get _phoneNumberForDisplay => '\u202A$_phoneNumber\u202C';

  Future<void> _linkAndContinue(dynamic credentialOrCode) async {
    final repo = ref.read(authRepositoryProvider);
    final regData = ref.read(registrationDataProvider);

    if (regData != null) {
      try {
        // 1. Create the Auth account after the phone OTP is verified.
        final user = await repo.createUserWithEmailAndPassword(
          email: regData.email,
          password: regData.password,
        );

        // 2. Save profile in Firestore
        await repo.saveUserProfile(
          uid: user.uid,
          firstName: regData.firstName,
          lastName: regData.lastName,
          email: regData.email,
          phoneNumber: regData.phoneNumber,
          displayName: '${regData.firstName} ${regData.lastName}',
          photoUrl: null,
          phoneVerified: true,
        );

        // 3. Update display name in Firebase Auth
        await repo.updateDisplayName(
          '${regData.firstName} ${regData.lastName}',
        );

        // 4. Link the phone credential
        if (credentialOrCode is String) {
          await repo.linkPhoneWithOtp(
            verificationId: _verificationId!,
            smsCode: credentialOrCode,
            phoneNumber: _phoneNumber,
          );
        } else {
          await repo.linkPhoneCredential(
            credentialOrCode,
            phoneNumber: _phoneNumber,
          );
        }

        // Merge guest cart into the new account.
        await ref
            .read(guestCartProvider.notifier)
            .mergeToFirestore(ref.read(cartRepositoryProvider), user.uid);
      } catch (e) {
        // Clear registration data first, before any auth state changes
        ref.read(registrationDataProvider.notifier).state = null;
        ref.read(registrationErrorProvider.notifier).state = e is StateError
            ? e.message
            : 'UNKNOWN';
        // Cleanup: delete the auth user if any registration step failed
        try {
          await ref.read(authRepositoryProvider).deleteCurrentUser();
        } catch (_) {}
        if (mounted) {
          context.go(Routes.register);
        }
        return;
      }

      // 6. Clear registration data
      ref.read(registrationDataProvider.notifier).state = null;

      await NotificationService.instance.onUserLogin();

      if (!mounted) return;
      final pending = ref.read(pendingRedirectProvider);
      if (!mounted) return;
      if (pending != null) {
        ref.read(pendingRedirectProvider.notifier).state = null;
        if (context.canPop()) {
          context.pop(true);
        } else {
          context.go(pending);
        }
      } else {
        context.go(Routes.home);
      }
      return;
    } else {
      // If no registration data, check if logged in
      final isLoggedIn = repo.currentUserUid != null;
      if (isLoggedIn) {
        if (credentialOrCode is String) {
          await repo.linkPhoneWithOtp(
            verificationId: _verificationId!,
            smsCode: credentialOrCode,
            phoneNumber: _phoneNumber,
          );
        } else {
          await repo.linkPhoneCredential(
            credentialOrCode,
            phoneNumber: _phoneNumber,
          );
        }
      } else {
        // Sign in
        if (credentialOrCode is String) {
          final user = await repo.signInWithOtp(
            verificationId: _verificationId!,
            smsCode: credentialOrCode,
          );
          // Merge guest cart into the logged-in account
          await ref.read(guestCartProvider.notifier).mergeToFirestore(
            ref.read(cartRepositoryProvider),
            user.uid,
          );
          
          // Check if profile exists
          final profileRepo = ref.read(addressRepositoryProvider);
          final userData = await profileRepo.getUserData(user.uid);
          if (userData == null || userData['firstName'] == null || userData['firstName'].toString().isEmpty) {
             if (mounted) {
               context.go(Routes.completeProfile, extra: _phoneNumber);
             }
             return;
          }
        } else {
          await repo.signInWithPhoneCredential(credentialOrCode);
          final uid = repo.currentUserUid;
          if (uid != null) {
            await ref.read(guestCartProvider.notifier).mergeToFirestore(
              ref.read(cartRepositoryProvider),
              uid,
            );
            // Check if profile exists
            final profileRepo = ref.read(addressRepositoryProvider);
            final userData = await profileRepo.getUserData(uid);
            if (userData == null || userData['firstName'] == null || userData['firstName'].toString().isEmpty) {
               if (mounted) {
                 context.go(Routes.completeProfile, extra: _phoneNumber);
               }
               return;
            }
          }
        }
      }
    }

    await NotificationService.instance.onUserLogin();

    if (!mounted) return;
    AppToast.show(
      context,
      AppLocalizations.of(context)!.phoneVerified,
      icon: Icons.check_circle_outline,
    );

    // Merge guest cart if any
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid != null) {
      await ref
          .read(guestCartProvider.notifier)
          .mergeToFirestore(ref.read(cartRepositoryProvider), uid);
    }

    final pending = ref.read(pendingRedirectProvider);
    if (!mounted) return;
    if (pending != null) {
      ref.read(pendingRedirectProvider.notifier).state = null;
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go(pending);
      }
    } else {
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmBack();
      },
      child: Scaffold(
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
            onPressed: _confirmBack,
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
                                    color: AppColors.gold.withValues(
                                      alpha: 0.18,
                                    ),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.smartphone_outlined,
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
                          t.phoneVerificationTitle,
                          style: AppTypography.displayMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          t.phoneVerificationSubtitle(_phoneNumberForDisplay),
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                        const SizedBox(height: AppSpacing.xl),
                        if (!_codeSent) ...[
                          if (_errorMessage != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Text(
                                _errorMessage!,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ).animate().fadeIn(),
                            const SizedBox(height: AppSpacing.lg),
                            SizedBox(
                              height: 52,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _sendOtp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gold,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                  child: Text(
                                    AppLocalizations.of(context)!.resendCode,
                                    style: AppTypography.titleLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ),
                            ).animate().fadeIn(),
                          ] else
                            const Padding(
                              padding: EdgeInsets.only(top: AppSpacing.md),
                              child: CircularProgressIndicator(
                                color: AppColors.gold,
                              ),
                            ).animate().fadeIn(delay: 300.ms),
                        ] else ...[
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                LayoutBuilder(
                                  builder: (context, fieldConstraints) {
                                    final otpBoxWidth =
                                        ((fieldConstraints.maxWidth -
                                                    AppSpacing.sm * 5) /
                                                6)
                                            .clamp(34.0, 46.0)
                                            .toDouble();

                                    return Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                      children: List.generate(6, (i) {
                                        return SizedBox(
                                          width: otpBoxWidth,
                                          child: Focus(
                                            onKeyEvent: (focusNode, event) {
                                              if (event.logicalKey ==
                                                      LogicalKeyboardKey
                                                          .backspace &&
                                                  _otpControllers[i]
                                                      .text
                                                      .isEmpty &&
                                                  i > 0) {
                                                _otpFocusNodes[i - 1]
                                                    .requestFocus();
                                                return KeyEventResult.handled;
                                              }
                                              return KeyEventResult.ignored;
                                            },
                                            child: TextFormField(
                                              controller: _otpControllers[i],
                                              focusNode: _otpFocusNodes[i],
                                              textAlign: TextAlign.center,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                  1,
                                                ),
                                              ],
                                              style: AppTypography.titleLarge.copyWith(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: AppColors.border,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: AppColors
                                                                .border,
                                                            width: 1.5,
                                                          ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color:
                                                                AppColors.gold,
                                                            width: 1.5,
                                                          ),
                                                    ),
                                              ),
                                              onChanged: (v) =>
                                                  _onOtpChanged(i, v),
                                            ),
                                          ),
                                        );
                                        }),
                                      ),
                                    );
                                  },
                                ).animate().fadeIn(
                                  delay: 400.ms,
                                  duration: 400.ms,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                if (_errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 6,
                                      bottom: 12,
                                    ),
                                    child: Text(
                                      _errorMessage!,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.error,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ).animate().fadeIn(),
                                SizedBox(
                                  height: 54,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isVerifying
                                        ? null
                                        : _verifyAndSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.gold,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 4,
                                      shadowColor: AppColors.gold.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                    child: _isVerifying
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                            : Text(
                                                t.verifyPhone,
                                                style: AppTypography.titleLarge.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                  ),
                                ).animate().fadeIn(
                                  delay: 500.ms,
                                  duration: 400.ms,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                TextButton(
                                  onPressed: _resendEnabled ? _sendOtp : null,
                                  child: Text(
                                    _resendEnabled
                                        ? t.resendCode
                                        : t.resendIn(_resendSeconds.toString()),
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: _resendEnabled
                                          ? AppColors.gold
                                          : AppColors.textMuted,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ).animate().fadeIn(
                                  delay: 600.ms,
                                  duration: 400.ms,
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Future<void> _confirmBack() async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          t.phoneVerificationBackTitle,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          t.phoneVerificationBackConfirm,
          style: AppTypography.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              t.cancel,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              t.confirm,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.pop();
    }
  }
}
