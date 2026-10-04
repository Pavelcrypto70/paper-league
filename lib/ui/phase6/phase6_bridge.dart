import 'package:flutter/material.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/l10n/s_path.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/beginner/path_kit.dart';
import 'package:provider/provider.dart';

/// Desks 22–28: Contest → Finals stakes.
class Phase6Bridge extends StatelessWidget {
  const Phase6Bridge({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Text(s.p6Cap, style: pathCapStyle.copyWith(color: PlColors.warn)),
        const SizedBox(height: 8),
        Text(s.p6Title, style: pathTitleStyle(context)),
        const SizedBox(height: 8),
        Text(s.p6Body, style: pathSubStyle),
        const SizedBox(height: 16),
        PathCard(
          child: Column(
            children: [
              _Row('Grow', s.p6Grow),
              const SizedBox(height: 12),
              _Row('Contest', s.p6Contest),
              const SizedBox(height: 12),
              _Row('Finals', s.p6Finals),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CoachBubble(s.p6Coach),
        const SizedBox(height: 20),
        PathButton(
          s.p6Cta,
          trailingIcon: Icons.arrow_forward_rounded,
          pulse: true,
          onPressed: () async {
            pathTap(strong: true);
            final desk = context.read<DeskController>();
            await desk.completePhase6Bridge();
            desk.requestShellTab(2);
          },
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.text);
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: pathMono(size: 12, weight: FontWeight.w700, color: PlColors.accent)),
        ),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15, height: 1.4, color: PathInk.body))),
      ],
    );
  }
}
