import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:elct/l10n/app_localizations.dart';
import 'package:elct/core/theme/app_colors.dart';
import 'package:elct/core/theme/app_typography.dart';
import 'package:elct/core/widgets/app_toast.dart';
import 'package:elct/features/auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../../../../core/utils/error_formatter.dart';

class CountryCode {
  final String name;
  final String code;
  final String flag;
  final String formatHint;
  final int maxLength;

  const CountryCode({
    required this.name,
    required this.code,
    required this.flag,
    required this.formatHint,
    required this.maxLength,
  });
}

const List<CountryCode> _countries = [
  CountryCode(name: 'الكويت', code: '+965', flag: '🇰🇼', formatHint: '3xx xxxxxxx', maxLength: 8),
  CountryCode(name: 'المملكة العربية السعودية', code: '+966', flag: '🇸🇦', formatHint: '5xxxxxxxx', maxLength: 9),
  CountryCode(name: 'الإمارات العربية المتحدة', code: '+971', flag: '🇦🇪', formatHint: '5xxxxxxxx', maxLength: 9),
  CountryCode(name: 'قطر', code: '+974', flag: '🇶🇦', formatHint: 'xxxxxxxx', maxLength: 8),
  CountryCode(name: 'البحرين', code: '+973', flag: '🇧🇭', formatHint: 'xxxxxxxx', maxLength: 8),
  CountryCode(name: 'عمان', code: '+968', flag: '🇴🇲', formatHint: 'xxxxxxxx', maxLength: 8),
  CountryCode(name: 'مصر', code: '+20', flag: '🇪🇬', formatHint: '1xxxxxxxxx', maxLength: 10),
];

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _isSaving = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  CountryCode _selectedCountry = _countries.first; // Kuwait default (+965)

  @override
  void initState() {
    super.initState();
    final userEntity = ref.read(authStateProvider).value;
    
    String firstName = userEntity?.firstName ?? '';
    String lastName = userEntity?.lastName ?? '';
    
    if (firstName.isEmpty && lastName.isEmpty) {
      final displayName = userEntity?.displayName ?? '';
      final parts = displayName.split(' ');
      if (parts.isNotEmpty) firstName = parts.first;
      if (parts.length > 1) lastName = parts.skip(1).join(' ');
    }

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _emailController = TextEditingController(text: userEntity?.email ?? '');
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _prefillPhone(userEntity?.phoneNumber);
  }

  void _prefillPhone(String? phone) {
    if (phone == null || phone.isEmpty) return;
    String normalizedPhone = phone;
    if (!normalizedPhone.startsWith('+') && normalizedPhone.startsWith('96')) {
      normalizedPhone = '+$normalizedPhone';
    } else if (!normalizedPhone.startsWith('+') && normalizedPhone.startsWith('20')) {
      normalizedPhone = '+$normalizedPhone';
    }
    bool codeFound = false;
    for (var country in _countries) {
      if (normalizedPhone.startsWith(country.code)) {
        _selectedCountry = country;
        _phoneController.text = normalizedPhone.substring(country.code.length);
        codeFound = true;
        break;
      }
    }
    if (!codeFound) {
      _phoneController.text = phone;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserIdProvider);
    final l10n = AppLocalizations.of(context)!;

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
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Clean large title instead of image header
                Text(
                  l10n.editProfile,
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: AppColors.textPrimary,
                  ),
                ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1),
                const SizedBox(height: 24),

                // ─── Section: Personal Info ───────────────────────────
                _buildSectionLabel(l10n.editPersonalInfo, Icons.person_outline)
                    .animate().fadeIn(duration: 300.ms).slideX(begin: 0.1),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildLuxuryField(
                        controller: _firstNameController,
                        label: l10n.firstName,
                        hint: '',
                        icon: Icons.badge_outlined,
                        delay: 100,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? l10n.required : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLuxuryField(
                        controller: _lastNameController,
                        label: l10n.lastName,
                        hint: '',
                        icon: Icons.badge_outlined,
                        delay: 100,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? l10n.required : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Luxury Phone Number Field with country dropdown
                _buildLuxuryPhoneField(l10n)
                    .animate(delay: 150.ms).fadeIn(duration: 300.ms).slideY(begin: 0.05),
                const SizedBox(height: 24),

                // ─── Section: Account ─────────────────────────────────
                _buildSectionLabel(l10n.accountData, Icons.lock_outline)
                    .animate(delay: 200.ms).fadeIn(duration: 300.ms).slideX(begin: 0.1),
                const SizedBox(height: 16),
                
                _buildLuxuryField(
                  controller: _emailController,
                  label: l10n.email,
                  hint: 'example@email.com',
                  icon: Icons.alternate_email,
                  keyboardType: TextInputType.emailAddress,
                  delay: 250,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.required;
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(v.trim())) {
                      return l10n.invalidEmailMessage;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                _buildLuxuryField(
                  controller: _passwordController,
                  label: l10n.password,
                  hint: l10n.leaveBlankHint,
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isObscured: _obscurePassword,
                  onToggleObscure: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  delay: 300,
                  validator: (v) {
                    if (v == null || v.isEmpty) return null; // optional
                    if (v.length < 6) return l10n.passwordMin6;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                _buildLuxuryField(
                  controller: _confirmPasswordController,
                  label: l10n.confirmPassword,
                  hint: l10n.retypePassword,
                  icon: Icons.lock_person_outlined,
                  isPassword: true,
                  isObscured: _obscureConfirm,
                  onToggleObscure: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  delay: 350,
                  validator: (v) {
                    if (_passwordController.text.isEmpty) return null;
                    if (v != _passwordController.text) {
                      return l10n.passwordMismatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 36),

                // ─── Save Button ──────────────────────────────────────
                _buildSaveButton(uid, l10n)
                    .animate(delay: 400.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),
                
                _buildCancelButton(l10n)
                    .animate(delay: 450.ms).fadeIn(duration: 300.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Section Label ────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.gold, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
        ),
        const Spacer(),
        Container(
          height: 1,
          width: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gold.withValues(alpha: 0.3), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Luxury Text Field ────────────────────────────────────────────────────
  Widget _buildLuxuryField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int delay = 0,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isObscured = true,
    VoidCallback? onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && isObscured,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTypography.labelLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTypography.bodyMedium,
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted.withValues(alpha: 0.7)),
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
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              )
            : null,
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
    ).animate(delay: Duration(milliseconds: delay)).fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }

  // ─── Custom Luxury Phone Field ────────────────────────────────────────────
  Widget _buildLuxuryPhoneField(AppLocalizations l10n) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(_selectedCountry.maxLength),
      ],
      validator: (v) {
        if (v == null || v.trim().isEmpty) return l10n.required;
        if (v.trim().length < _selectedCountry.maxLength) {
          return l10n.phoneTooShort(_selectedCountry.maxLength.toString());
        }
        return null;
      },
      style: AppTypography.labelLarge,
      decoration: InputDecoration(
        labelText: l10n.phoneNumber,
        hintText: _selectedCountry.formatHint,
        labelStyle: AppTypography.bodyMedium,
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted.withValues(alpha: 0.7)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        prefixIcon: IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showCountryPickerDialog(context),
                child: Row(
                  children: [
                    const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      _selectedCountry.flag,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selectedCountry.code,
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 24,
                color: AppColors.border,
              ),
              const SizedBox(width: 12),
            ],
          ),
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

  // Country Picker Modal Bottom Sheet
  void _showCountryPickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.selectCountryCode,
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final country = _countries[index];
                    final isSelected = country.code == _selectedCountry.code;
                    return ListTile(
                      leading: Text(
                        country.flag,
                        style: const TextStyle(fontSize: 22),
                      ),
                      title: Text(
                        country.name,
                        style: isSelected
                            ? AppTypography.labelLarge.copyWith(color: AppColors.gold)
                            : AppTypography.bodyLarge,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            country.code,
                            style: isSelected
                                ? AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.gold)
                                : AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            textDirection: TextDirection.ltr,
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.check_circle, color: AppColors.gold, size: 18),
                          ]
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCountry = country;
                          _phoneController.clear();
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Save Button ─────────────────────────────────────────────────────────
  Widget _buildSaveButton(String? uid, AppLocalizations l10n) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 54,
      decoration: BoxDecoration(
        gradient: _isSaving ? null : LinearGradient(
          colors: AppColors.goldGradient.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        color: _isSaving ? AppColors.border : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isSaving ? null : [
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
          onTap: _isSaving ? null : () => _save(uid),
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.gold,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.save_outlined, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.save,
                        style: AppTypography.titleLarge.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ─── Cancel Button ────────────────────────────────────────────────────────
  Widget _buildCancelButton(AppLocalizations l10n) {
    return TextButton(
      onPressed: () => context.pop(),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(
        l10n.cancel,
        style: AppTypography.labelLarge,
      ),
    );
  }

  // ─── Save Logic ───────────────────────────────────────────────────────────
  Future<void> _save(String? uid) async {
    if (uid == null) {
      AppToast.show(context, AppLocalizations.of(context)!.noUserLoggedIn, icon: Icons.error_outline);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    HapticFeedback.lightImpact();

    try {
      final newFirstName = _firstNameController.text.trim();
      final newLastName = _lastNameController.text.trim();
      final newFullName = '$newFirstName $newLastName';
      final newEmail = _emailController.text.trim();
      
      // Combine selected country code and phone digits
      final newPhone = '${_selectedCountry.code}${_phoneController.text.trim()}';
      final newPassword = _passwordController.text;
      final repo = ref.read(authRepositoryProvider);

      // 1. Update Firebase Auth display name
      await repo.updateDisplayName(newFullName);

      // 2. Update email in Firebase Auth
      final currentEmail = repo.currentUserEmail;
      if (currentEmail != newEmail) {
        await repo.verifyBeforeUpdateEmail(newEmail);
        if (mounted) {
          AppToast.show(
            context,
            AppLocalizations.of(context)!.emailVerificationSent,
            icon: Icons.mark_email_read_outlined,
          );
        }
      }

      // 3. Update password in Firebase Auth (optional)
      if (newPassword.isNotEmpty) {
        await repo.updatePassword(newPassword);
      }
      if (!mounted) return;

      // 4. Update Firestore profile document
      await repo.saveUserProfile(
        uid: uid,
        displayName: newFullName,
        firstName: newFirstName,
        lastName: newLastName,
        email: newEmail,
        phoneNumber: newPhone,
      );

      // 5. Invalidate cached profile
      ref.invalidate(userProfileProvider(uid));

      if (!mounted) return;
      AppToast.show(
        context,
        AppLocalizations.of(context)!.editProfileSuccess,
        icon: Icons.check_circle_outline,
      );
      context.pop();
    } on StateError catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      AppToast.show(context, userErrorMessage(e, l10n), icon: Icons.error_outline);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        AppLocalizations.of(context)!.unexpectedError,
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
