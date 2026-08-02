import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:paper_league/domain/models.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/format.dart';
import 'package:paper_league/ui/widgets/recap_sheet.dart';

class PositionsScreen extends StatelessWidget {
  const PositionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final desk = context.watch<DeskController>();
    final s = S.of(context);
    final pos = desk.position;

    return ListView(
      padding: const EdgeInsets.fromLTRB(PlSpace.lg, PlSpace.md, PlSpace.lg, PlSpace.xl),
      children: [
        Text(s.positions, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: PlSpace.xs),
        Text(s.positionsSub, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: PlSpace.xl),
        if (pos == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(PlRadius.lg),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [PlColors.surface, PlColors.bgElevated],
              ),
              border: Border.all(color: PlColors.lineSoft),
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: PlColors.surface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: PlColors.lineSoft),
                  ),
                  child: const Icon(Icons.inbox_outlined, color: PlColors.faint, size: 26),
                ),
                const SizedBox(height: PlSpace.md),
                Text(s.flat, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: PlSpace.xs),
                Text(
                  s.noOpen,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          _OpenCard(desk: desk, pos: pos),
        const SizedBox(height: PlSpace.xl),
        Row(
          children: [
            Text(s.history, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: PlColors.surface2,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${desk.tradesCount} · ${desk.winRatePct.toStringAsFixed(0)}% WR',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: PlColors.muted),
              ),
            ),
          ],
        ),
        const SizedBox(height: PlSpace.md),
        if (desk.history.isEmpty)
          Text(s.noTrades, style: Theme.of(context).textTheme.bodySmall)
        else
          ...desk.history.take(20).map((t) => _HistoryTile(trade: t)),
      ],
    );
  }
}

class _OpenCard extends StatelessWidget {
  const _OpenCard({required this.desk, required this.pos});
  final DeskController desk;
  final Position pos;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final u = pos.unrealized(desk.markFor(pos.symbol));
    final color = u >= 0 ? PlColors.bull : PlColors.bear;
    final risk = pos.riskAmount();
    return Container(
      padding: const EdgeInsets.all(PlSpace.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PlRadius.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.12),
            PlColors.surface,
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Text(
                  pos.side == Side.long ? s.long : s.short,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    fontSize: 11,
                  ),
                ),
              ),
              const Spacer(),
              Text(money(u), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: PlSpace.md),
          Text(
            '${pos.symbol} · ${qtyFmt(pos.qty)} @ ${priceFmt(pos.entry)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'SL ${priceFmt(pos.stop)}${pos.tp != null ? ' · TP ${priceFmt(pos.tp!)}' : ''} · risk ${money(risk)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: PlSpace.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    desk.closePartial(0.5);
                    HapticFeedback.selectionClick();
                  },
                  child: Text(s.close50),
                ),
              ),
              const SizedBox(width: PlSpace.sm),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: PlColors.bear),
                  onPressed: () {
                    desk.closePosition();
                    HapticFeedback.mediumImpact();
                  },
                  child: Text(s.closeAll),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.trade});
  final ClosedTrade trade;

  @override
  Widget build(BuildContext context) {
    final color = trade.pnl >= 0 ? PlColors.bull : PlColors.bear;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(PlRadius.md),
        onTap: () {
          HapticFeedback.selectionClick();
          showRecapSheet(context, trade);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: PlColors.surface,
            borderRadius: BorderRadius.circular(PlRadius.md),
            border: Border.all(color: PlColors.lineSoft),
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 36,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${trade.symbol} · ${trade.side.name.toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${priceFmt(trade.entry)} → ${priceFmt(trade.exit)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${trade.rMultiple >= 0 ? '+' : ''}${trade.rMultiple.toStringAsFixed(2)}R',
                    style: TextStyle(color: color, fontWeight: FontWeight.w800),
                  ),
                  Text(money(trade.pnl), style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
