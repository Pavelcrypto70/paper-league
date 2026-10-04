import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/l10n/s_path.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/beginner/path_kit.dart';
import 'package:paper_league/ui/format.dart';
import 'package:paper_league/ui/widgets/candle_chart.dart';
import 'package:paper_league/domain/models.dart';
import 'package:provider/provider.dart';

Future<void> openMove1Flow(BuildContext context, {bool startAtCopy = false}) {
  pathTap(strong: true);
  return Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      transitionDuration: PlMotion.emphasis,
      reverseTransitionDuration: PlMotion.standard,
      pageBuilder: (_, _, _) => Move1FlowScreen(startAtCopy: startAtCopy),
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
  );
}

/// Replay → paper copy for move 1 (bounce up).
class Move1FlowScreen extends StatefulWidget {
  const Move1FlowScreen({super.key, this.startAtCopy = false});
  final bool startAtCopy;

  @override
  State<Move1FlowScreen> createState() => _Move1FlowScreenState();
}

class _Move1FlowScreenState extends State<Move1FlowScreen> {
  late int _page; // 0 replay, 1 copy, 2 done

  @override
  void initState() {
    super.initState();
    _page = widget.startAtCopy ? 1 : 0;
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
    duration: const Duration(milliseconds: 4200),
  );

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
  }

  @override
  void dispose() {
    _play.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
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
                    builder: (context, _) => Container(
                      height: 240,
                      decoration: BoxDecoration(
                        color: PlColors.surface,
                        borderRadius: BorderRadius.circular(PlRadius.lg),
                        border: Border.all(color: PlColors.lineSoft),
                      ),
                      child: CustomPaint(painter: _MoveReplayPainter(t: _play.value)),
                    ),
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
    final candles = desk.candles;

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
                      border: Border.all(color: PlColors.lineSoft),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: candles.isEmpty
                        ? const Center(child: CircularProgressIndicator(color: PlColors.accent))
                        : IgnorePointer(
                            child: CandleChart(
                              candles: candles,
                              entry: pos?.entry,
                              stop: _stopPlaced || (desk.tutorialStopSet) ? pos?.stop : null,
                              side: pos != null ? Side.long : null,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  if (!open) CoachBubble(s.moveCopyCoach),
                  if (!open) ...[
                    const SizedBox(height: 12),
                    PathCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Column(
                        children: [
                          KvRow(s.m3RiskPer, '1.0% · −${money0(100)}', valueColor: PlColors.accent),
                          KvRow(s.moveTargetLabel, s.moveTargetHint, valueColor: PlColors.bull),
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
                            'LONG ${pos.qty.toStringAsFixed(pos.qty >= 1 ? 2 : 4)}',
                            valueColor: PlColors.bull,
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

/// Procedural bounce replay — zone, buy, stop, target reveal over time.
class _MoveReplayPainter extends CustomPainter {
  _MoveReplayPainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final n = 28;
    final slot = w / (n + 2);
    final path = <Offset>[];
    for (var i = 0; i < n; i++) {
      final x = slot * (i + 1);
      final phase = i / (n - 1);
      // Down then bounce up
      double yN;
      if (phase < 0.45) {
        yN = 0.28 + phase * 0.9;
      } else if (phase < 0.55) {
        yN = 0.68;
      } else {
        yN = 0.68 - (phase - 0.55) * 0.85;
      }
      yN += math.sin(i * 1.7) * 0.02;
      path.add(Offset(x, h * yN.clamp(0.12, 0.88)));
    }

    // candles
    for (var i = 0; i < path.length; i++) {
      final p = path[i];
      final prev = i == 0 ? p : path[i - 1];
      final bull = p.dy <= prev.dy;
      final color = (bull ? PlColors.bull : PlColors.bear).withValues(alpha: 0.9);
      final bodyH = math.max(4.0, (p.dy - prev.dy).abs() + 6);
      final cx = p.dx;
      canvas.drawLine(
        Offset(cx, p.dy - bodyH * 0.7),
        Offset(cx, p.dy + bodyH * 0.5),
        Paint()
          ..color = color.withValues(alpha: 0.55)
          ..strokeWidth = 1.2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, p.dy), width: slot * 0.55, height: bodyH * 0.55),
          const Radius.circular(1.5),
        ),
        Paint()..color = color,
      );
    }

    final buyI = 14;
    final buyY = path[buyI].dy;
    final stopY = buyY + h * 0.12;
    final tpY = buyY - h * 0.18;

    void tag(String text, Offset at, Color c) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: PlColors.onAccent,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(at.dx, at.dy - 9, tp.width + 14, 18),
        const Radius.circular(4),
      );
      canvas.drawRRect(r, Paint()..color = c);
      tp.paint(canvas, Offset(at.dx + 7, at.dy - 6));
    }

    void dash(double y, Color c) {
      final paint = Paint()
        ..color = c
        ..strokeWidth = 1.5;
      for (var x = 0.0; x < w; x += 10) {
        canvas.drawLine(Offset(x, y), Offset(math.min(x + 6, w), y), paint);
      }
    }

    if (t > 0.15) {
      // zone
      canvas.drawRect(
        Rect.fromLTRB(0, buyY - 8, w, stopY + 4),
        Paint()..color = PlColors.accent.withValues(alpha: 0.08),
      );
    }
    if (t > 0.35) {
      dash(buyY, PlColors.accent);
      tag('КУПИЛИ', Offset(12, buyY - 14), PlColors.accent);
    }
    if (t > 0.55) {
      dash(stopY, PlColors.bear);
      tag('СТОП', Offset(12, stopY - 14), PlColors.bear);
    }
    if (t > 0.75) {
      dash(tpY, PlColors.bull);
      tag('ЗАКРЫЛИ', Offset(12, tpY - 14), PlColors.bull);
    }
  }

  @override
  bool shouldRepaint(covariant _MoveReplayPainter oldDelegate) => oldDelegate.t != t;
}
