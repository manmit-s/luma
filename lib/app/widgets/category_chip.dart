import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme/app_theme.dart';
import 'category_icon.dart';

/// Single source of truth for category badges / selectable chips.
class CategoryChip extends ConsumerWidget {
  const CategoryChip({
    super.key,
    required this.label,
    this.selected = true,
    this.onSelected,
    this.compact = false,
    this.categoryId,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final bool compact;
  final String? categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.lumaPalette;
    final category = categoryId == null
        ? null
        : ref.watch(categoryControllerProvider).byId(categoryId);
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (category != null) ...[
          CategoryIcon(category: category, size: compact ? 14 : 16),
          const SizedBox(width: 5),
        ],
        Text(
          label,
          style: TextStyle(
            color: palette.chipSelectedText,
            fontSize: compact ? 11 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
    if (onSelected == null) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.sm : 10,
          vertical: compact ? AppSpacing.xs : 5,
        ),
        decoration: BoxDecoration(
          color: palette.chipSelectedBackground,
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        child: content,
      );
    }
    return ChoiceChip(
      label: content,
      selected: selected,
      onSelected: onSelected,
      selectedColor: palette.chipSelectedBackground,
      backgroundColor: palette.chipUnselectedBackground,
      side: BorderSide(color: palette.chipUnselectedBorder),
      labelStyle: TextStyle(
        color: selected ? palette.chipSelectedText : palette.chipUnselectedText,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}

/// Count badge used for "N Pending".
class CountBadge extends StatelessWidget {
  const CountBadge(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: palette.chipSelectedBackground,
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: palette.chipSelectedText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
