import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool secondary;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondary = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    const textStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);

    final Widget child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: secondary ? scheme.primary : scheme.onPrimary,
            ),
          )
        : Text(label);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: secondary
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.primary,
                side: BorderSide(color: scheme.primary, width: 1.5),
                shape: shape,
                textStyle: textStyle,
              ),
              child: child,
            )
          : FilledButton(
              onPressed: isLoading ? null : onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                disabledBackgroundColor: scheme.primary.withAlpha(140),
                shape: shape,
                textStyle: textStyle,
              ),
              child: child,
            ),
    );
  }
}
