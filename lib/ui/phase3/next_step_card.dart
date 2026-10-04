import 'package:flutter/material.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/l10n/s_path.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/beginner/path_kit.dart';
import 'package:paper_league/ui/phase2/move1_flow.dart';
import 'package:paper_league/ui/screens/tape_drill_screen.dart';
import 'package:provider/provider.dart';

/// Always-visible “tap this next” on the free terminal.
class NextStepCard extends StatelessWidget {
  const NextStepCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final desk = context.watch<DeskController>();
    if (!desk.fullTerminalUnlocked) return const SizedBox.shrink();

    final kind = desk.nextStepKind;
    final (title, body, cta) = switch (kind) {
      0 => (s.nsDailyTitle, s.nsDailyBody, s.nsDailyCta),
      1 => (s.nsLeagueTitle, s.nsLeagueBody, s.nsLeagueCta),
      2 => (s.nsShortTitle, s.nsShortBody, s.nsShortCta),
      3 => (s.nsDrillTitle, s.nsDrillBody, s.nsDrillCta),
      4 => (s.nsSeasonTitle, s.nsSeasonBody, s.nsSeasonCta),
      _ => (s.nsDoneTitle, s.nsDoneBody, s.nsDoneCta),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(PlSpace.lg, 8, PlSpace.lg, 0),
      child: PathCard(
        accent: kind != 5,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.nsCap, style: pathCapStyle.copyWith(color: PlColors.accent)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(body, style: const TextStyle(fontSize: 13, height: 1.35, color: PlColors.muted)),
            const SizedBox(height: 10),
            PathButton(
              cta,
              height: 44,
              trailingIcon: Icons.arrow_forward_rounded,
              pulse: kind != 5,
              onPressed: () => _act(context, desk, kind),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _act(BuildContext context, DeskController desk, int kind) async {
    pathTap(strong: true);
    switch (kind) {
      case 0:
        // Daily strip is above — nudge focus: scroll not available; flash via snackbar tip.
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).nsDailyHint)));
      case 1:
        desk.requestShellTab(2);
      case 2:
        await openMove1Flow(context, short: true);
      case 3:
        if (!context.mounted) return;
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(builder: (_) => const TapeDrillScreen()),
        );
      case 4:
        desk.requestShellTab(2);
      default:
        desk.requestShellTab(2);
    }
  }
}
