import 'package:flutter/material.dart';

import '../../config/theme/app_dimensions.dart';
import '../../config/theme/app_palette.dart';

enum BannerVariant { danger, warn }

/// Title+body banner for credential/network/permission notices.
class InlineBanner extends StatelessWidget {
  const InlineBanner({
    super.key,
    required this.title,
    required this.body,
    this.variant = BannerVariant.danger,
  });

  final String title;
  final String body;
  final BannerVariant variant;

  @override
  Widget build(BuildContext context) {
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;

    final isDanger = variant == BannerVariant.danger;
    final borderColor = isDanger ? scheme.error : palette.warn;
    final bgColor = isDanger ? palette.dangerSoft : palette.warnSoft;
    final textColor = isDanger ? scheme.error : palette.warn;

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: dims.borderWidth),
          borderRadius: BorderRadius.circular(AppRadii.r16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: dims.fMd, color: isDanger ? textColor : scheme.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              style: TextStyle(fontSize: dims.fSm, height: 1.5, color: palette.ink2),
            ),
          ],
        ),
      ),
    );
  }
}
