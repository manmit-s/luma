import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/utils/format.dart';

/// Large, dominant expense amount (SPEC 45.2).
class AmountDisplay extends StatelessWidget {
  const AmountDisplay(this.minor, {super.key, this.fontSize = 32, this.color});

  final int minor;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
        formatAmount(minor),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: color ?? AppColors.textPrimary,
        ),
      );
}
