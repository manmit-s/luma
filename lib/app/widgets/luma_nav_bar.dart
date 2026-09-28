import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum LumaTab { home, history, export, settings }

/// Premium floating glassmorphic dock:
/// Optical blur + translucent frosted gradient + light refraction border + ambient glow + center glowing FAB.
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
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              // Frosted multi-stop glass surface with specular gradient
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF221D30).withValues(alpha: 0.82),
                  const Color(0xFF161222).withValues(alpha: 0.90),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              // Frosted rim catching light
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.50),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.peach.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 2),
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
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 54, minHeight: 52),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.plum.withValues(alpha: 0.70)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: selected
                          ? AppColors.peach.withValues(alpha: 0.35)
                          : Colors.transparent,
                      width: 1,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.peach.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedScale(
                            scale: selected ? 1.08 : 1.0,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            child: Icon(
                              selected ? selectedIcon : icon,
                              size: 21,
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
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.peach.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                    ),
                                  ],
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
                          fontSize: 10,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          letterSpacing: 0.1,
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

class _CenterFab extends StatefulWidget {
  const _CenterFab({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_CenterFab> createState() => _CenterFabState();
}

class _CenterFabState extends State<_CenterFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Add expense',
        button: true,
        child: Tooltip(
          message: 'Add expense',
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: widget.onTap,
            child: AnimatedScale(
              scale: _pressed ? 0.92 : 1.0,
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOutCubic,
              child: Container(
                width: 52,
                height: 52,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFB894),
                      AppColors.peach,
                      Color(0xFFE2744B),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.40),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.peach.withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.add_rounded,
                  size: 27,
                  color: AppColors.onCta,
                ),
              ),
            ),
          ),
        ),
      );
}
