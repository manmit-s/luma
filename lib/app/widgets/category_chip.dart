import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Single source of truth for category badges / selectable chips.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    this.selected = true,
    this.onSelected,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (onSelected == null) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.sm : 10,
          vertical: compact ? AppSpacing.xs : 5,
        ),
        decoration: BoxDecoration(
          color: AppColors.plum,
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.peach,
            fontSize: compact ? 11 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.plum,
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.border),
      labelStyle: TextStyle(
        color: selected ? AppColors.peach : AppColors.textSecondary,
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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.plum,
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.peach,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
