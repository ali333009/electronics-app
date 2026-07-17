import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/router/routes.dart';
import '../providers/auth_provider.dart';

class ResetPasswordPhoneScreen extends ConsumerStatefulWidget {
  const ResetPasswordPhoneScreen({super.key});

  @override
  ConsumerState<ResetPasswordPhoneScreen> createState() =>
      _ResetPasswordPhoneScreenState();
}

class _ResetPasswordPhoneScreenState
    extends ConsumerState<ResetPasswordPhoneScreen> {
  final _phoneController = TextEditingController();
  final _countryCodeController = TextEditingController(text: '+20');
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _countryCodeController.dispose();
    super.dispose();
  }

  String get _fullPhone =>
      '${_countryCodeController.text.trim()}${_phoneController.text.trim()}';

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

  String _mapError(String code) {
    switch (code) {
      case 'INVALID_PHONE':
        return 'رقم الهاتف غير صحيح. تأكد من كود الدولة والرقم.';
      case 'TOO_MANY_ATTEMPTS':
        return 'محاولات كثيرة جداً. حاول لاحقاً.';
      case 'NETWORK_ERROR':
        return 'خطأ في الاتصال بالإنترنت.';
      default:
        return 'حدث خطأ. تأكد من الرقم وحاول مجدداً.';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'إعادة تعيين كلمة المرور',
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: AppSpacing.sm),

                // Subtitle
                Text(
                  'أدخل رقم هاتفك المسجل لتلقي رمز التحقق',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: AppSpacing.xxl),

                // Phone field
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Country code
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        controller: _countryCodeController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[+\d]')),
                          LengthLimitingTextInputFormatter(5),
                        ],
                        style: AppTypography.bodyLarge,
                        decoration: InputDecoration(
                          labelText: 'كود',
                          filled: true,
                          fillColor: Colors.white,
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
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Phone number
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15),
                        ],
                        style: AppTypography.bodyLarge,
                        decoration: InputDecoration(
                          labelText: 'رقم الهاتف',
                          hintText: '01XXXXXXXXX',
                          filled: true,
                          fillColor: Colors.white,
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
                          if (v == null || v.trim().length < 9) {
                            return 'أدخل رقم هاتف صحيح';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
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
                  text: 'إرسال رمز التحقق',
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
