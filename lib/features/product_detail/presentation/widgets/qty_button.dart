import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool disabled;

  const QtyButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        icon: Icon(
          icon,
          color: disabled
              ? AppColors.textMuted.withValues(alpha: 0.4)
              : Colors.black,
          size: 18,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: 18,
      ),
    );
  }
}
