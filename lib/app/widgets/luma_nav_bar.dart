import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum LumaTab { home, history, export, settings }

/// Premium floating pill dock: blur glass + pending badge + center Add FAB.
///
/// Single contained blur surface (dock only) — rest of app stays solid.
class LumaNavBar extends StatelessWidget {
  const LumaNavBar({
    super.key,
    required this.current,
    required this.onSelect,
    required this.pendingCount,
    required this.onAdd,
  });

  final LumaTab current;
  final ValueChanged<LumaTab> onSelect;
  final int pendingCount;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _NavItem(
                    tab: LumaTab.home,
                    label: 'Home',
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    selected: current == LumaTab.home,
                    badgeCount: pendingCount,
                    onTap: () => onSelect(LumaTab.home),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    tab: LumaTab.history,
                    label: 'History',
                    icon: Icons.receipt_long_outlined,
                    selectedIcon: Icons.receipt_long_rounded,
                    selected: current == LumaTab.history,
                    onTap: () => onSelect(LumaTab.history),
                  ),
                ),
                _CenterFab(onTap: onAdd),
                Expanded(
                  child: _NavItem(
                    tab: LumaTab.export,
                    label: 'Export',
                    icon: Icons.ios_share_outlined,
                    selectedIcon: Icons.ios_share_rounded,
                    selected: current == LumaTab.export,
                    onTap: () => onSelect(LumaTab.export),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    tab: LumaTab.settings,
                    label: 'Settings',
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings_rounded,
                    selected: current == LumaTab.settings,
                    onTap: () => onSelect(LumaTab.settings),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  // No haptics by design — silent tab switching.
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final LumaTab tab;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) => Semantics(
        label: label,
        selected: selected,
        button: true,
        child: Tooltip(
          message: label,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 56, minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.plum : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedScale(
                            scale: selected ? 1.05 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              selected ? selectedIcon : icon,
                              size: 22,
                              color: selected
                                  ? AppColors.peach
                                  : AppColors.textSecondary,
                            ),
                          ),
                          if (badgeCount > 0)
                            Positioned(
                              right: -10,
                              top: -6,
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.plum,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.peach,
                                    width: 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  badgeCount > 9 ? '9+' : '$badgeCount',
                                  style: const TextStyle(
                                    color: AppColors.peach,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          // Fixed size in both states: growing 10 → 11 on
                          // select widened the pill and overflowed labels
                          // like "Settings" in the 5-slot dock.
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.peach
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class _CenterFab extends StatelessWidget {
  const _CenterFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Add expense',
        button: true,
        child: Tooltip(
          message: 'Add expense',
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: onTap,
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.peach,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.add_rounded,
                size: 26,
                color: AppColors.onCta,
              ),
            ),
          ),
        ),
      );
}
