import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:paper_league/domain/models.dart';
import 'package:paper_league/domain/playbook.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/services/desk_audio.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';

Future<void> showPlaybooksSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: PlColors.surface,
    isScrollControlled: true,
    builder: (_) => const PlaybooksSheet(),
  );
}

class PlaybooksSheet extends StatelessWidget {
  const PlaybooksSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final desk = context.watch<DeskController>();
    final s = S.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(PlSpace.lg, PlSpace.md, PlSpace.lg, PlSpace.xl + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: PlColors.line, borderRadius: BorderRadius.circular(99)),
            ),
          ),
          const SizedBox(height: PlSpace.lg),
          Text(s.playbooks, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            desk.playbooksIntroSeen ? s.playbooksHelp : s.pbIntroBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (!desk.playbooksIntroSeen) ...[
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () => desk.markPlaybooksIntroSeen(),
              child: Text(s.drillIntroGo),
            ),
          ],
          const SizedBox(height: PlSpace.lg),
          ...desk.playbooks.map((pb) => _PbTile(pb: pb)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              DeskAudio.instance.play(DeskSfx.tap);
              final maxSlots = 5 + desk.playbookSlotBonus;
              if (desk.playbooks.length >= maxSlots) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.playbookSlotsFull)),
                  );
                }
                return;
              }
              final id = 'pb_${DateTime.now().millisecondsSinceEpoch}';
              await desk.upsertPlaybook(
                Playbook(
                  id: id,
                  name: s.isRu ? 'Мой сетап' : 'My setup',
                  side: Side.long,
                  stopAtrMult: 1.2,
                  tpR: 2.0,
                ),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: Text(s.addPlaybook),
          ),
        ],
      ),
    );
  }
}

class _PbTile extends StatelessWidget {
  const _PbTile({required this.pb});
  final Playbook pb;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final desk = context.read<DeskController>();
    final color = pb.side == Side.long ? PlColors.bull : PlColors.bear;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PlColors.bgElevated,
        borderRadius: BorderRadius.circular(PlRadius.md),
        border: Border.all(color: PlColors.lineSoft),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 42,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pb.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  '${pb.side.name.toUpperCase()} · SL ${pb.stopAtrMult.toStringAsFixed(1)}ATR · TP ${pb.tpR.toStringAsFixed(1)}R',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              DeskAudio.instance.play(DeskSfx.fill);
              await desk.applyPlaybook(pb);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(s.playbookApplied)),
                );
              }
            },
            child: Text(s.applyChart),
          ),
        ],
      ),
    );
  }
}
