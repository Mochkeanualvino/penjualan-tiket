import 'package:flutter/material.dart';
import '../services/auto_save_service.dart';
import '../utils/theme.dart';

/// Widget indikator visual real-time yang menunjukkan status simpan otomatis pada form.
class AutoSaveStatusIndicator extends StatelessWidget {
  final AutoSaveStatus status;
  final String? customMessage;

  const AutoSaveStatusIndicator({
    super.key,
    required this.status,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (status == AutoSaveStatus.idle) {
      return const SizedBox.shrink();
    }

    Widget content;
    Color bgColor;
    Color borderColor;

    switch (status) {
      case AutoSaveStatus.saving:
        bgColor = Colors.blue.shade900.withAlpha(80);
        borderColor = Colors.blueAccent;
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              customMessage ?? 'Menyimpan otomatis ke API & Local...',
              style: const TextStyle(fontSize: 12, color: Colors.lightBlueAccent),
            ),
          ],
        );
        break;

      case AutoSaveStatus.saved:
        bgColor = AppTheme.accentGreen.withAlpha(40);
        borderColor = AppTheme.accentGreen;
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.accentGreen),
            const SizedBox(width: 6),
            Text(
              customMessage ?? 'Tersimpan otomatis (API & Local)',
              style: const TextStyle(fontSize: 12, color: AppTheme.accentGreen, fontWeight: FontWeight.bold),
            ),
          ],
        );
        break;

      case AutoSaveStatus.error:
        bgColor = AppTheme.accentRed.withAlpha(40);
        borderColor = AppTheme.accentRed;
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 14, color: AppTheme.accentRed),
            const SizedBox(width: 6),
            Text(
              customMessage ?? 'Gagal menyimpan draft otomatis',
              style: const TextStyle(fontSize: 12, color: AppTheme.accentRed),
            ),
          ],
        );
        break;

      case AutoSaveStatus.idle:
      default:
        return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: content,
    );
  }
}
