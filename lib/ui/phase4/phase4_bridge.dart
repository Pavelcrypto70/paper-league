import 'package:flutter/material.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/l10n/s_path.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/beginner/path_kit.dart';
import 'package:provider/provider.dart';

/// Desks 8–14: how to climb League after the week habit.
class Phase4Bridge extends StatelessWidget {
  const Phase4Bridge({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Text(s.p4Cap, style: pathCapStyle.copyWith(color: PlColors.accent)),
        const SizedBox(height: 8),
        Text(s.p4Title, style: pathTitleStyle(context)),
        const SizedBox(height: 8),
        Text(s.p4Body, style: pathSubStyle),
        const SizedBox(height: 16),
        PathCard(
          child: Column(
            children: [
              _Row(Icons.checklist_rounded, s.p4Point1),
              const SizedBox(height: 12),
              _Row(Icons.military_tech_rounded, s.p4Point2),
              const SizedBox(height: 12),
              _Row(Icons.bolt_rounded, s.p4Point3),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CoachBubble(s.p4Coach),
        const SizedBox(height: 20),
        PathButton(
          s.p4Cta,
          trailingIcon: Icons.arrow_forward_rounded,
          pulse: true,
          onPressed: () async {
            pathTap(strong: true);
            await context.read<DeskController>().completePhase4Bridge();
          },
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: PlColors.accent),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15, height: 1.4, color: PathInk.body))),
      ],
    );
  }
}
