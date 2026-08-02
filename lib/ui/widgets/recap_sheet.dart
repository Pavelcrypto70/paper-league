import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paper_league/domain/models.dart';
import 'package:paper_league/domain/trade_coach.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/format.dart';
import 'package:paper_league/ui/widgets/recap_share_card.dart';
import 'package:paper_league/ui/widgets/trade_replay_chart.dart';
import 'package:provider/provider.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/services/desk_audio.dart';

Future<void> showRecapSheet(BuildContext context, ClosedTrade trade) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: PlColors.surface,
    isScrollControlled: true,
    builder: (ctx) => RecapSheet(trade: trade),
  );
}

class RecapSheet extends StatefulWidget {
  const RecapSheet({super.key, required this.trade});

  final ClosedTrade trade;

  @override
  State<RecapSheet> createState() => _RecapSheetState();
}

class _RecapSheetState extends State<RecapSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: PlMotion.emphasis)..forward();
    _scale = Tween(begin: 0.92, end: 1.0).animate(CurvedAnimation(parent: _c, curve: PlMotion.curveIn));
    _fade = CurvedAnimation(parent: _c, curve: PlMotion.curveIn);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trade = widget.trade;
    final s = S.of(context);
    final win = trade.pnl >= 0;
    final color = win ? PlColors.bull : PlColors.bear;
    final analysis = analyzeTrade(trade, ru: s.isRu);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(PlSpace.lg, PlSpace.md, PlSpace.lg, PlSpace.xl + bottom),
          child: SingleChildScrollView(
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
                const SizedBox(height: PlSpace.lg),
                Text(s.recap, style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.2)),
                const SizedBox(height: PlSpace.sm),
                Text(
                  '${trade.symbol} · ${trade.side == Side.long ? s.long : s.short}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  s.exitLabel(trade.exitKind.name),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: PlSpace.sm),
                Text(
                  '${trade.rMultiple >= 0 ? '+' : ''}${trade.rMultiple.toStringAsFixed(2)}R',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: color,
                        fontSize: 44,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.2,
                        shadows: [
                          Shadow(color: color.withValues(alpha: 0.35), blurRadius: 18),
                        ],
                      ),
                ),
                const SizedBox(height: PlSpace.sm),
                Text(
                  '${money(trade.pnl)} · ${priceFmt(trade.entry)} → ${priceFmt(trade.exit)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: PlSpace.lg),
                Text(s.tapeReplay, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 8),
                TradeReplayChart(trade: trade),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _MetricChip(label: s.mfe, value: '+${analysis.mfeR.toStringAsFixed(1)}R', color: PlColors.bull),
                    const SizedBox(width: 8),
                    _MetricChip(label: s.mae, value: '−${analysis.maeR.toStringAsFixed(1)}R', color: PlColors.bear),
                  ],
                ),
                const SizedBox(height: PlSpace.lg),
                Container(
                  padding: const EdgeInsets.all(PlSpace.md),
                  decoration: BoxDecoration(
                    color: PlColors.bgElevated,
                    borderRadius: BorderRadius.circular(PlRadius.md),
                    border: Border.all(color: PlColors.lineSoft),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        analysis.headline,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: PlColors.accent),
                      ),
                      const SizedBox(height: 10),
                      ...analysis.points.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Icon(Icons.circle, size: 6, color: PlColors.accent),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(p, style: Theme.of(context).textTheme.bodyMedium),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 20, color: PlColors.lineSoft),
                      Text(
                        '${s.discipline} ${trade.scoreDelta >= 0 ? '+' : ''}${trade.scoreDelta}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: PlColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: PlSpace.md),
                _Flag(ok: trade.flags.contains(RecapFlag.stopSet), label: s.flagStop),
                _Flag(ok: trade.flags.contains(RecapFlag.sizeOk), label: s.flagSize),
                _Flag(ok: trade.flags.contains(RecapFlag.noWiden), label: s.flagWiden),
                _Flag(ok: trade.flags.contains(RecapFlag.noRevenge), label: s.flagRevenge),
                const SizedBox(height: PlSpace.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          DeskAudio.instance.play(DeskSfx.tap);
                          final nick = context.read<DeskController>().nickname;
                          final desk = context.read<DeskController>();
                          await shareRecapCard(context, trade: trade, nickname: nick);
                          if (!context.mounted) return;
                          await desk.markDailyShare();
                        },
                        icon: const Icon(Icons.ios_share_rounded, size: 18),
                        label: Text(s.shareRecap),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: PlColors.accent,
                          foregroundColor: PlColors.onAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PlRadius.md)),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Text(s.backToDesk, style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(PlRadius.sm),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
            const Spacer(),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _Flag extends StatelessWidget {
  const _Flag({required this.ok, required this.label});
  final bool ok;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PlSpace.sm),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 18,
            color: ok ? PlColors.bull : PlColors.bear,
          ),
          const SizedBox(width: PlSpace.sm),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ok ? PlColors.text : PlColors.muted,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
