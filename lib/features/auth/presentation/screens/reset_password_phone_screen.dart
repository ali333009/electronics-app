import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:elct/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/router/routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/country_picker_widget.dart';

class ResetPasswordPhoneScreen extends ConsumerStatefulWidget {
  const ResetPasswordPhoneScreen({super.key});

  @override
  ConsumerState<ResetPasswordPhoneScreen> createState() =>
      _ResetPasswordPhoneScreenState();
}

class _ResetPasswordPhoneScreenState
    extends ConsumerState<ResetPasswordPhoneScreen> {
  final _phoneController = TextEditingController();
  CountryCode _selectedCountry = countries.first;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _fullPhone =>
      '${_selectedCountry.code}${_phoneController.text.trim()}';

  Future<void> _sendOtp() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = ref.read(authRepositoryProvider);
    repo.sendOtp(
      phoneNumber: _fullPhone,
      onCodeSent: (verificationId, _) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        context.push(Routes.resetPasswordOtp, extra: {
          'verificationId': verificationId,
          'phone': _fullPhone,
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = _mapError(error);
        });
      },
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
        });
      },
    );
  }

  String _mapError(String code) {
    final l10n = AppLocalizations.of(context)!;
    switch (code) {
      case 'INVALID_PHONE':
        return l10n.invalidPhoneNumber;
      case 'TOO_MANY_ATTEMPTS':
        return l10n.tooManyRequests;
      case 'NETWORK_ERROR':
        return l10n.connectionError;
      default:
        return l10n.genericError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.xl),
                // Icon
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
                  child: const Icon(
                    Icons.lock_reset_outlined,
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

                // Title
                Text(
                  l10n.setNewPassword,
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: AppSpacing.sm),

                // Subtitle
                Text(
                  l10n.phoneLoginSubtitle,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: AppSpacing.xxl),

                // Phone field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                  ],
                  style: AppTypography.bodyLarge,
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumber,
                    hintText: '01XXXXXXXXX',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: CountryPickerPrefix(
                      selectedCountry: _selectedCountry,
                      onTap: _showCountryPickerDialog,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: AppColors.border, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: AppColors.border, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: AppColors.gold, width: 1.5),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 8) {
                      return l10n.enterValidPhone;
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                const SizedBox(height: AppSpacing.sm),

                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 4),
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(),

                const SizedBox(height: AppSpacing.xl),

                // Send OTP button
                AppButton(
                  text: l10n.sendVerificationCode,
                  isLoading: _isLoading,
                  onPressed: _sendOtp,
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
