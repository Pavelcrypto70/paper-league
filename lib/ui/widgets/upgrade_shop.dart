import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:paper_league/domain/desk_meta.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';

Future<void> showUpgradeShop(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: PlColors.surface,
    isScrollControlled: true,
    builder: (_) => const _UpgradeShop(),
  );
}

class _UpgradeShop extends StatelessWidget {
  const _UpgradeShop();

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
          Text(s.upgradeShop, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            '${s.credits}: ${desk.meta.credits} · ${s.streakLabel} ${desk.meta.loginStreak}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: PlSpace.lg),
          ...kDeskUpgrades.map((u) {
            final owned = desk.meta.has(u.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: PlColors.bgElevated,
                borderRadius: BorderRadius.circular(PlRadius.md),
                child: InkWell(
                  borderRadius: BorderRadius.circular(PlRadius.md),
                  onTap: owned
                      ? null
                      : () async {
                          final ok = await desk.buyUpgrade(u.id);
                          if (!context.mounted) return;
                          HapticFeedback.selectionClick();
                          if (!ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(s.notEnoughCredits)),
                            );
                          }
                        },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u.title(s.isRu), style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text(u.hint(s.isRu), style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        Text(
                          owned ? s.owned : '${u.cost}',
                          style: TextStyle(
                            color: owned ? PlColors.bull : PlColors.accent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
