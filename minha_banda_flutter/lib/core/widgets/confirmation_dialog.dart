import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

Future<bool?> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String content,
  String confirmLabel = 'Confirmar',
  String cancelLabel = 'Cancelar',
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.stageBlack2,
      title: Text(title, style: const TextStyle(color: AppColors.warmWhite)),
      content: Text(content, style: const TextStyle(color: AppColors.bodyText)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelLabel, style: const TextStyle(color: AppColors.bodyText)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmLabel, style: const TextStyle(color: AppColors.danger)),
        ),
      ],
    ),
  );
}
