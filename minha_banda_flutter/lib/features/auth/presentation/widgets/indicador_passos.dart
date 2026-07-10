import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class IndicadorPassos extends StatelessWidget {
  const IndicadorPassos({
    super.key,
    required this.total,
    required this.atual,
  });

  final int total;
  final int atual;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isDone = i < atual - 1;
        final isActive = i == atual - 1;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.spotlight
                  : isActive
                      ? AppColors.spotlight.withValues(alpha: 0.5)
                      : AppColors.inputBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
