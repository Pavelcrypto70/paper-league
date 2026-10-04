import 'package:flutter/material.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/l10n/s_path.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/beginner/path_kit.dart';
import 'package:paper_league/ui/phase2/move1_flow.dart';
import 'package:provider/provider.dart';

/// Desks 15–21: unlock Short lesson + send user to Tape Drill.
class Phase5Bridge extends StatelessWidget {
  const Phase5Bridge({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Text(s.p5Cap, style: pathCapStyle.copyWith(color: PlColors.bear)),
        const SizedBox(height: 8),
        Text(s.p5Title, style: pathTitleStyle(context)),
        const SizedBox(height: 8),
        Text(s.p5Body, style: pathSubStyle),
        const SizedBox(height: 16),
        PathCard(
          accent: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.p5Point1, style: const TextStyle(fontSize: 15, height: 1.4)),
              const SizedBox(height: 10),
              Text(s.p5Point2, style: const TextStyle(fontSize: 15, height: 1.4)),
              const SizedBox(height: 10),
              Text(s.p5Point3, style: const TextStyle(fontSize: 15, height: 1.4)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CoachBubble(s.p5Coach),
        const SizedBox(height: 20),
        PathButton(
          s.p5CtaShort,
          trailingIcon: Icons.arrow_forward_rounded,
          pulse: true,
          onPressed: () async {
            pathTap(strong: true);
            final desk = context.read<DeskController>();
            await desk.completePhase5Bridge();
            if (!context.mounted) return;
            await openMove1Flow(context, short: true);
          },
        ),
        const SizedBox(height: 8),
        PathButton(
          s.p5CtaLater,
          tone: PathButtonTone.ghost,
          onPressed: () async {
            pathTap();
            await context.read<DeskController>().completePhase5Bridge();
          },
        ),
      ],
    );
  }
}
