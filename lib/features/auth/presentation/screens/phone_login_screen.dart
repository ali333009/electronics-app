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

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, String>> _countries = [
    {'code': '+965', 'name': 'الكويت', 'flag': '🇰🇼'},
    {'code': '+966', 'name': 'السعودية', 'flag': '🇸🇦'},
    {'code': '+971', 'name': 'الإمارات', 'flag': '🇦🇪'},
    {'code': '+973', 'name': 'البحرين', 'flag': '🇧🇭'},
    {'code': '+974', 'name': 'قطر', 'flag': '🇶🇦'},
    {'code': '+968', 'name': 'عمان', 'flag': '🇴🇲'},
    {'code': '+20', 'name': 'مصر', 'flag': '🇪🇬'},
    {'code': '+964', 'name': 'العراق', 'flag': '🇮🇶'},
    {'code': '+1', 'name': 'أمريكا', 'flag': '🇺🇸'},
  ];
  String _selectedCountryCode = '+965';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    String phone = _phoneController.text.trim();
    // إزالة الأصفار في البداية إن وجدت حتى لا تتكرر مع الكود
    phone = phone.replaceAll(RegExp(r'^0+'), '');
    String fullPhone = '$_selectedCountryCode$phone';
    
    // Navigate to OTP screen
    _navigateAndHandleResult(fullPhone);
  }

  Future<void> _navigateAndHandleResult(String fullPhone) async {
    final result = await context.push<bool>(Routes.phoneVerification, extra: fullPhone);
    if (result == true && mounted) {
      context.pop(true);
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'تسجيل الدخول برقم الهاتف',
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'أدخل رقم هاتفك لتصلك رسالة التفعيل',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: AppSpacing.xxl),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 54, // Same height as AppTextField approximately
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountryCode,
                            icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                            items: _countries.map((c) {
                              return DropdownMenuItem<String>(
                                value: c['code'],
                                child: Text(
                                  '${c['flag']} ${c['code']}',
                                  style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                                  textDirection: TextDirection.ltr,
                                ),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedCountryCode = v);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppTextField(
                          controller: _phoneController,
                          label: 'رقم الهاتف',
                          hint: 'مثال: 66123456',
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.isEmpty) return t.phoneRequired;
                            if (v.length < 7) return t.phoneInvalid;
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  height: 56,
                  child: AppButton(
                    text: 'متابعة',
                    onPressed: _submit,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
