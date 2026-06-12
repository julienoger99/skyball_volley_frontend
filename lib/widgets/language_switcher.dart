import 'package:flutter/material.dart';
import '../locale_notifier.dart';
import '../theme/app_theme.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  static const _labels = {'fr': 'FR', 'en': 'EN', 'pt': 'PT'};

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (_, current, _) {
        final code = current.languageCode;
        return PopupMenuButton<Locale>(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          offset: const Offset(0, 36),
          onSelected: localeNotifier.setLocale,
          itemBuilder: (_) => LocaleNotifier.supported
              .where((l) => l.languageCode != code)
              .map((locale) => PopupMenuItem(
                    value: locale,
                    child: Text(
                      _labels[locale.languageCode] ?? locale.languageCode,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ))
              .toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _labels[code] ?? code.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 14),
              ],
            ),
          ),
        );
      },
    );
  }
}
