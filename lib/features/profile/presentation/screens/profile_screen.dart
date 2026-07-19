import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:elct/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/utils/error_formatter.dart';
import '../../../../core/providers/app_settings_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/services/notification_service.dart';
import 'package:elct/core/widgets/app_toast.dart';
import 'package:elct/features/profile/presentation/providers/profile_provider.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _appVersion = info.version);
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserIdProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final profile = uid == null ? null : ref.watch(userProfileProvider(uid)).valueOrNull;
    // Merge: prefer live authState data, fallback to Firestore profile cache
    final displayName = user?.displayName ?? (profile?['displayName'] as String?);
    final email = user?.email ?? (profile?['email'] as String?);
    final photoUrl = user?.photoUrl ?? (profile?['photoUrl'] as String?);
    final orderCount = ref.watch(ordersListProvider).valueOrNull?.length ?? 0;
    final wishlistCount = ref.watch(wishlistCountProvider);
    final appSettings = ref.watch(appSettingsProvider).valueOrNull ?? AppSettings();

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(displayName, email, photoUrl),
            const SizedBox(height: 24),
            _buildQuickActionsRow(orderCount, wishlistCount),
            const SizedBox(height: 16),
            
            // App Information Section
            _buildSectionTitle(l10n.appInfo),
            _buildRowItem(
              icon: Icons.security,
              iconColor: AppColors.success,
              iconBgColor: AppColors.success.withValues(alpha: 0.1),
              title: l10n.privacyPolicy,
              onTap: () => _showPrivacyPolicy(),
            ),
            _buildRowItem(
              icon: Icons.description,
              iconColor: const Color(0xFFFF9500),
              iconBgColor: const Color(0xFFFF9500).withValues(alpha: 0.1),
              title: AppLocalizations.of(context)!.terms,
              onTap: () => _showTermsAndConditions(),
            ),
            _buildRowItem(
              icon: Icons.assignment_return,
              iconColor: const Color(0xFF007AFF),
              iconBgColor: const Color(0xFF007AFF).withValues(alpha: 0.1),
              title: l10n.returnPolicy,
              onTap: () => _showReturnPolicy(),
            ),
            _buildRowItem(
              icon: Icons.language,
              iconColor: const Color(0xFF5856D6),
              iconBgColor: const Color(0xFF5856D6).withValues(alpha: 0.1),
              title: AppLocalizations.of(context)!.language,
              onTap: () => _switchLanguage(),
            ),
            _buildRowItem(
              icon: Icons.info_outline,
              iconColor: const Color(0xFF8E8E93),
              iconBgColor: const Color(0xFF8E8E93).withValues(alpha: 0.1),
              title: l10n.appVersion,
              trailingText: _appVersion,
              onTap: () {},
            ),

            // Contact Us Section
            _buildSectionTitle(l10n.contactUs),
            _buildRowItem(
              icon: Icons.phone_in_talk,
              iconColor: const Color(0xFF007AFF),
              iconBgColor: const Color(0xFF007AFF).withValues(alpha: 0.1),
              title: AppLocalizations.of(context)!.contactUs,
              onTap: () => _showContactUs(appSettings),
            ),

            // Social Media Section
            _buildSectionTitle(l10n.keepInTouch),
            _buildSocialSection(appSettings),

            // Danger Zone Section
            _buildSectionTitle(l10n.dangerZone),
            _buildRowItem(
              icon: Icons.delete_forever,
              iconColor: AppColors.error,
              iconBgColor: AppColors.error.withValues(alpha: 0.1),
              title: l10n.deleteAccountTitle,
              isDanger: true,
              onTap: () => _confirmDeleteAccount(),
            ),
            _buildRowItem(
              icon: Icons.logout,
              iconColor: AppColors.error,
              iconBgColor: AppColors.error.withValues(alpha: 0.1),
              title: AppLocalizations.of(context)!.logout,
              isDanger: true,
              onTap: () => _confirmLogout(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String? displayName, String? email, String? photoUrl) {
    final name = (displayName?.trim().isNotEmpty == true)
        ? displayName!
        : AppLocalizations.of(context)!.defaultUserName;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 60, AppSpacing.lg, 32),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Profile Image Circle
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: (photoUrl != null && photoUrl.isNotEmpty) ? photoUrl : '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => Transform.scale(
                    scale: 1.35,
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Name and Edit Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => context.push(Routes.editProfile),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: AppColors.surfaceDark, size: 14),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${AppLocalizations.of(context)!.welcomeUser} $name',
                style: AppTypography.titleLarge.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Email
          if (email != null && email.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  email,
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(width: 6),
                Icon(Icons.email_outlined, color: Colors.white.withValues(alpha: 0.7), size: 14),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow(int orders, int wishlist) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _buildQuickActionItem(
            icon: Icons.location_on,
            iconColor: AppColors.success,
            bgColor: AppColors.success.withValues(alpha: 0.08),
            label: l10n.address,
            onTap: () => context.push(Routes.addresses),
          ),
          const SizedBox(width: 12),
          _buildQuickActionItem(
            icon: Icons.favorite,
            iconColor: const Color(0xFFFF2D55),
            bgColor: const Color(0xFFFF2D55).withValues(alpha: 0.08),
            label: l10n.wishlistTitle,
            badgeCount: wishlist > 0 ? wishlist.toString() : null,
            onTap: () => context.push(Routes.wishlist),
          ),
          const SizedBox(width: 12),
          _buildQuickActionItem(
            icon: Icons.shopping_bag,
            iconColor: const Color(0xFF007AFF),
            bgColor: const Color(0xFF007AFF).withValues(alpha: 0.08),
            label: l10n.myOrders,
            badgeCount: orders > 0 ? orders.toString() : null,
            onTap: () => context.push(Routes.orders),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    String? badgeCount,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
              if (badgeCount != null)
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  top: -4,
                  end: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeCount,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 24, AppSpacing.lg, 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildRowItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.labelLarge.copyWith(color: isDanger ? AppColors.error : AppColors.textPrimary),
                  ),
                ),
                if (trailingText != null)
                  Text(
                    trailingText,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                  )
                else
                  Icon(
                    isRtl ? Icons.chevron_left : Icons.chevron_right,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialSection(AppSettings settings) {
    final socialLinks = [
      _SocialLink(FontAwesomeIcons.youtube, const Color(0xFFFF0000), settings.youtube),
      _SocialLink(FontAwesomeIcons.snapchat, const Color(0xFFFFFC00), settings.snapchat),
      _SocialLink(FontAwesomeIcons.tiktok, Colors.black, settings.tiktok),
      _SocialLink(FontAwesomeIcons.instagram, const Color(0xFFE1306C), settings.instagram),
      _SocialLink(FontAwesomeIcons.facebook, const Color(0xFF1877F2), settings.facebook),
      _SocialLink(FontAwesomeIcons.xTwitter, Colors.black, settings.twitter),
    ].where((link) => link.url.trim().isNotEmpty).toList();

    if (socialLinks.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1E293B),
              AppColors.surfaceDark,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: socialLinks
              .map(
                (link) => _buildSocialIcon(
                  fallbackIcon: link.icon,
                  iconColor: link.color,
                  url: link.url,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSocialIcon({
    required dynamic fallbackIcon,
    required Color iconColor,
    required String url,
  }) {
    return GestureDetector(
      onTap: () => _launchExternalUrl(url),
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: FaIcon(fallbackIcon, color: iconColor, size: 24),
        ),
      ),
    );
  }

  Future<void> _openLegalPage(String section) async {
    final uri = Uri.parse('https://privacy-policy-vtbf.vercel.app#$section');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } else if (mounted) {
      AppToast.show(context, AppLocalizations.of(context)!.errorPrefix(''), icon: Icons.error_outline);
    }
  }

  Future<void> _showPrivacyPolicy() => _openLegalPage('privacy');

  Future<void> _showTermsAndConditions() => _openLegalPage('terms');

  Future<void> _showReturnPolicy() => _openLegalPage('returns');

  void _showContactUs(AppSettings settings) {
    final l10n = AppLocalizations.of(context)!;
    final phone = settings.phone.trim();
    final whatsapp = settings.whatsapp.trim();
    final email = settings.email.trim();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.contactUs,
                style: AppTypography.titleLarge,
                textAlign: TextAlign.center,
              ),
              const Divider(height: 24),
              if (phone.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.phone, color: AppColors.gold),
                  title: Align(
                    alignment: Alignment.centerRight,
                    child: Text(phone, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  subtitle: Align(
                    alignment: Alignment.centerRight,
                    child: Text(l10n.customerServiceCall),
                  ),
                  onTap: () => _launchPhone(phone),
                ),
              if (whatsapp.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline, color: AppColors.success),
                  title: Align(
                    alignment: Alignment.centerRight,
                    child: Text(whatsapp, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  onTap: () => _launchWhatsapp(whatsapp),
                ),
              if (email.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.blue),
                  title: Align(
                    alignment: Alignment.centerRight,
                    child: Text(email, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  subtitle: Align(
                    alignment: Alignment.centerRight,
                    child: Text(l10n.emailSupport),
                  ),
                  onTap: () => _launchEmail(email),
                ),
              if (phone.isEmpty && whatsapp.isEmpty && email.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(l10n.comingSoon, style: const TextStyle(color: AppColors.textMuted)),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchExternalUrl(String rawUrl) async {
    final value = rawUrl.trim();
    if (value.isEmpty) return;
    final uri = Uri.tryParse(value.contains('://') ? value : 'https://$value');
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsapp(String value) async {
    final trimmed = value.trim();
    final uri = trimmed.startsWith('http')
        ? Uri.tryParse(trimmed)
        : Uri.tryParse('https://wa.me/${trimmed.replaceAll(RegExp(r'[^\d]'), '')}');
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _switchLanguage() {
    final current = ref.read(localeProvider).languageCode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)!.language,
          textAlign: TextAlign.center,
          style: AppTypography.labelLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.check_circle,
                color: current == 'ar' ? AppColors.gold : Colors.transparent,
              ),
              title: Text(
                AppLocalizations.of(context)!.arabic,
                style: AppTypography.labelLarge,
              ),
              subtitle: Text(AppLocalizations.of(context)!.arabicSubtitle,
                style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              onTap: () {
                Navigator.pop(ctx);
                if (current != 'ar') ref.read(localeProvider.notifier).setLocale('ar');
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.check_circle,
                color: current == 'en' ? AppColors.gold : Colors.transparent,
              ),
              title: Text(
                'English',
                style: AppTypography.labelLarge,
              ),
              subtitle: Text(AppLocalizations.of(context)!.englishSubtitle,
                style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              onTap: () {
                Navigator.pop(ctx);
                if (current != 'en') ref.read(localeProvider.notifier).setLocale('en');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(authRepositoryProvider);
    if (!mounted) return;
    if (!repo.hasGoogleProvider) {
      // Check auth user exists via regular repo method
      final uid = ref.read(currentUserIdProvider);
      if (uid == null) return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.deleteAccountTitle, style: AppTypography.labelLarge),
        content: Text(l10n.deleteAccountConfirm, style: AppTypography.bodyLarge),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel, style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.deleteLabel, style: AppTypography.bodyLarge.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final isGoogleUser = repo.hasGoogleProvider;
    String? password;

    if (isGoogleUser) {
      try {
        await repo.reauthenticateWithGoogle();
      } catch (_) {
        return;
      }
    } else {
      password = await _showPasswordDialog(l10n);
      if (password == null || password.isEmpty) return;
    }

    if (!context.mounted) return;
    // Capture the router before the async gap to avoid context issues
    final router = GoRouter.of(context);

    try {
      await repo.deleteCurrentUser(password: password);
      // Defer navigation to next microtask so the widget tree
      // finishes processing the auth state change first
      Future.microtask(() {
        router.go(Routes.login);
      });
    } catch (e) {
      if (!context.mounted) return;
      AppToast.show(context, userErrorMessage(e, l10n), icon: Icons.error_outline);
    }
  }

  Future<String?> _showPasswordDialog(AppLocalizations l10n) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PasswordDialog(l10n: l10n),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.of(context)!.logoutTitle, style: AppTypography.bodyLarge),
        content: Text(AppLocalizations.of(context)!.logoutConfirm, style: AppTypography.bodyLarge),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel, style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await NotificationService.instance.onUserLogout();
              await ref.read(authRepositoryProvider).signOut();
              if (mounted) context.go(Routes.home);
            },
            child: Text(AppLocalizations.of(context)!.logout, style: AppTypography.bodyLarge.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SocialLink {
  final dynamic icon;
  final Color color;
  final String url;

  const _SocialLink(this.icon, this.color, this.url);
}

class _PasswordDialog extends StatefulWidget {
  final AppLocalizations l10n;
  const _PasswordDialog({required this.l10n});

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.l10n.deleteAccountTitle, style: AppTypography.labelLarge),
      content: TextField(
        controller: _controller,
        obscureText: _obscure,
        autofocus: true,
        decoration: InputDecoration(
          labelText: widget.l10n.password,
          labelStyle: AppTypography.bodyLarge,
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, ''),
          child: Text(widget.l10n.cancel, style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(widget.l10n.confirm, style: AppTypography.bodyLarge.copyWith(color: AppColors.error)),
        ),
      ],
    );
  }
}
