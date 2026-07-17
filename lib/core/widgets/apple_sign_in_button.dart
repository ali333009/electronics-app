import 'package:flutter/material.dart';
import 'package:elct/core/theme/app_typography.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String label;

  const AppleSignInButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(FontAwesomeIcons.apple, size: 24, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: AppTypography.bodyLargeBold.copyWith(color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
}
