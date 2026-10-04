import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:paper_league/domain/models.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/services/desk_audio.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/format.dart';
import 'package:paper_league/ui/beginner/beginner_flow.dart';
import 'package:paper_league/ui/beginner/beginner_home.dart';
import 'package:paper_league/ui/widgets/candle_chart.dart';
import 'package:paper_league/ui/widgets/daily_desk_strip.dart';
import 'package:paper_league/ui/widgets/pulse_target.dart';
import 'package:paper_league/ui/widgets/order_sheet.dart';
import 'package:paper_league/ui/widgets/playbooks_sheet.dart';
import 'package:paper_league/ui/widgets/watchlist_sheet.dart';

class DeskScreen extends StatefulWidget {
  const DeskScreen({super.key});

  @override
  State<DeskScreen> createState() => _DeskScreenState();
}

class _DeskScreenState extends State<DeskScreen> {
  ChartTool _tool = ChartTool.pointer;
  int _clearToken = 0;
  Color? _juiceFlash;
  bool _pathBooted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final desk = context.watch<DeskController>();
    if (!_pathBooted && !desk.loading) {
      _pathBooted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<DeskController>().ensureBeginnerPathStarted();
      });
    }
    final juice = desk.pendingJuice;
    if (juice != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _fireJuice(juice, desk.hasHudPulse);
        desk.consumeJuice();
      });
    }
  }

  void _fireJuice(String kind, bool strong) {
    final color = switch (kind) {
      'fill' => PlColors.accent,
      'stop' => PlColors.bear,
      'tp' => PlColors.bull,
      'win' => PlColors.bull,
      'loss' => PlColors.bear,
      _ => PlColors.accent,
    };
    if (kind == 'stop' || kind == 'tp') {
      HapticFeedback.heavyImpact();
    } else if (kind == 'fill') {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    setState(() => _juiceFlash = color.withValues(alpha: strong ? 0.28 : 0.16));
    Future<void>.delayed(Duration(milliseconds: strong ? 220 : 140), () {
      if (mounted) setState(() => _juiceFlash = null);
    });
  }

  Future<void> _openTicket(Side side) async {
    final desk = context.read<DeskController>();
    DeskAudio.instance.play(DeskSfx.tap);
    if (desk.beginnerPathActive) {
      await openBeginnerFlow(context);
      return;
    }
    if (desk.needsLeagueNickname) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).nickRequired)));
      // Soft warn only — trading still allowed; score publish stays gated elsewhere.
    }
    final required = desk.preTradeRequired || desk.needsFirstRunTrade;
    if (required) {
      final ok = await showPreTradeCheck(context);
      if (!mounted || !ok) return;
      await desk.markDailyPlannedTrade();
    } else {
      final soft = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final s = S.of(ctx);
          return AlertDialog(
            backgroundColor: PlColors.surface,
            title: Text(s.preTradeSoft),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.preTradeSkip)),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(s.preTrade),
              ),
            ],
          );
        },
      );
      if (!mounted || soft == null) return;
      if (soft) {
        final ok = await showPreTradeCheck(context);
        if (!mounted || !ok) return;
        await desk.markDailyPlannedTrade();
      }
    }
    if (!mounted) return;
    await showOrderSheet(context, desk: desk, side: side);
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select((DeskController d) => d.loading);
    if (loading) return const _Skeleton();

    final desk = context.watch<DeskController>();
    if (desk.beginnerPathActive) return const BeginnerHome();

    return Stack(
      children: [
        Column(
          children: [
            const _HeaderStrip(),
            if (desk.needsLeagueNickname)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  S.of(context).nickRequired,
                  style: const TextStyle(color: PlColors.warn, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            const DailyDeskStrip(),
            _DrawBar(
                tool: _tool,
                onTool: (t) {
                  DeskAudio.instance.play(DeskSfx.tap);
                  setState(() => _tool = t);
                },
                onClear: () {
                  DeskAudio.instance.play(DeskSfx.tap);
                  context.read<DeskController>().clearPlaybookLevels();
                  setState(() => _clearToken++);
                },
              ),
            Expanded(child: _Chart(tool: _tool, clearToken: _clearToken)),
            const _CoachBanner(),
            const _PositionDock(),
            _Actions(onTicket: _openTicket),
          ],
        ),
        if (_juiceFlash != null)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _juiceFlash != null ? 1 : 0,
                duration: PlMotion.micro,
                child: ColoredBox(color: _juiceFlash!),
              ),
            ),
          ),
      ],
    );
  }
}

class _CoachBanner extends StatelessWidget {
  const _CoachBanner();

  @override
  Widget build(BuildContext context) {
    final done = context.select((DeskController d) => d.coachDone);
    if (done) return const SizedBox.shrink();
    final s = S.of(context);
    final desk = context.read<DeskController>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(PlSpace.lg, 8, PlSpace.lg, 0),
      child: Material(
        color: PlColors.accentDim,
        borderRadius: BorderRadius.circular(PlRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(PlRadius.md),
          onTap: () => desk.completeCoach(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(PlRadius.md),
              border: Border.all(color: PlColors.accent.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                const Icon(Icons.school_outlined, color: PlColors.accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.coachTitle, style: const TextStyle(fontWeight: FontWeight.w800, color: PlColors.accent)),
                      Text(s.coachBody, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Text(s.dismiss, style: const TextStyle(color: PlColors.muted, fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderStrip extends StatelessWidget {
  const _HeaderStrip();

  @override
  Widget build(BuildContext context) {
    final desk = context.watch<DeskController>();
    final s = S.of(context);
    final mark = desk.mark;
    final dir = desk.markDir;
    final ch = desk.change24hPct(desk.activeSymbol);
    final color = dir > 0 ? PlColors.bull : dir < 0 ? PlColors.bear : PlColors.text;
    final chColor = ch >= 0 ? PlColors.bull : PlColors.bear;
    final pnl = desk.dayPnlPct >= 0 ? PlColors.bull : PlColors.bear;
    final tape = desk.error;

    return Padding(
      padding: const EdgeInsets.fromLTRB(PlSpace.lg, PlSpace.sm, PlSpace.lg, 0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  DeskAudio.instance.play(DeskSfx.tap);
                  showWatchlistSheet(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: PlColors.surface,
                    borderRadius: BorderRadius.circular(PlRadius.sm),
                    border: Border.all(color: PlColors.lineSoft),
                  ),
                  child: Row(
                    children: [
                      Text(
                        desk.activeMeta.base,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${desk.dayVolPct(desk.activeSymbol).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: PlColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Icon(Icons.expand_more, size: 18, color: PlColors.muted),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (tape != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: PlColors.warn.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(PlRadius.sm),
                    border: Border.all(color: PlColors.warn.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    tape.toUpperCase(),
                    style: const TextStyle(
                      color: PlColors.warn,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: PlColors.bullSoft,
                    borderRadius: BorderRadius.circular(PlRadius.sm),
                    border: Border.all(color: PlColors.bull.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    desk.wsTapeLive
                        ? '${s.deskLiveTape} · ${s.wsTape}'
                        : (desk.usedLiveFeed ? s.deskLiveTape : s.deskOffline),
                    style: TextStyle(
                      color: (desk.wsTapeLive || desk.usedLiveFeed) ? PlColors.bull : PlColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              const Spacer(),
              ...['5m', '15m', '30m', '1h'].map((tf) {
                final on = desk.timeframe == tf;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: _MiniChip(
                    label: tf.toUpperCase(),
                    on: on,
                    onTap: () {
                      DeskAudio.instance.play(DeskSfx.tap);
                      desk.setTimeframe(tf);
                    },
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.last, style: Theme.of(context).textTheme.labelSmall),
                    _TickPrice(mark: mark, color: color),
                  ],
                ),
              ),
              Text(pctPoints(ch), style: TextStyle(color: chColor, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Stat(label: s.equity, value: money0(desk.equity)),
              _Stat(label: s.session, value: pctPoints(desk.dayPnlPct), color: pnl),
              _Stat(label: s.maxDd, value: pctPoints(-desk.maxDrawdown)),
              _Stat(label: s.disc, value: desk.processDisplay, color: PlColors.accent),
            ],
          ),
        ],
      ),
    );
  }
}

class _TickPrice extends StatefulWidget {
  const _TickPrice({required this.mark, required this.color});
  final double mark;
  final Color color;

  @override
  State<_TickPrice> createState() => _TickPriceState();
}

class _TickPriceState extends State<_TickPrice> {
  double _flash = 0;

  @override
  void didUpdateWidget(covariant _TickPrice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mark != widget.mark && oldWidget.mark != 0) {
      setState(() => _flash = 1);
      Future<void>.delayed(PlMotion.standard, () {
        if (mounted) setState(() => _flash = 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: PlMotion.micro,
      curve: PlMotion.curveIn,
      style: Theme.of(context).textTheme.displayMedium!.copyWith(
            fontSize: 32,
            height: 1,
            color: Color.lerp(widget.color, PlColors.text, _flash * 0.35),
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            fontFeatures: const [FontFeature.tabularFigures()],
            shadows: _flash > 0.2
                ? [
                    Shadow(
                      color: widget.color.withValues(alpha: 0.45 * _flash),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
      child: Text(priceFmt(widget.mark)),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color ?? PlColors.text,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: PlMotion.micro,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: on ? PlColors.accentSoft : PlColors.surface,
          borderRadius: BorderRadius.circular(PlRadius.sm),
          border: Border.all(color: on ? PlColors.accent : PlColors.lineSoft),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: on ? PlColors.accent : PlColors.muted,
          ),
        ),
      ),
    );
  }
}

class _DrawBar extends StatelessWidget {
  const _DrawBar({
    required this.tool,
    required this.onTool,
    required this.onClear,
  });

  final ChartTool tool;
  final ValueChanged<ChartTool> onTool;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    Widget chip(ChartTool t, IconData icon, String tip) {
      final on = tool == t;
      return Tooltip(
        message: tip,
        child: InkWell(
          onTap: () => onTool(t),
          borderRadius: BorderRadius.circular(PlRadius.sm),
          child: AnimatedContainer(
            duration: PlMotion.micro,
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: on ? PlColors.accentSoft : Colors.transparent,
              borderRadius: BorderRadius.circular(PlRadius.sm),
              border: Border.all(color: on ? PlColors.accent : PlColors.lineSoft),
            ),
            child: Icon(icon, size: 17, color: on ? PlColors.accent : PlColors.muted),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(PlSpace.lg, 8, PlSpace.lg, 0),
      child: Row(
        children: [
          chip(ChartTool.pointer, Icons.near_me_outlined, s.toolPointer),
          chip(ChartTool.level, Icons.horizontal_rule, s.toolLevel),
          chip(ChartTool.line, Icons.timeline, s.toolLine),
          chip(ChartTool.erase, Icons.auto_fix_high, s.toolErase),
          const Spacer(),
          Tooltip(
            message: s.playbooks,
            child: InkWell(
              onTap: () {
                DeskAudio.instance.play(DeskSfx.tap);
                showPlaybooksSheet(context);
              },
              borderRadius: BorderRadius.circular(PlRadius.sm),
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(PlRadius.sm),
                  border: Border.all(color: PlColors.lineSoft),
                ),
                child: const Icon(Icons.bookmark_added_outlined, size: 17, color: PlColors.muted),
              ),
            ),
          ),
          TextButton(
            onPressed: onClear,
            style: TextButton.styleFrom(
              foregroundColor: PlColors.muted,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(s.clear, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double h) => Container(
          height: h,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PlColors.surface,
                PlColors.surface2,
                PlColors.surface,
              ],
            ),
            borderRadius: BorderRadius.circular(PlRadius.md),
          ),
        );
    return Padding(
      padding: const EdgeInsets.all(PlSpace.lg),
      child: Column(
        children: [
          bar(44),
          bar(56),
          Expanded(child: bar(double.infinity)),
        ],
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.tool, required this.clearToken});
  final ChartTool tool;
  final int clearToken;

  @override
  Widget build(BuildContext context) {
    final desk = context.watch<DeskController>();
    final pos = desk.position;
    final show = pos != null && pos.symbol == desk.activeSymbol;
    final pb = desk.activePlaybookLevels;
    final seed = pb?.prices ?? const <double>[];
    return Padding(
      padding: const EdgeInsets.fromLTRB(PlSpace.lg, 8, PlSpace.lg, 0),
      child: CandleChart(
        key: ValueKey('chart-${desk.activeSymbol}-${desk.timeframe}'),
        candles: desk.candles,
        entry: show ? pos.entry : pb?.entry,
        stop: show && !(desk.tutorialTrade && !desk.tutorialStopSet) ? pos.stop : pb?.stop,
        tp: show ? pos.tp : pb?.tp,
        side: show ? pos.side : pb?.side,
        tool: tool,
        onStopDrag: show ? desk.updateStop : null,
        onTpDrag: show ? (p) => desk.updateTp(p) : null,
        seedLevels: seed,
        seedToken: desk.playbookSeedToken + clearToken,
      ),
    );
  }
}

class _PositionDock extends StatelessWidget {
  const _PositionDock();

  @override
  Widget build(BuildContext context) {
    final desk = context.watch<DeskController>();
    final pos = desk.position;
    final s = S.of(context);
    if (pos == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(PlSpace.lg, 8, PlSpace.lg, 0),
        child: Text(s.flatHint, style: Theme.of(context).textTheme.bodySmall),
      );
    }
    final m = desk.books[pos.symbol]?.last.close ?? desk.mark;
    final u = pos.unrealized(m);
    final color = u >= 0 ? PlColors.bull : PlColors.bear;
    final r = pos.rMultiple(m);
    return Container(
      margin: const EdgeInsets.fromLTRB(PlSpace.lg, 8, PlSpace.lg, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PlColors.surface,
        borderRadius: BorderRadius.circular(PlRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            color.withValues(alpha: 0.08),
            PlColors.surface,
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${pos.side.name.toUpperCase()} ${pos.symbol}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${qtyFmt(pos.qty)} · ${money(u)} · ${r >= 0 ? '+' : ''}${r.toStringAsFixed(2)}R',
                      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      desk.tutorialTrade && !desk.tutorialStopSet
                          ? '${S.of(context).gestureStopHint} · ${S.of(context).mission3RiskHint}'
                          : 'SL ${priceFmt(pos.stop)}${pos.tp != null ? ' · TP ${priceFmt(pos.tp!)}' : ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: desk.tutorialTrade && !desk.tutorialStopSet
                    ? null
                    : () {
                        DeskAudio.instance.play(DeskSfx.tap);
                        desk.closePosition();
                        HapticFeedback.mediumImpact();
                      },
                style: TextButton.styleFrom(foregroundColor: PlColors.bear),
                child: Text(s.close),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (!(desk.tutorialTrade && !desk.tutorialStopSet))
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    desk.closePartial(0.5);
                    HapticFeedback.selectionClick();
                  },
                  child: const Text('50%'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    final next = pos.side == Side.long
                        ? pos.stop + (m - pos.stop) * 0.35
                        : pos.stop - (pos.stop - m) * 0.35;
                    desk.updateStop(next);
                    HapticFeedback.selectionClick();
                  },
                  child: Text(s.tighten),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.onTicket});
  final Future<void> Function(Side side) onTicket;

  @override
  Widget build(BuildContext context) {
    final desk = context.watch<DeskController>();
    final s = S.of(context);
    final open = desk.position != null;
    final needStop = desk.tutorialTrade && !desk.tutorialStopSet;
    final needClose = desk.tutorialTrade && desk.tutorialStopSet && open;
    final pathTrade = desk.beginnerPathActive && desk.beginnerPathStep == 2 && !open;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(PlSpace.lg, 10, PlSpace.lg, 10),
        child: open
            ? PulseTarget(
                active: needStop || needClose,
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: needStop ? PlColors.accent : PlColors.bear,
                      foregroundColor: needStop ? PlColors.onAccent : PlColors.onBear,
                    ),
                    onPressed: () {
                      DeskAudio.instance.play(DeskSfx.tap);
                      if (needStop) {
                        desk.placeTutorialStop();
                        HapticFeedback.mediumImpact();
                        return;
                      }
                      desk.closePosition();
                      HapticFeedback.mediumImpact();
                    },
                    child: Text(
                      needStop ? s.gestureStopCta : s.closeAll,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              )
            : pathTrade
                ? PulseTarget(
                    active: true,
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: PlColors.bull,
                          foregroundColor: PlColors.onBull,
                        ),
                        onPressed: () => onTicket(Side.long),
                        child: Text(s.missionBuyLong, style: const TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: PlColors.bull,
                              foregroundColor: PlColors.onBull,
                            ),
                            onPressed: () => onTicket(Side.long),
                            child: Text(s.long, style: const TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: PlColors.bear,
                              foregroundColor: PlColors.onBear,
                            ),
                            onPressed: desk.beginnerPathActive && desk.beginnerPathStep < 2
                                ? null
                                : () => onTicket(Side.short),
                            child: Text(s.short, style: const TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
