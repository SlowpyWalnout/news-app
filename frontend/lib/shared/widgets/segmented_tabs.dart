import 'package:flutter/material.dart';

import '../../config/theme/app_dimensions.dart';

class SegmentedTabItem {
  const SegmentedTabItem({required this.label, required this.value});
  final String label;
  final String value;
}

/// Three-way (or n-way) segmented control, e.g. Todas/Borradores/Publicados.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final List<SegmentedTabItem> items;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.r14),
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _Segment(
                  item: item,
                  active: item.value == selected,
                  dims: dims,
                  onTap: () => onSelected(item.value),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.item, required this.active, required this.dims, required this.onTap});

  final SegmentedTabItem item;
  final bool active;
  final AppDimensions dims;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      excludeSemantics: true,
      child: Material(
        color: active ? scheme.onSurface : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.r11),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.r11),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            child: Text(
              item.label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: dims.fXs,
                color: active ? scheme.surface : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
