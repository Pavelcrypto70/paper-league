import 'package:flutter/material.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/l10n/s_path.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/beginner/path_kit.dart';
import 'package:provider/provider.dart';

/// Short glossary after 3 move copies — terms they’ll see in League/Recap.
class GlossaryTour extends StatelessWidget {
  const GlossaryTour({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final items = [
      (s.glTerm1, s.glDef1),
      (s.glTerm2, s.glDef2),
      (s.glTerm3, s.glDef3),
      (s.glTerm4, s.glDef4),
      (s.glTerm5, s.glDef5),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Text(s.glCap, style: pathCapStyle.copyWith(color: PlColors.accent)),
        const SizedBox(height: 8),
        Text(s.glTitle, style: pathTitleStyle(context)),
        const SizedBox(height: 8),
        Text(s.glBody, style: pathSubStyle),
        const SizedBox(height: 16),
        for (final (term, def) in items) ...[
          PathCard(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(term, style: pathMono(size: 13, weight: FontWeight.w700, color: PlColors.accent)),
                const SizedBox(height: 4),
                Text(def, style: const TextStyle(fontSize: 15, height: 1.4, color: PathInk.body)),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        PathButton(
          s.glCta,
          trailingIcon: Icons.arrow_forward_rounded,
          pulse: true,
          onPressed: () async {
            pathTap(strong: true);
            await context.read<DeskController>().markGlossarySeen();
          },
        ),
      ],
    );
  }
}
