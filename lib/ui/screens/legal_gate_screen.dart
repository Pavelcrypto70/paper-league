import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/services/analytics.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:provider/provider.dart';

class LegalGateScreen extends StatefulWidget {
  const LegalGateScreen({super.key});

  @override
  State<LegalGateScreen> createState() => _LegalGateScreenState();
}

class _LegalGateScreenState extends State<LegalGateScreen> {
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: PlColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PAPER LEAGUE',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: PlColors.accent,
                      letterSpacing: 1.4,
                    ),
              ),
              const SizedBox(height: 8),
              Text(s.legalTitle, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PlColors.surface,
                    borderRadius: BorderRadius.circular(PlRadius.md),
                    border: Border.all(color: PlColors.lineSoft),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      s.legalBody,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                            color: PlColors.text,
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: checked,
                activeColor: PlColors.accent,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  s.acceptDisclaimer,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PlColors.text,
                      ),
                ),
                onChanged: (v) => setState(() => checked = v ?? false),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: checked
                      ? () async {
                          HapticFeedback.mediumImpact();
                          await Analytics.log('legal_accept');
                          if (!context.mounted) return;
                          await context.read<LocaleController>().acceptDisclaimer();
                        }
                      : null,
                  child: Text(s.enterDesk),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
