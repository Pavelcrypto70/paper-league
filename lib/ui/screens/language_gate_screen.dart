import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/theme/tokens.dart';

/// The first visible product screen. It deliberately uses native language
/// names so a user never has to understand an already-selected locale.
class LanguageGateScreen extends StatelessWidget {
  const LanguageGateScreen({super.key, required this.onPick});

  final Future<void> Function(AppLang language) onPick;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: PlColors.accentDim,
                  border: Border.all(color: PlColors.line),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PAPER LEAGUE · SEASON 28D',
                  style: TextStyle(
                    color: PlColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Choose your language',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Elige tu idioma · Escolha seu idioma · Выберите язык',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              for (final language in AppLang.values) ...[
                _LanguageOption(
                  language: language,
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    await onPick(language);
                  },
                ),
                const SizedBox(height: 10),
              ],
              const Spacer(),
              const Text(
                'You can change this later in Profile.',
                style: TextStyle(color: PlColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({required this.language, required this.onTap});

  final AppLang language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = switch (language) {
      AppLang.en => 'English',
      AppLang.es => 'Latinoamérica',
      AppLang.pt => 'Brasil',
      AppLang.ru => 'Русский',
    };
    return Material(
      color: PlColors.surface,
      borderRadius: BorderRadius.circular(PlRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PlRadius.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: PlColors.line),
            borderRadius: BorderRadius.circular(PlRadius.md),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.nativeLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: PlColors.accent),
            ],
          ),
        ),
      ),
    );
  }
}
