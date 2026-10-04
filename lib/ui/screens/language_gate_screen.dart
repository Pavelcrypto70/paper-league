import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/beginner/path_kit.dart';

/// The first visible product screen. It deliberately uses native language
/// names so a user never has to understand an already-selected locale.
class LanguageGateScreen extends StatefulWidget {
  const LanguageGateScreen({super.key, required this.onPick});

  final Future<void> Function(AppLang language) onPick;

  @override
  State<LanguageGateScreen> createState() => _LanguageGateScreenState();
}

class _LanguageGateScreenState extends State<LanguageGateScreen> {
  late AppLang _lang = AppLang.fromCode(
    WidgetsBinding.instance.platformDispatcher.locale.languageCode,
  );
  bool _busy = false;

  String get _continue => switch (_lang) {
        AppLang.en => 'Continue',
        AppLang.es => 'Continuar',
        AppLang.pt => 'Continuar',
        AppLang.ru => 'Продолжить',
      };

  Future<void> _go() async {
    if (_busy) return;
    setState(() => _busy = true);
    HapticFeedback.mediumImpact();
    await widget.onPick(_lang);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: PlColors.accentDim,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: PathInk.accentLine),
                          ),
                          child: Text('PL', style: pathMono(size: 26, weight: FontWeight.w700, color: PlColors.accent)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Choose your language',
                        textAlign: TextAlign.center,
                        style: pathTitleStyle(context),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Elige tu idioma · Escolha seu idioma · Выберите язык',
                        textAlign: TextAlign.center,
                        style: pathSubStyle,
                      ),
                      const SizedBox(height: 22),
                      for (final language in AppLang.values) ...[
                        _LanguageOption(
                          language: language,
                          selected: language == _lang,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _lang = language);
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PathButton(_continue, onPressed: _busy ? null : _go),
              const SizedBox(height: 10),
              const Text(
                'You can change this later in Profile.',
                textAlign: TextAlign.center,
                style: pathFineStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({required this.language, required this.selected, required this.onTap});

  final AppLang language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: PlMotion.micro,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? PlColors.accentDim : PlColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? PlColors.accent : PlColors.lineSoft),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: PlMotion.micro,
                width: 38,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? PlColors.accent : PlColors.surface2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  language.name.toUpperCase(),
                  style: pathMono(
                    size: 13,
                    weight: FontWeight.w700,
                    color: selected ? PlColors.onAccent : PlColors.muted,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  language.nativeLabel,
                  style: const TextStyle(fontSize: 17, color: PlColors.text),
                ),
              ),
              if (selected) const Icon(Icons.check_rounded, color: PlColors.accent, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
