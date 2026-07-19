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
import '../../../../core/widgets/google_sign_in_button.dart';
import '../../../../core/widgets/apple_sign_in_button.dart';
import '../../../../core/providers/pending_redirect_provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/auth_provider.dart';
import 'package:elct/features/auth/utils/merge_guest_cart.dart';
import '../widgets/country_picker_widget.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  String? _errorMessage;
  String? _emailErrorOverride;
  bool _isCheckingEmail = false;
  bool _agreedToTerms = false;
  bool _termsError = false;
  CountryCode _selectedCountry = countries.first;
  Timer? _emailCheckTimer;

  @override
  void dispose() {
    _emailCheckTimer?.cancel();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_isLoading || _isGoogleLoading) return;

    if (!_formKey.currentState!.validate()) return;

    if (_isCheckingEmail) return;

    if (!_agreedToTerms) {
      setState(() => _termsError = true);
      HapticFeedback.lightImpact();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _termsError = false;
    });
    try {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final email = _emailController.text.trim();

      final phoneNumber =
          '${_selectedCountry.code}${_phoneController.text.trim()}';

      ref.read(registrationDataProvider.notifier).state = RegistrationData(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: _passwordController.text,
        phoneNumber: phoneNumber,
      );

      if (!mounted) return;
      final result = await context.push<bool>(Routes.phoneVerification);
      if (result == true && mounted) {
        context.pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      setState(() => _errorMessage = userErrorMessage(e, t));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      final user = await repo.signInWithGoogle();
      await mergeGuestCartAndNotify(ref, user.uid);
      if (!mounted) return;
      final pending = ref.read(pendingRedirectProvider);
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
    } catch (e) {
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      setState(() => _errorMessage = userErrorMessage(e, t));
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
      final user = await repo.signInWithApple();
      await mergeGuestCartAndNotify(ref, user.uid);
      if (!mounted) return;
      final pending = ref.read(pendingRedirectProvider);
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
    } catch (e) {
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      setState(() => _errorMessage = userErrorMessage(e, t));
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    ref.listen<String?>(registrationErrorProvider, (previous, next) {
      if (next == null || !mounted) return;
      setState(() => _errorMessage = userErrorMessage(StateError(next), t));
      ref.read(registrationErrorProvider.notifier).state = null;
    });

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
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.gold.withValues(alpha: 0.2),
                                    AppColors.gold.withValues(alpha: 0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_add_outlined,
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
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          t.registerTitle,
                          style: AppTypography.displayMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          t.registerSubtitle,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                        const SizedBox(height: AppSpacing.lg),

                        _buildLuxuryField(
                          controller: _firstNameController,
                          label: t.firstName,
                          icon: Icons.badge_outlined,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.givenName],
                          delay: 300,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return t.firstNameRequired;
                            }
                            if (v.trim().length < 2) {
                              return t.fullNameShort;
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                        const SizedBox(height: AppSpacing.md),

                        _buildLuxuryField(
                          controller: _lastNameController,
                          label: t.lastName,
                          icon: Icons.badge_outlined,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.familyName],
                          delay: 350,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return t.lastNameRequired;
                            }
                            if (v.trim().length < 2) {
                              return t.fullNameShort;
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
                        const SizedBox(height: AppSpacing.md),

                        _buildLuxuryPhoneField(
                          t,
                        ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
                        const SizedBox(height: AppSpacing.md),

                        _buildLuxuryField(
                          controller: _emailController,
                          label: t.email,
                          icon: Icons.alternate_email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          delay: 450,
                          onChanged: (value) {
                            _emailCheckTimer?.cancel();
                            if (_emailErrorOverride != null) {
                              setState(() => _emailErrorOverride = null);
                            }
                            final email = value.trim();
                            if (email.isEmpty ||
                                !RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(email)) {
                              setState(() => _isCheckingEmail = false);
                              return;
                            }
                            setState(() => _isCheckingEmail = true);
                            _emailCheckTimer = Timer(
                              const Duration(milliseconds: 500),
                              () async {
                                final exists = await ref
                                    .read(authRepositoryProvider)
                                    .checkEmailExists(email);
                                if (!mounted) return;
                                setState(() {
                                  _isCheckingEmail = false;
                                  if (exists) {
                                    _emailErrorOverride = AppLocalizations.of(
                                      context,
                                    )!.emailAlreadyInUse;
                                  }
                                });
                                _formKey.currentState?.validate();
                              },
                            );
                          },
                          validator: (v) {
                            if (_emailErrorOverride != null) {
                              return _emailErrorOverride;
                            }
                            if (v == null || v.trim().isEmpty) {
                              return t.emailRequired;
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(v.trim())) {
                              return t.emailInvalid;
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 450.ms, duration: 400.ms),
                        const SizedBox(height: AppSpacing.md),

                        _buildLuxuryField(
                          controller: _passwordController,
                          label: t.password,
                          icon: Icons.lock_outline,
                          isPassword: true,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          delay: 500,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return t.passwordRequired;
                            }
                            if (v.length < 8) {
                              return t.passwordMinLength;
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                        const SizedBox(height: AppSpacing.md),

                        _buildLuxuryField(
                          controller: _confirmPasswordController,
                          label: t.confirmPassword,
                          icon: Icons.lock_person_outlined,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          delay: 550,
                          validator: (v) {
                            if (v != _passwordController.text) {
                              return t.passwordMismatch;
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 550.ms, duration: 400.ms),
                        const SizedBox(height: AppSpacing.md),

                        _buildTermsCheckbox(
                          t,
                        ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _errorMessage!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),

                        _buildRegisterButton(
                          t,
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
                            label: t.signInWithApple,
                            isLoading: _isAppleLoading,
                            onPressed: _loginWithApple,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              t.haveAccount,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.replace(Routes.login),
                              child: Text(
                                t.login,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
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

  Widget _buildLuxuryField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int delay = 0,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Iterable<String>? autofillHints,
    bool isPassword = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      validator: validator,
      onChanged: onChanged,
      textDirection: keyboardType == TextInputType.emailAddress || isPassword
          ? TextDirection.ltr
          : Directionality.of(context),
      style: AppTypography.labelLarge,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.bodyMedium,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.gold, size: 18),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        errorStyle: AppTypography.badge,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }

  Widget _buildLuxuryPhoneField(AppLocalizations t) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.telephoneNumberNational],
      textDirection: TextDirection.ltr,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(_selectedCountry.maxLength),
      ],
      validator: (v) {
        if (v == null || v.trim().isEmpty) return t.phoneRequired;
        if (v.trim().length < _selectedCountry.maxLength) {
          return t.phoneTooShort(_selectedCountry.maxLength.toString());
        }
        return null;
      },
      style: AppTypography.labelLarge.copyWith(
        letterSpacing: 1.0,
      ),
      decoration: InputDecoration(
        labelText: t.phoneNumber,
        hintText: _selectedCountry.formatHint,
        labelStyle: AppTypography.bodyMedium,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textMuted.withValues(alpha: 0.7),
          letterSpacing: 1.0,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        prefixIcon: CountryPickerPrefix(
          selectedCountry: _selectedCountry,
          onTap: () => _showCountryPickerDialog(),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        errorStyle: AppTypography.badge,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }

  void _showCountryPickerDialog() {
    showCountryPickerDialog(
      context: context,
      selectedCountry: _selectedCountry,
      countries: countries,
      onCountrySelected: (country) {
        setState(() {
          _selectedCountry = country;
          _phoneController.clear();
        });
      },
    );
  }

  Widget _buildTermsCheckbox(AppLocalizations t) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _agreedToTerms,
                onChanged: (v) => setState(() {
                  _agreedToTerms = v ?? false;
                  if (_agreedToTerms) _termsError = false;
                }),
                activeColor: AppColors.gold,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: WidgetStateBorderSide.resolveWith((states) {
                  if (_termsError) {
                    return const BorderSide(color: AppColors.error, width: 1.5);
                  }
                  return BorderSide(
                    color: _agreedToTerms ? AppColors.gold : AppColors.border,
                  );
                }),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                text: TextSpan(
                  style: AppTypography.caption,
                  children: [
                    TextSpan(text: '${t.agreeToTerms} '),
                    TextSpan(
                      text: t.privacyPolicy,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: ' ${t.separatorAnd} '),
                    TextSpan(
                      text: t.termsAndConditions,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_termsError)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 6, start: 34),
            child: Text(
              t.agreeRequired,
              style: AppTypography.badge.copyWith(
                fontWeight: FontWeight.w400,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRegisterButton(AppLocalizations t) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 54,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _isLoading
            ? null
            : const LinearGradient(
                colors: [
                  AppColors.gold,
                  Color(0xFFC9A86A),
                  Color(0xFFB8943F),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: _isLoading ? AppColors.border : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isLoading
            ? null
            : [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _register,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.gold,
                    ),
                  )
                : Text(
                    t.createAccount,
                      style: AppTypography.bodyLargeBold.copyWith(fontSize: 13),
                  ),
          ),
        ),
      ),
    );
  }
}
