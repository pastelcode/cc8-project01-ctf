import 'package:flutter/material.dart';

/// A large tap button for flag capture / steal interactions.
///
/// Displays a red circle with an "E" label and fires [onPressed] on tap.
class InteractButton extends StatelessWidget {
  /// Called when the user taps the button.
  final VoidCallback? onPressed;

  const InteractButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFF4444).withValues(alpha: 0.8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 3,
          ),
        ),
        child: const Center(
          child: Text(
            'E',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
