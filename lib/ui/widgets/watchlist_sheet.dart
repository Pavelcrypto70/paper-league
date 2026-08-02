import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/services/desk_audio.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/format.dart';

Future<void> showWatchlistSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: PlColors.surface,
    isScrollControlled: true,
    builder: (_) => const WatchlistSheet(),
  );
}

class WatchlistSheet extends StatelessWidget {
  const WatchlistSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final desk = context.watch<DeskController>();
    final s = S.of(context);
    final ranked = desk.symbolsByVolatility;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PlColors.line,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(s.topVol, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(s.topVolSub, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.55,
              child: ListView.separated(
                itemCount: ranked.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final sym = ranked[index];
                  final on = desk.activeSymbol == sym.id;
                  final vol = desk.dayVolPct(sym.id);
                  final ch = desk.change24hPct(sym.id);
                  final mark = desk.books[sym.id]?.last.close ?? sym.start;
                  final chColor = ch >= 0 ? PlColors.bull : PlColors.bear;
                  return Material(
                    color: on ? PlColors.accentSoft : PlColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        DeskAudio.instance.play(DeskSfx.tap);
                        desk.switchSymbol(sym.id);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: on ? PlColors.accent.withValues(alpha: 0.5) : PlColors.lineSoft,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              alignment: Alignment.center,
                              child: Text(
                                '#${index + 1}',
                                style: TextStyle(
                                  color: index < 3 ? PlColors.accent : PlColors.faint,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(sym.base, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                  Text(sym.id, style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  priceFmt(mark),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                                Text(
                                  '${vol.toStringAsFixed(1)}% · ${pctPoints(ch)}',
                                  style: TextStyle(color: chColor, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
