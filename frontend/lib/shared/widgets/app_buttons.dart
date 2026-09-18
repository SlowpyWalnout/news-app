import 'package:flutter/material.dart';

import '../../config/theme/app_dimensions.dart';
import '../../config/theme/app_palette.dart';

/// Filled accent CTA with an inline spinner while [loading].
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;
    final isEnabled = enabled && !loading;

    return SizedBox(
      width: double.infinity,
      height: dims.tap,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? scheme.primary : palette.line,
          disabledBackgroundColor: palette.line,
          foregroundColor: isEnabled ? scheme.onPrimary : palette.ink3,
          disabledForegroundColor: palette.ink3,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.r16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(scheme.onPrimary),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: dims.fLg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Outlined button on `edge` border — secondary actions like "Editar".
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;
    final isEnabled = !loading;

    final button = SizedBox(
      height: dims.tap,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
          disabledForegroundColor: palette.ink3,
          side: BorderSide(color: palette.edge, width: dims.borderWidth),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.r15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading) ...[
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(scheme.onSurface)),
              ),
              const SizedBox(width: 12),
            ] else if (icon != null) ...[
              icon!,
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: dims.fMd),
              ),
            ),
          ],
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Destructive-styled outlined button — "Borrar".
class DestructiveButton extends StatelessWidget {
  const DestructiveButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: dims.tap,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: palette.dangerSoft,
          foregroundColor: scheme.error,
          side: BorderSide(color: scheme.error, width: dims.borderWidth),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.r15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 10)],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: dims.fMd),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
