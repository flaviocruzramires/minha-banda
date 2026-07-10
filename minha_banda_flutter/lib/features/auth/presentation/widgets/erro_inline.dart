import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ErroInline extends StatelessWidget {
  const ErroInline({super.key, required this.mensagem});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        border: Border.all(color: AppColors.dangerBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              size: 16, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensagem,
              style: const TextStyle(fontSize: 12, color: Color(0xFFEF9F7A)),
            ),
          ),
        ],
      ),
    );
  }
}
