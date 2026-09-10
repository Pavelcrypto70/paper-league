import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:paper_league/domain/models.dart';
import 'package:paper_league/domain/tape_drill.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/services/desk_audio.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';

class TapeDrillScreen extends StatefulWidget {
  const TapeDrillScreen({super.key});

  @override
  State<TapeDrillScreen> createState() => _TapeDrillScreenState();
}

class _TapeDrillScreenState extends State<TapeDrillScreen> {
  TapeDrillRound? _round;
  int _scrub = 0;
  bool _decided = false;
  bool _revealed = false;
  bool _showResult = false;
  bool _tapeVisible = false;
  TapeDrillResult? _result;
  DrillDecision? _decision;
  double? _stop;
  double? _tp;
  double _stopAtr = 1.2;
  double _tpR = 2.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final desk = context.read<DeskController>();
      if (!desk.tapeDrillIntroSeen) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            final s = S.of(ctx);
            return AlertDialog(
              backgroundColor: PlColors.surface,
              title: Text(s.drillIntroTitle),
              content: Text(s.drillIntroBody),
              actions: [
                FilledButton(
                  onPressed: () {
                    desk.markTapeDrillIntroSeen();
                    Navigator.pop(ctx);
                  },
                  child: Text(s.drillIntroGo),
                ),
              ],
            );
          },
        );
      }
      if (mounted) _newRound();
    });
  }

  void _newRound() {
    final desk = context.read<DeskController>();
    final symbol = desk.activeSymbol;
    final candles = List<Candle>.from(desk.books[symbol] ?? desk.candles);
    if (candles.length < 60) {
      setState(() {
        _round = null;
      });
      return;
    }
    final round = buildDrillRound(candles, symbol: symbol);
    setState(() {
      _round = round;
      _scrub = math.max(0, round.hideFrom - 40);
      _decided = false;
      _revealed = false;
      _showResult = false;
      _tapeVisible = false;
      _result = null;
      _decision = round.suggested;
      _stop = null;
      _tp = null;
      _stopAtr = 1.2;
      _tpR = 2.0;
    });
  }

  void _planLevels(DrillDecision d) {
    final round = _round;
    if (round == null) return;
    final entry = round.decisionBar.close;
    final slice = round.revealed;
    var atrPct = 1.5;
    if (slice.length >= 14) {
      final w = slice.sublist(slice.length - 14);
      var sum = 0.0;
      for (final x in w) {
        sum += (x.high - x.low) / x.close;
      }
      atrPct = sum / w.length * 100;
    }
    final atr = entry * (atrPct / 100).clamp(0.002, 0.08);
    final dist = atr * _stopAtr;
    setState(() {
      _decision = d;
      if (d == DrillDecision.long) {
        _stop = entry - dist;
        _tp = entry + dist * _tpR;
      } else if (d == DrillDecision.short) {
        _stop = entry + dist;
        _tp = entry - dist * _tpR;
      } else {
        _stop = null;
        _tp = null;
      }
    });
  }

  Future<void> _commit() async {
    final round = _round;
    final decision = _decision;
    if (round == null || decision == null) return;
    final result = gradeDrill(
      round: round,
      decision: decision,
      stop: decision == DrillDecision.skip ? null : _stop,
      tp: _tp,
    );
    setState(() {
      _decided = true;
      _result = result;
      _showResult = false;
    });
    // Cinema reveal: scrub through future bars.
    final target = math.min(round.candles.length - 1, round.hideFrom + round.horizon);
    for (var i = _scrub; i <= target; i += 2) {
      if (!mounted) return;
      setState(() {
        _scrub = i;
        _revealed = true;
      });
      await Future<void>.delayed(const Duration(milliseconds: 28));
    }
    if (!mounted) return;
    setState(() {
      _scrub = target;
      _showResult = true;
    });
    DeskAudio.instance.play(result.processScore >= 4 ? DeskSfx.win : DeskSfx.tap);
    HapticFeedback.mediumImpact();
    await context.read<DeskController>().recordTapeDrill(result.processScore);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final round = _round;
    final desk = context.watch<DeskController>();

    return Scaffold(
      backgroundColor: PlColors.bg,
      appBar: AppBar(
        title: Text(s.tapeDrill),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                '${s.processPts} ${desk.tapeDrillPoints}',
                style: const TextStyle(color: PlColors.accent, fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: round == null
          ? Center(child: Text(s.tapeDrillEmpty, style: Theme.of(context).textTheme.bodyMedium))
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.drillQuestTitle, style: const TextStyle(fontWeight: FontWeight.w800, color: PlColors.accent)),
                        const SizedBox(height: 4),
                        Text(
                          round.suggested == DrillDecision.long ? s.drillQuestLong('') : s.drillQuestShort(''),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (!_tapeVisible)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: FilledButton(
                        onPressed: () {
                          DeskAudio.instance.play(DeskSfx.tap);
                          setState(() {
                            _tapeVisible = true;
                            _scrub = round.hideFrom;
                            _planLevels(round.suggested);
                          });
                        },
                        child: Text(s.drillShowTape),
                      ),
                    )
                  else
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            Text(s.drillLookHere, style: Theme.of(context).textTheme.labelSmall),
                            const SizedBox(height: 6),
                            Expanded(
                              child: _DrillChart(
                                candles: round.candles,
                                endIndex: _scrub,
                                hideFrom: round.hideFrom,
                                revealed: _revealed,
                                entry: _decided ? round.decisionBar.close : null,
                                stop: _stop,
                                tp: _tp,
                                side: _decision == DrillDecision.long
                                    ? Side.long
                                    : _decision == DrillDecision.short
                                        ? Side.short
                                        : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_tapeVisible && !_decided) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: FilledButton(
                        onPressed: () {
                          DeskAudio.instance.play(DeskSfx.tap);
                          if (_decision == null) _planLevels(round.suggested);
                          _commit();
                        },
                        child: Text(s.drillPutStop),
                      ),
                    ),
                  ] else if (_showResult && _result != null) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.92, end: 1),
                        duration: PlMotion.emphasis,
                        curve: PlMotion.curveIn,
                        builder: (context, t, child) => Opacity(
                          opacity: t.clamp(0.0, 1.0),
                          child: Transform.scale(scale: t, child: child),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: PlColors.surface,
                            borderRadius: BorderRadius.circular(PlRadius.lg),
                            border: Border.all(color: PlColors.accent.withValues(alpha: 0.35)),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                PlColors.accentDim,
                                PlColors.surface,
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.drillPtsWhy(_result!.processScore),
                                style: const TextStyle(
                                  color: PlColors.accent,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(_result!.tip(s.isRu), style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(s.back),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: _newRound,
                                      child: Text(s.drillTryAgain),
                                    ),
                                  ),
                                ],
                              ),
                              if (context.watch<DeskController>().meta.drillRerolls > 0) ...[
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () async {
                                    final ok = await context.read<DeskController>().spendDrillReroll();
                                    if (ok) _newRound();
                                  },
                                  child: Text(
                                    '${s.nextDrill} (${context.watch<DeskController>().meta.drillRerolls})',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else if (_decided) ...[
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2, color: PlColors.accent),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _DrillChart extends StatelessWidget {
  const _DrillChart({
    required this.candles,
    required this.endIndex,
    required this.hideFrom,
    required this.revealed,
    this.entry,
    this.stop,
    this.tp,
    this.side,
  });

  final List<Candle> candles;
  final int endIndex;
  final int hideFrom;
  final bool revealed;
  final double? entry;
  final double? stop;
  final double? tp;
  final Side? side;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PlColors.bgElevated,
        borderRadius: BorderRadius.circular(PlRadius.lg),
        border: Border.all(color: PlColors.lineSoft),
      ),
      child: CustomPaint(
        painter: _DrillPainter(
          candles: candles,
          endIndex: endIndex.clamp(0, candles.length - 1),
          hideFrom: hideFrom,
          revealed: revealed,
          entry: entry,
          stop: stop,
          tp: tp,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _DrillPainter extends CustomPainter {
  _DrillPainter({
    required this.candles,
    required this.endIndex,
    required this.hideFrom,
    required this.revealed,
    this.entry,
    this.stop,
    this.tp,
  });

  final List<Candle> candles;
  final int endIndex;
  final int hideFrom;
  final bool revealed;
  final double? entry;
  final double? stop;
  final double? tp;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;
    const window = 70;
    final end = endIndex + 1;
    final start = math.max(0, end - window);
    final visible = candles.sublist(start, end);
    if (visible.isEmpty) return;

    var hi = visible.first.high;
    var lo = visible.first.low;
    for (final c in visible) {
      if (c.high > hi) hi = c.high;
      if (c.low < lo) lo = c.low;
    }
    for (final p in [entry, stop, tp]) {
      if (p == null) continue;
      if (p > hi) hi = p;
      if (p < lo) lo = p;
    }
    final pad = (hi - lo) * 0.08 + 1e-9;
    hi += pad;
    lo -= pad;

    double y(double price) => size.height * (1 - (price - lo) / (hi - lo));
    final w = size.width / visible.length;

    final fog = Paint()..color = PlColors.bg.withValues(alpha: 0.55);
    final fogStart = hideFrom - start;
    if (!revealed && fogStart >= 0 && fogStart < visible.length) {
      canvas.drawRect(
        Rect.fromLTWH(fogStart * w, 0, size.width - fogStart * w, size.height),
        fog,
      );
    }

    final wick = Paint()
      ..color = PlColors.wick
      ..strokeWidth = 1;
    for (var i = 0; i < visible.length; i++) {
      final c = visible[i];
      final abs = start + i;
      final hidden = !revealed && abs > hideFrom;
      if (hidden) continue;
      final cx = i * w + w / 2;
      canvas.drawLine(Offset(cx, y(c.high)), Offset(cx, y(c.low)), wick);
      final bodyTop = y(math.max(c.open, c.close));
      final bodyBot = y(math.min(c.open, c.close));
      final body = Paint()..color = c.isBull ? PlColors.bull : PlColors.bear;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(cx - w * 0.32, bodyTop, cx + w * 0.32, math.max(bodyBot, bodyTop + 1)),
          const Radius.circular(1),
        ),
        body,
      );
    }

    void level(double? p, Color color) {
      if (p == null) return;
      final yy = y(p);
      canvas.drawLine(
        Offset(0, yy),
        Offset(size.width, yy),
        Paint()
          ..color = color.withValues(alpha: 0.85)
          ..strokeWidth = 1.2,
      );
    }

    level(entry, PlColors.accent);
    level(stop, PlColors.bear);
    level(tp, PlColors.bull);

    // Decision marker
    final di = hideFrom - start;
    if (di >= 0 && di < visible.length) {
      final x = di * w + w / 2;
      canvas.drawCircle(Offset(x, y(candles[hideFrom].close)), 3.5, Paint()..color = PlColors.accent);
    }
  }

  @override
  bool shouldRepaint(covariant _DrillPainter old) =>
      old.endIndex != endIndex ||
      old.revealed != revealed ||
      old.stop != stop ||
      old.tp != tp ||
      old.entry != entry;
}
