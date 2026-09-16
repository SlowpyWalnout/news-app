import 'package:flutter/material.dart';

import '../../config/theme/app_dimensions.dart';
import '../../config/theme/app_palette.dart';

/// Text input matching the prototype's field recipe: `--tap` min height,
/// 15px radius, full-ink border, and an optional error/counter footer.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.errorText,
    this.counterText,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    this.fontFamily = 'Figtree',
  });

  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final String? errorText;
  final String? counterText;
  final bool obscureText;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String fontFamily;

  @override
  Widget build(BuildContext context) {
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final palette = context.palette;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: dims.fSm,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: dims.tap),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            maxLines: obscureText ? 1 : maxLines,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.w500,
              fontSize: dims.fMd,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              filled: true,
              fillColor: hasError ? palette.dangerSoft : Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.r15),
                borderSide: BorderSide(
                  color: hasError ? Theme.of(context).colorScheme.error : palette.edge,
                  width: dims.borderWidth,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.r15),
                borderSide: BorderSide(
                  color: hasError ? Theme.of(context).colorScheme.error : palette.edge,
                  width: dims.borderWidth,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.r15),
                borderSide: BorderSide(
                  color: hasError ? Theme.of(context).colorScheme.error : palette.edge,
                  width: dims.borderWidth,
                ),
              ),
            ),
          ),
        ),
        if (hasError || counterText != null) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (hasError)
                Expanded(
                  child: Text(
                    errorText!,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: dims.fSm,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                )
              else
                const Spacer(),
              if (counterText != null)
                Text(
                  counterText!,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                    color: palette.ink3,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
