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
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    const borderRadius = BorderRadius.all(Radius.circular(32));

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          // Soft ambient drop shadow for floating elevation
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 28,
            offset: const Offset(0, 10),
            spreadRadius: -2,
          ),
          // Subtle theme-accented glow echoing brand tones under the dock
          BoxShadow(
            color: (palette.id == LumaThemeId.lumaOriginal
                    ? const Color(0xFF542A52)
                    : palette.primaryAccent)
                .withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 3),
          ),
          // Sharp ground contact shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              // Blurry translucent frosted glass in the app's palette
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 1.0],
                colors: palette.id == LumaThemeId.lumaOriginal
                    ? [
                        // Subtle specular top reflection
                        const Color(0xFF352648).withValues(alpha: 0.38),
                        // See-through translucent core letting underlying content blur through
                        const Color(0xFF1B1527).withValues(alpha: 0.26),
                        // Grounded base
                        const Color(0xFF140E20).withValues(alpha: 0.36),
                      ]
                    : [
                        Color.lerp(palette.elevated, Colors.white, 0.18)!
                            .withValues(alpha: 0.38),
                        palette.elevated.withValues(alpha: 0.26),
                        palette.background.withValues(alpha: 0.36),
                      ],
              ),
              // Frosted rim catching light
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.24),
                width: 1.2,
              ),
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
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    return Semantics(
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  gradient: selected
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.lerp(
                              palette.navIndicatorBackground,
                              Colors.white,
                              0.08,
                            )!,
                            palette.navIndicatorBackground,
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: selected
                        ? palette.navIndicatorBorder
                        : Colors.transparent,
                    width: 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: palette.primaryAccent.withValues(
                              alpha: palette.id == LumaThemeId.lumaOriginal
                                  ? 0.14
                                  : 0.08,
                            ),
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
                                ? palette.primaryAccent
                                : palette.textSecondary,
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
                                color: palette.chipSelectedBackground,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: palette.primaryAccent,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: palette.primaryAccent.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                badgeCount > 9 ? '9+' : '$badgeCount',
                                style: TextStyle(
                                  color: palette.chipSelectedText,
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
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        letterSpacing: 0.1,
                        color: selected
                            ? palette.primaryAccent
                            : palette.textSecondary,
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
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    return Semantics(
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: palette.id == LumaThemeId.lumaOriginal
                      ? const [
                          Color(0xFFFFB894),
                          Color(0xFFFF9E79),
                          Color(0xFFE2744B),
                        ]
                      : [
                          Color.lerp(
                                palette.primaryAccent,
                                Colors.white,
                                0.18,
                              ) ??
                              palette.primaryAccent,
                          palette.primaryAccent,
                          Color.lerp(
                                palette.primaryAccent,
                                Colors.black,
                                0.18,
                              ) ??
                              palette.primaryAccent,
                        ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.40),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: palette.primaryAccent.withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.add_rounded,
                size: 27,
                color: palette.onPrimaryAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
