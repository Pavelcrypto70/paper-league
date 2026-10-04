import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paper_league/domain/models.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/l10n/s_path.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/beginner/path_kit.dart';
import 'package:paper_league/ui/format.dart';
import 'package:paper_league/ui/widgets/candle_chart.dart';
import 'package:provider/provider.dart';

Future<void> openMove1Flow(BuildContext context, {bool startAtCopy = false, bool short = false}) {
  pathTap(strong: true);
  final desk = context.read<DeskController>();
  // Force a fresh day-chart at flow open; keep it stable until the next open.
  desk.prepareMoveTeach(day: desk.habitViewDay, force: true, short: short);
  return Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      transitionDuration: PlMotion.emphasis,
      reverseTransitionDuration: PlMotion.standard,
      pageBuilder: (_, _, _) => Move1FlowScreen(startAtCopy: startAtCopy, short: short),
      transitionsBuilder: (_, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: PlMotion.curveIn);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    ),
  ).whenComplete(desk.clearMoveTeach);
}

/// Replay → paper copy for move 1 (bounce up) or Short fade when [short].
class Move1FlowScreen extends StatefulWidget {
  const Move1FlowScreen({super.key, this.startAtCopy = false, this.short = false});
  final bool startAtCopy;
  final bool short;

  @override
  State<Move1FlowScreen> createState() => _Move1FlowScreenState();
}

class _Move1FlowScreenState extends State<Move1FlowScreen> {
  late int _page; // 0 replay, 1 copy, 2 done

  @override
  void initState() {
    super.initState();
    // Always show today's bounce replay first so the chart is not a repeat.
    // [startAtCopy] kept for call-site compat but intentionally ignored.
    _page = widget.startAtCopy ? 0 : 0;
  }

  void _go(int p) => setState(() => _page = p);

  @override
  Widget build(BuildContext context) {
    final page = switch (_page) {
      0 => _ReplayPage(
          onNext: () async {
            await context.read<DeskController>().markMove1ReplaySeen();
            _go(1);
          },
          onClose: () => Navigator.of(context).maybePop(),
        ),
      1 => _CopyPage(
          onDone: () => _go(2),
          onClose: () => Navigator.of(context).maybePop(),
        ),
      _ => _DonePage(onClose: () => Navigator.of(context).maybePop()),
    };
    return Scaffold(
      backgroundColor: PlColors.bg,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: PlMotion.emphasis,
          child: KeyedSubtree(key: ValueKey(_page), child: page),
        ),
      ),
    );
  }
}

class _ReplayPage extends StatefulWidget {
  const _ReplayPage({required this.onNext, required this.onClose});
  final VoidCallback onNext;
  final VoidCallback onClose;

  @override
  State<_ReplayPage> createState() => _ReplayPageState();
}

class _ReplayPageState extends State<_ReplayPage> with SingleTickerProviderStateMixin {
  late final AnimationController _play = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  );
  Timer? _live;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _play.value = 1;
      } else {
        _play.forward();
      }
    });
    // After the tape finishes drawing, keep the last candle breathing.
    _play.addStatusListener((st) {
      if (st == AnimationStatus.completed && mounted && _live == null) {
        _live = Timer.periodic(const Duration(milliseconds: 320), (_) {
          if (!mounted) return;
          context.read<DeskController>().tickMoveTeach();
        });
      }
    });
  }

  @override
  void dispose() {
    _live?.cancel();
    _play.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final desk = context.watch<DeskController>();
    final all = desk.moveTeachCandles ?? const <Candle>[];
    final steps = [s.moveStep1, s.moveStep2, s.moveStep3, s.moveStep4];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FlowHeader(label: s.moveReplayLabel, onClose: widget.onClose, progress: 1 / 3),
          const SizedBox(height: 14),
          Text(s.moveTitle, style: pathTitleStyle(context)),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedBuilder(
                    animation: _play,
                    builder: (context, _) {
                      final t = _play.value;
                      final n = all.isEmpty ? 0 : math.max(10, (all.length * t).ceil());
                      final slice = all.isEmpty ? all : all.take(n.clamp(1, all.length)).toList();
                      final showGuide = t > 0.28;
                      final showStop = t > 0.55;
                      final showTp = t > 0.78;
                      final buy = desk.moveTeachBuy;
                      final short = desk.teachIsShort;
                      return Container(
                        height: 260,
                        decoration: BoxDecoration(
                          color: PlColors.surface,
                          borderRadius: BorderRadius.circular(PlRadius.lg),
                          border: Border.all(color: PlColors.lineSoft),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: slice.isEmpty
                            ? const Center(child: CircularProgressIndicator(color: PlColors.accent))
                            : IgnorePointer(
                                child: CandleChart(
                                  candles: slice,
                                  guideLevel: showGuide ? buy : null,
                                  guideTag: showGuide ? (short ? s.moveSellLine : s.moveBuyLine) : null,
                                  entry: showGuide ? buy : null,
                                  stop: showStop && buy != null
                                      ? (short ? buy * 1.012 : buy * 0.988)
                                      : null,
                                  tp: showTp && buy != null
                                      ? (short ? buy * 0.986 : buy * 1.014)
                                      : null,
                                  side: short ? Side.short : Side.long,
                                ),
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  for (var i = 0; i < steps.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    _StepRow(
                      index: i + 1,
                      text: steps[i],
                      active: _play.value >= (i + 1) / steps.length - 0.05,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          PathButton(
            s.moveReplayCta,
            trailingIcon: Icons.arrow_forward_rounded,
            onPressed: () {
              pathTap(strong: true);
              widget.onNext();
            },
          ),
        ],
      ),
    );
  }
}

class _CopyPage extends StatefulWidget {
  const _CopyPage({required this.onDone, required this.onClose});
  final VoidCallback onDone;
  final VoidCallback onClose;

  @override
  State<_CopyPage> createState() => _CopyPageState();
}

class _CopyPageState extends State<_CopyPage> {
  bool _busy = false;
  bool _stopPlaced = false;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(milliseconds: 320), (_) {
      if (!mounted) return;
      context.read<DeskController>().tickMoveTeach();
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _buy() async {
    if (_busy) return;
    setState(() => _busy = true);
    pathTap(strong: true);
    final desk = context.read<DeskController>();
    await desk.ensureMove1Trade();
    if (!mounted) return;
    if (desk.position != null) {
      desk.placeMove1Stop(riskPct: 0.01);
      HapticFeedback.heavyImpact();
      setState(() => _stopPlaced = true);
    }
    setState(() => _busy = false);
  }

  void _close() {
    pathTap(strong: true);
    context.read<DeskController>().closePosition();
    HapticFeedback.heavyImpact();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final desk = context.watch<DeskController>();
    final pos = desk.position;
    final open = pos != null && desk.moveCopyTrade;
    final candles = desk.moveTeachCandles ?? desk.candles;
    final guide = desk.moveTeachBuy ?? desk.move1BounceLine;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FlowHeader(label: s.moveCopyLabel, onClose: widget.onClose, progress: 2 / 3),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                desk.activeSymbol.replaceAll('USDT', '/USDT'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 10),
              PathChip(desk.timeframe),
              const Spacer(),
              PathChip(s.movePaper, tone: PathTone.accent),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (open)
                    PathBanner(
                      tone: PathTone.bull,
                      icon: Icons.check_rounded,
                      title: s.moveOpened,
                      body: s.moveOpenedBody,
                    ),
                  if (open) const SizedBox(height: 12),
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: PlColors.surface,
                      borderRadius: BorderRadius.circular(PlRadius.lg),
                      border: Border.all(color: open ? PlColors.lineSoft : PlColors.accent.withValues(alpha: 0.45)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: candles.isEmpty
                        ? const Center(child: CircularProgressIndicator(color: PlColors.accent))
                        : IgnorePointer(
                            child: CandleChart(
                              candles: candles,
                              entry: pos?.entry,
                              stop: _stopPlaced || (desk.tutorialStopSet) ? pos?.stop : null,
                              side: pos != null
                                  ? (desk.teachIsShort ? Side.short : Side.long)
                                  : null,
                              // Keep guide on the same teaching chart (also after fill).
                              guideLevel: guide ?? desk.moveTeachBuy,
                              guideTag: desk.teachIsShort ? s.moveSellLine : s.moveBuyLine,
                            ),
                          ),
                  ),
                  if (!open) ...[
                    const SizedBox(height: 8),
                    Text(
                      desk.teachIsShort ? s.moveLookLineShort : s.moveLookLine,
                      textAlign: TextAlign.center,
                      style: pathMono(size: 12, color: desk.teachIsShort ? PlColors.bear : PlColors.accent),
                    ),
                    const SizedBox(height: 12),
                    CoachBubble(desk.teachIsShort ? s.moveCopyCoachShort : s.moveCopyCoach),
                    const SizedBox(height: 12),
                    PathCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Column(
                        children: [
                          KvRow(s.m3RiskPer, '1.0% · −${money0(100)}', valueColor: PlColors.accent),
                          KvRow(
                            s.moveTargetLabel,
                            desk.teachIsShort ? s.moveTargetHintShort : s.moveTargetHint,
                            valueColor: PlColors.bull,
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (open) ...[
                    PathCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Column(
                        children: [
                          KvRow(
                            s.m2Position,
                            '${desk.teachIsShort ? 'SHORT' : 'LONG'} ${pos.qty.toStringAsFixed(pos.qty >= 1 ? 2 : 4)}',
                            valueColor: desk.teachIsShort ? PlColors.bear : PlColors.bull,
                          ),
                          KvRow(s.m2Entry, priceFmt(pos.entry)),
                          KvRow(s.m3Stop, priceFmt(pos.stop), valueColor: PlColors.bear),
                          KvRow(
                            s.m2PnlNow,
                            '${pos.unrealized(desk.markFor(pos.symbol)) >= 0 ? '+' : ''}${money(pos.unrealized(desk.markFor(pos.symbol)))} ${s.practice}',
                            valueColor: pos.unrealized(desk.markFor(pos.symbol)) >= 0 ? PlColors.bull : PlColors.bear,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (!open)
            PathButton(
              'Buy · Long',
              tone: PathButtonTone.bull,
              pulse: true,
              onPressed: candles.isEmpty || _busy ? null : _buy,
            )
          else
            PathButton(s.moveCloseTarget, onPressed: _close),
        ],
      ),
    );
  }
}

class _DonePage extends StatelessWidget {
  const _DonePage({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final copies = context.watch<DeskController>().move1Copies;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const Icon(Icons.check_circle_rounded, size: 64, color: PlColors.bull),
          const SizedBox(height: 16),
          Text(s.moveCopyDoneTitle, textAlign: TextAlign.center, style: pathTitleStyle(context)),
          const SizedBox(height: 8),
          Text(s.moveCopyDoneBody, textAlign: TextAlign.center, style: pathSubStyle),
          const SizedBox(height: 20),
          PathChip('$copies / 3', tone: PathTone.bull),
          const Spacer(),
          PathButton(
            s.moveToToday,
            onPressed: () {
              pathTap(strong: true);
              onClose();
            },
          ),
        ],
      ),
    );
  }
}

class _FlowHeader extends StatelessWidget {
  const _FlowHeader({required this.label, required this.onClose, required this.progress});
  final String label;
  final VoidCallback onClose;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(label, style: pathMono(size: 13, weight: FontWeight.w600, color: PlColors.muted)),
            const Spacer(),
            InkResponse(
              onTap: onClose,
              radius: 22,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close_rounded, size: 22, color: PlColors.muted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress.clamp(0.05, 1),
            minHeight: 5,
            backgroundColor: PlColors.surface3,
            color: PlColors.accent,
          ),
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.text, required this.active});
  final int index;
  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: active ? 1 : 0.45,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? PlColors.accentDim : PlColors.surface2,
              border: Border.all(color: active ? PathInk.accentLine : PlColors.lineSoft),
            ),
            child: Text(
              '$index',
              style: pathMono(size: 12, weight: FontWeight.w700, color: active ? PlColors.accent : PlColors.faint),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(text, style: const TextStyle(fontSize: 15, height: 1.4, color: PathInk.body)),
            ),
          ),
        ],
      ),
    );
  }
}

