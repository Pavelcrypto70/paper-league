import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paper_league/config/app_links.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/l10n/s_path.dart';
import 'package:paper_league/services/analytics.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/beginner/path_kit.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalGateScreen extends StatefulWidget {
  const LegalGateScreen({super.key});

  @override
  State<LegalGateScreen> createState() => _LegalGateScreenState();
}

class _LegalGateScreenState extends State<LegalGateScreen> {
  final _checked = [false, false, false];

  bool get _ready => _checked.every((c) => c);

  Future<void> _accept() async {
    HapticFeedback.mediumImpact();
    await Analytics.log('legal_accept');
    if (!mounted) return;
    await context.read<LocaleController>().acceptDisclaimer();
  }

  Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final rules = [s.legalRule1, s.legalRule2, s.legalRule3];
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
                      const SizedBox(height: 12),
                      const Icon(Icons.shield_outlined, size: 56, color: PlColors.accent),
                      const SizedBox(height: 14),
                      Text(s.legalStartTitle, textAlign: TextAlign.center, style: pathTitleStyle(context)),
                      const SizedBox(height: 6),
                      Text(s.legalStartSub, textAlign: TextAlign.center, style: pathSubStyle),
                      const SizedBox(height: 20),
                      for (var i = 0; i < rules.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        _RuleRow(
                          text: rules[i],
                          checked: _checked[i],
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _checked[i] = !_checked[i]);
                          },
                        ),
                      ],
                      const SizedBox(height: 12),
                      AnimatedOpacity(
                        duration: PlMotion.micro,
                        opacity: _ready ? 0 : 1,
                        child: Text(s.legalTapHint, textAlign: TextAlign.center, style: pathFineStyle),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PathButton(s.legalAcceptCta, onPressed: _ready ? _accept : null),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Link(label: s.legalTerms, onTap: () => _open(AppLinks.termsUrl)),
                  const Text('  ·  ', style: pathFineStyle),
                  _Link(label: s.legalPrivacy, onTap: () => _open(AppLinks.privacyUrl)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.text, required this.checked, required this.onTap});

  final String text;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: PlMotion.micro,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: PlColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: checked ? PathInk.accentLine : PlColors.lineSoft),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: PlMotion.micro,
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: checked ? PlColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: checked ? PlColors.accent : PlColors.line, width: 1.5),
                ),
                child: checked ? const Icon(Icons.check_rounded, size: 16, color: PlColors.onAccent) : null,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(text, style: const TextStyle(fontSize: 15, height: 1.45, color: PathInk.body)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: pathFineStyle.copyWith(decoration: TextDecoration.underline, decorationColor: PlColors.faint),
      ),
    );
  }
}
