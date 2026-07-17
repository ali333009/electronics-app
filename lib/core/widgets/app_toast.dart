import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppToast {
  static void show(BuildContext context, String message, {IconData? icon}) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final entry = OverlayEntry(
      builder: (_) => _AppToastWidget(
        message: message,
        icon: icon,
        bottomInset: bottomInset,
      ),
    );
    Overlay.of(context).insert(entry);
    Future.delayed(const Duration(seconds: 2), entry.remove);
  }
}

class _AppToastWidget extends StatefulWidget {
  final String message;
  final IconData? icon;
  final double bottomInset;
  const _AppToastWidget({
    required this.message,
    this.icon,
    required this.bottomInset,
  });

  @override
  State<_AppToastWidget> createState() => _AppToastWidgetState();
}

class _AppToastWidgetState extends State<_AppToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = widget.bottomInset + 80;
    return Positioned(
      bottom: bottom,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _controller,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: AppColors.gold, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child:                     Text(widget.message,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textWhite)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
