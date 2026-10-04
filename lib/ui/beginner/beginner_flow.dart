import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paper_league/data/market_feed.dart';
import 'package:paper_league/domain/models.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/l10n/s_path.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/beginner/path_ceremonies.dart';
import 'package:paper_league/ui/beginner/path_kit.dart';
import 'package:paper_league/ui/format.dart';
import 'package:paper_league/ui/widgets/candle_chart.dart';
import 'package:provider/provider.dart';

Future<void> openBeginnerFlow(BuildContext context) {
  pathTap(strong: true);
  return Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      transitionDuration: PlMotion.emphasis,
      reverseTransitionDuration: PlMotion.standard,
      pageBuilder: (_, _, _) => const BeginnerFlowScreen(),
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

/// Missions 1–4 and the first-win ceremony as one full-screen flow (no terminal chrome).
class BeginnerFlowScreen extends StatefulWidget {
  const BeginnerFlowScreen({super.key});

  @override
  State<BeginnerFlowScreen> createState() => _BeginnerFlowScreenState();
}

class _BeginnerFlowScreenState extends State<BeginnerFlowScreen> {
  late int _page;

  @override
  void initState() {
    super.initState();
    final step = context.read<DeskController>().beginnerPathStep;
    _page = step >= 5 ? 5 : step.clamp(1, 4);
  }

  void _go(int page) => setState(() => _page = page);

  void _close() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final Widget page = switch (_page) {
      1 => _CandleMission(onNext: () => _go(2), onClose: _close),
      2 => _TradeMission(onNext: () => _go(3), onClose: _close),
      3 => _StopMission(onNext: () => _go(4), onClose: _close),
      4 => _JournalMission(onNext: () => _go(5), onClose: _close),
      _ => FirstWinPanel(onDone: _close),
    };
    return Scaffold(
      backgroundColor: PlColors.bg,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: PlMotion.emphasis,
          switchInCurve: PlMotion.curveIn,
          switchOutCurve: PlMotion.curveOut,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(anim),
              child: child,
            ),
          ),
          child: KeyedSubtree(key: ValueKey(_page), child: page),
        ),
      ),
    );
  }
}

class _MissionLayout extends StatelessWidget {
  const _MissionLayout({
    required this.mission,
    required this.onClose,
    required this.body,
    required this.actions,
  });

  final int mission;
  final VoidCallback onClose;
  final List<Widget> body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MissionHeader(mission: mission, onClose: onClose),
          const SizedBox(height: 14),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _spaced(body, 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._spaced(actions, 10),
        ],
      ),
    );
  }
}

List<Widget> _spaced(List<Widget> items, double gap) => [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) SizedBox(height: gap),
        items[i],
      ],
    ];

double _chartHeight(BuildContext context) =>
    (MediaQuery.sizeOf(context).height * 0.3).clamp(190.0, 290.0);

String _base(String symbolId) {
  for (final m in MarketFeed.symbols) {
    if (m.id == symbolId) return m.base;
  }
  return symbolId.replaceAll('USDT', '');
}

String _pair(String symbolId) => '${_base(symbolId)}/USDT';

String _qty(double v) {
  final digits = v >= 100 ? 0 : (v >= 1 ? 2 : 4);
  var out = v.toStringAsFixed(digits);
  if (out.contains('.')) out = out.replaceFirst(RegExp(r'\.?0+$'), '');
  return out;
}

String _signedMoney(double v) => '${v >= 0 ? '+' : '−'}${money(v.abs())}';

String _riskPct(double r) => '${(r * 100).toStringAsFixed(1)}%';

Color _signColor(double v) => v >= 0 ? PlColors.bull : PlColors.bear;

void _toast(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 2)));
}

class _ChartBox extends StatelessWidget {
  const _ChartBox({this.entry, this.stop});

  final double? entry;
  final double? stop;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final candles = context.watch<DeskController>().candles;
    return Container(
      height: _chartHeight(context),
      decoration: BoxDecoration(
        color: PlColors.surface,
        borderRadius: BorderRadius.circular(PlRadius.lg),
        border: Border.all(color: PlColors.lineSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: candles.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: PlColors.accent),
                  ),
                  const SizedBox(height: 10),
                  Text(s.homeLoading, style: pathCapStyle),
                ],
              ),
            )
          : IgnorePointer(
              child: CandleChart(
                candles: candles,
                entry: entry,
                stop: stop,
                side: entry != null ? Side.long : null,
              ),
            ),
    );
  }
}

class _PairRow extends StatelessWidget {
  const _PairRow();

  @override
  Widget build(BuildContext context) {
    final desk = context.watch<DeskController>();
    final color = desk.markDir > 0
        ? PlColors.bull
        : desk.markDir < 0
            ? PlColors.bear
            : PlColors.text;
    return Row(
      children: [
        Text(
          _pair(desk.activeSymbol),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: PlColors.text),
        ),
        const SizedBox(width: 10),
        PathChip(desk.timeframe),
        const Spacer(),
        if (desk.mark > 0) Text(priceFmt(desk.mark), style: pathMono(size: 17, weight: FontWeight.w700, color: color)),
      ],
    );
  }
}

// ───────────────────────── Mission 1 · candle ─────────────────────────

class _CandleMission extends StatefulWidget {
  const _CandleMission({required this.onNext, required this.onClose});
  final VoidCallback onNext;
  final VoidCallback onClose;

  @override
  State<_CandleMission> createState() => _CandleMissionState();
}

class _CandleMissionState extends State<_CandleMission> {
  static const _correct = [0, 1];
  int _q = 0;
  int? _picked;

  bool get _ok => _picked == _correct[_q];
  bool get _wrong => _picked != null && !_ok;

  void _pick(int i) {
    if (_ok) return;
    pathTap();
    setState(() => _picked = i);
    if (i == _correct[_q]) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _next() async {
    pathTap(strong: true);
    if (_q == 0) {
      setState(() {
        _q = 1;
        _picked = null;
      });
      return;
    }
    await context.read<DeskController>().completeCandleMission();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final question = _q == 0 ? s.m1Q1 : s.m1Q2;
    final answers = _q == 0 ? [s.m1Q1A, s.m1Q1B] : [s.m1Q2A, s.m1Q2B];

    return _MissionLayout(
      mission: 1,
      onClose: widget.onClose,
      body: [
        Text(s.pathTitle(1), style: pathTitleStyle(context)),
        Container(
          height: 226,
          decoration: BoxDecoration(
            color: PlColors.surface,
            borderRadius: BorderRadius.circular(PlRadius.lg),
            border: Border.all(color: PlColors.lineSoft),
          ),
          child: CustomPaint(
            painter: _CandleAnatomyPainter(
              focus: _q == 0 ? _Part.close : _Part.high,
              revealed: _ok,
              labels: {
                _Part.high: s.lblHigh,
                _Part.close: s.lblClose,
                _Part.open: s.lblOpen,
                _Part.low: s.lblLow,
              },
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: PlMotion.standard,
          child: CoachBubble(_wrong ? s.m1Wrong : s.m1Coach, key: ValueKey(_wrong)),
        ),
        PathCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: PlColors.text),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${_q + 1}/2', style: pathMono(size: 12, color: PlColors.faint)),
                ],
              ),
              for (var i = 0; i < answers.length; i++)
                _AnswerTile(
                  code: String.fromCharCode(65 + i),
                  label: answers[i],
                  state: _picked != i
                      ? _AnswerState.idle
                      : (i == _correct[_q] ? _AnswerState.ok : _AnswerState.bad),
                  onTap: () => _pick(i),
                ),
            ],
          ),
        ),
      ],
      actions: [
        PathButton(
          _ok ? (_q == 0 ? s.m1Next : s.m1Finish) : s.m1Pick,
          trailingIcon: _ok ? Icons.arrow_forward_rounded : null,
          onPressed: _ok ? _next : null,
        ),
      ],
    );
  }
}

enum _AnswerState { idle, ok, bad }

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({required this.code, required this.label, required this.state, required this.onTap});

  final String code;
  final String label;
  final _AnswerState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg) = switch (state) {
      _AnswerState.ok => (PlColors.bullSoft, PlColors.bull, PathInk.bullText),
      _AnswerState.bad => (PlColors.bearSoft, PlColors.bear, const Color(0xFFFFC7CE)),
      _AnswerState.idle => (PlColors.surface2, PlColors.lineSoft, PlColors.text),
    };
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: PlMotion.micro,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Text(
                  code,
                  style: pathMono(
                    size: 13,
                    weight: FontWeight.w700,
                    color: state == _AnswerState.idle ? PlColors.faint : fg,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(label, style: TextStyle(fontSize: 15, color: fg))),
                if (state == _AnswerState.ok) const Icon(Icons.check_rounded, size: 18, color: PlColors.bull),
                if (state == _AnswerState.bad) const Icon(Icons.close_rounded, size: 18, color: PlColors.bear),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _Part { high, close, open, low }

/// One annotated green candle (from the presentation's 352×226 artboard), scaled to fit.
class _CandleAnatomyPainter extends CustomPainter {
  _CandleAnatomyPainter({required this.focus, required this.revealed, required this.labels});

  final _Part focus;
  final bool revealed;
  final Map<_Part, String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    const artW = 352.0;
    const artH = 226.0;
    final k = math.min(size.width / artW, size.height / artH);
    final dx = (size.width - artW * k) / 2;
    final dy = (size.height - artH * k) / 2;
    Offset p(double x, double y) => Offset(dx + x * k, dy + y * k);
    Rect r(double x, double y, double w, double h) => Rect.fromLTWH(dx + x * k, dy + y * k, w * k, h * k);

    // Context candles
    void ctx(double x, double hi, double lo, double top, double h, Color c) {
      canvas.drawLine(p(x, hi), p(x, lo), Paint()..color = PlColors.wick.withValues(alpha: 0.35));
      canvas.drawRRect(
        RRect.fromRectAndRadius(r(x - 7, top, 14, h), Radius.circular(2 * k)),
        Paint()..color = c.withValues(alpha: 0.35),
      );
    }

    ctx(34, 70, 150, 90, 40, PlColors.bear);
    ctx(62, 95, 175, 115, 45, PlColors.bear);
    ctx(90, 100, 190, 125, 38, PlColors.bull);

    // Highlight frame
    _dashedRRect(
      canvas,
      RRect.fromRectAndRadius(r(122, 20, 76, 188), Radius.circular(12 * k)),
      Paint()
        ..color = PlColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
      5 * k,
    );

    // Hero candle
    canvas.drawLine(
      p(160, 32),
      p(160, 196),
      Paint()
        ..color = const Color(0xFFA9B8CC)
        ..strokeWidth = 2.5 * k
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r(140, 62, 40, 100), Radius.circular(4 * k)),
      Paint()..color = PlColors.bull,
    );

    // Labels
    final rows = <(_Part, String, Offset, Offset, double, Color)>[
      (_Part.high, 'High', p(166, 32), p(232, 32), 36, PlColors.text),
      (_Part.close, 'Close', p(184, 62), p(232, 78), 82, PlColors.bull),
      (_Part.open, 'Open', p(184, 162), p(232, 148), 146, PlColors.text),
      (_Part.low, 'Low', p(166, 196), p(232, 196), 194, PlColors.text),
    ];
    for (final (part, title, a, b, baseY, color) in rows) {
      final isFocus = part == focus;
      final lineColor = isFocus && revealed
          ? PlColors.accent
          : (part == _Part.close ? PlColors.bull : PlColors.faint);
      _dashedLine(canvas, a, b, Paint()
        ..color = lineColor
        ..strokeWidth = isFocus && revealed ? 1.6 : 1, 3 * k);
      final titleColor = isFocus && revealed ? PlColors.accent : color;
      _text(canvas, title, p(238, baseY - 13), pathMono(size: 13 * k, color: titleColor));
      _text(canvas, labels[part] ?? '', p(238, baseY + 2), pathMono(size: 11 * k, weight: FontWeight.w400, color: PlColors.muted));
    }

    if (revealed) {
      final anchor = focus == _Part.close ? p(160, 62) : p(160, 32);
      canvas.drawCircle(anchor, 9 * k, Paint()..color = PlColors.accent.withValues(alpha: 0.22));
      canvas.drawCircle(anchor, 4 * k, Paint()..color = PlColors.accent);
    }
  }

  void _text(Canvas canvas, String text, Offset at, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at);
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint, double dash) {
    final total = (b - a).distance;
    if (total <= 0) return;
    final dir = (b - a) / total;
    var d = 0.0;
    while (d < total) {
      final end = math.min(d + dash, total);
      canvas.drawLine(a + dir * d, a + dir * end, paint);
      d += dash * 2;
    }
  }

  void _dashedRRect(Canvas canvas, RRect rrect, Paint paint, double dash) {
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, math.min(d + dash, metric.length)), paint);
        d += dash * 2;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CandleAnatomyPainter old) =>
      old.focus != focus || old.revealed != revealed || old.labels != labels;
}

// ───────────────────────── Mission 2 · first trade ─────────────────────────

class _TradeMission extends StatefulWidget {
  const _TradeMission({required this.onNext, required this.onClose});
  final VoidCallback onNext;
  final VoidCallback onClose;

  @override
  State<_TradeMission> createState() => _TradeMissionState();
}

class _TradeMissionState extends State<_TradeMission> {
  bool _busy = false;

  Future<void> _buy() async {
    setState(() => _busy = true);
    pathTap(strong: true);
    await context.read<DeskController>().ensureTutorialTrade();
    HapticFeedback.heavyImpact();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final desk = context.watch<DeskController>();
    final pos = desk.position;
    final opened = pos != null && desk.tutorialTrade;
    final base = _base(desk.activeSymbol);

    if (!opened) {
      final ready = desk.candles.isNotEmpty && desk.tutorialQtyPreview > 0;
      return _MissionLayout(
        mission: 2,
        onClose: widget.onClose,
        body: [
          const _PairRow(),
          const _ChartBox(),
          CoachBubble(s.m2Coach),
          PathCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: [
                KvRow(s.m2Size, ready ? '${_qty(desk.tutorialQtyPreview)} $base · ${s.m2Fixed}' : '—'),
                KvRow(s.m2Balance, money0(desk.cash), valueColor: PlColors.accent),
              ],
            ),
          ),
        ],
        actions: [
          Row(
            children: [
              Expanded(
                child: PathButton(
                  'Buy · Long',
                  tone: PathButtonTone.bull,
                  pulse: true,
                  onPressed: ready && !_busy ? _buy : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PathButton(
                  'Sell · Short',
                  tone: PathButtonTone.bear,
                  faded: true,
                  onPressed: () => _toast(context, s.m2ShortLocked),
                ),
              ),
            ],
          ),
        ],
      );
    }

    final pnl = pos.unrealized(desk.markFor(pos.symbol));
    return _MissionLayout(
      mission: 2,
      onClose: widget.onClose,
      body: [
        PathBanner(
          tone: PathTone.bull,
          icon: Icons.check_rounded,
          title: s.m2OpenedTitle,
          body: s.m2OpenedBody,
        ),
        _ChartBox(entry: pos.entry),
        PathCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            children: [
              KvRow(s.m2Position, 'LONG ${_qty(pos.qty)} ${_base(pos.symbol)}', valueColor: PlColors.bull),
              KvRow(s.m2Entry, priceFmt(pos.entry)),
              KvRow(s.m2PnlNow, '${_signedMoney(pnl)} ${s.practice}', valueColor: _signColor(pnl)),
            ],
          ),
        ),
        CoachBubble(s.m2CoachAfter),
      ],
      actions: [
        PathButton(
          s.m2Next,
          trailingIcon: Icons.arrow_forward_rounded,
          onPressed: () {
            pathTap(strong: true);
            widget.onNext();
          },
        ),
      ],
    );
  }
}

// ───────────────────────── Mission 3 · stop ─────────────────────────

class _StopMission extends StatefulWidget {
  const _StopMission({required this.onNext, required this.onClose});
  final VoidCallback onNext;
  final VoidCallback onClose;

  @override
  State<_StopMission> createState() => _StopMissionState();
}

class _StopMissionState extends State<_StopMission> {
  static const _risks = [0.005, 0.01, 0.02];
  bool _editing = false;
  double _risk = 0.01;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final desk = context.read<DeskController>();
      if (desk.position == null) desk.ensureTutorialTrade();
    });
  }

  void _confirm() {
    pathTap(strong: true);
    context.read<DeskController>().placeTutorialStop(riskPct: _risk);
    HapticFeedback.heavyImpact();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final desk = context.watch<DeskController>();
    final pos = desk.position;

    if (pos == null) {
      return _MissionLayout(
        mission: 3,
        onClose: widget.onClose,
        body: const [_ChartBox()],
        actions: [PathButton(s.m3Place)],
      );
    }

    if (!_editing) {
      return _MissionLayout(
        mission: 3,
        onClose: widget.onClose,
        body: [
          PathBanner(
            tone: PathTone.warn,
            icon: Icons.warning_amber_rounded,
            title: s.m3WarnTitle,
            body: s.m3WarnBody,
          ),
          _ChartBox(entry: pos.entry),
          PathCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: [
                KvRow(s.m3Risk, s.m3Unlimited, valueColor: PlColors.bear),
                KvRow(s.m3Stop, '—', valueColor: PlColors.bear),
              ],
            ),
          ),
        ],
        actions: [
          PathButton(
            s.m3Place,
            icon: Icons.shield_outlined,
            pulse: true,
            onPressed: () {
              pathTap(strong: true);
              setState(() => _editing = true);
            },
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.heavyImpact();
              _toast(context, s.m3Blocked);
            },
            child: PathButton(s.m3Finish),
          ),
        ],
      );
    }

    final stop = desk.tutorialStopFor(_risk);
    return _MissionLayout(
      mission: 3,
      onClose: widget.onClose,
      body: [
        _ChartBox(entry: pos.entry, stop: stop),
        PathCard(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Text(s.m3RiskPer, style: const TextStyle(fontSize: 14, color: PlColors.muted)),
                  const Spacer(),
                  Text(
                    '${_riskPct(_risk)} · −${money0(desk.equity * _risk)}',
                    style: pathMono(color: PlColors.accent),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final r in _risks) ...[
                    if (r != _risks.first) const SizedBox(width: 8),
                    Expanded(
                      child: SelectTile(
                        label: r == 0.005 ? '0.5%' : '${(r * 100).round()}%',
                        on: r == _risk,
                        onTap: () {
                          pathTap();
                          setState(() => _risk = r);
                        },
                      ),
                    ),
                  ],
                ],
              ),
              if (stop != null) ...[
                const SizedBox(height: 6),
                KvRow(s.m3Stop, priceFmt(stop), valueColor: PlColors.bear),
              ],
            ],
          ),
        ),
        CoachBubble(s.m3Coach),
      ],
      actions: [
        PathButton(s.m3Confirm, onPressed: stop == null ? null : _confirm),
      ],
    );
  }
}

// ───────────────────────── Mission 4 · close + journal ─────────────────────────

class _JournalMission extends StatefulWidget {
  const _JournalMission({required this.onNext, required this.onClose});
  final VoidCallback onNext;
  final VoidCallback onClose;

  @override
  State<_JournalMission> createState() => _JournalMissionState();
}

class _JournalMissionState extends State<_JournalMission> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final desk = context.read<DeskController>();
      if (desk.position == null && desk.lastTutorialTrade == null) {
        await desk.ensureTutorialTrade();
        desk.placeTutorialStop(riskPct: desk.tutorialRiskPct);
      }
    });
  }

  void _close() {
    pathTap(strong: true);
    context.read<DeskController>().closePosition();
    HapticFeedback.heavyImpact();
  }

  Future<void> _accept() async {
    if (_busy) return;
    setState(() => _busy = true);
    pathTap(strong: true);
    await context.read<DeskController>().finishBeginnerPath();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final desk = context.watch<DeskController>();
    final trade = desk.lastTutorialTrade;
    final pos = desk.position;

    if (trade != null) return _journal(context, s, desk, trade);

    if (pos == null) {
      return _MissionLayout(
        mission: 4,
        onClose: widget.onClose,
        body: const [_ChartBox()],
        actions: [PathButton(s.m4Close)],
      );
    }

    final pnl = pos.unrealized(desk.markFor(pos.symbol));
    return _MissionLayout(
      mission: 4,
      onClose: widget.onClose,
      body: [
        PathBanner(
          tone: PathTone.bull,
          icon: Icons.shield_outlined,
          title: s.m4LiveTitle,
          body: s.m4LiveBody,
        ),
        _ChartBox(entry: pos.entry, stop: pos.stop),
        PathCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            children: [
              KvRow(s.m2Position, 'LONG ${_qty(pos.qty)} ${_base(pos.symbol)}', valueColor: PlColors.bull),
              KvRow(s.m3RiskPer, _riskPct(desk.tutorialRiskPct), valueColor: PlColors.accent),
              KvRow(s.m3Stop, priceFmt(pos.stop), valueColor: PlColors.bear),
              KvRow(s.m2PnlNow, '${_signedMoney(pnl)} ${s.practice}', valueColor: _signColor(pnl)),
            ],
          ),
        ),
      ],
      actions: [PathButton(s.m4Close, onPressed: _close)],
    );
  }

  Widget _journal(BuildContext context, S s, DeskController desk, ClosedTrade trade) {
    final riskOk = desk.tutorialRiskPct <= 0.0101;
    final score = riskOk ? 3 : 2;
    final pctOfBalance = trade.pnl / DeskController.startingCash * 100;
    final pnlColor = _signColor(trade.pnl);

    return _MissionLayout(
      mission: 4,
      onClose: widget.onClose,
      body: [
        Text(s.m4Title, style: pathTitleStyle(context)),
        PathCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.m4ClosedCap(_pair(trade.symbol)), style: pathCapStyle),
                    const SizedBox(height: 6),
                    Text(
                      _signedMoney(trade.pnl),
                      style: pathMono(size: 26, weight: FontWeight.w700, color: pnlColor),
                    ),
                  ],
                ),
              ),
              PathChip(
                '${pctPoints(pctOfBalance)} ${s.practice}',
                tone: trade.pnl >= 0 ? PathTone.bull : PathTone.bear,
              ),
            ],
          ),
        ),
        PathCard(
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    s.m4Discipline,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: PlColors.text),
                  ),
                  const Spacer(),
                  Text('$score / 3', style: pathMono(size: 20, weight: FontWeight.w700, color: PlColors.accent)),
                ],
              ),
              const SizedBox(height: 4),
              CheckLine(s.m4Check1),
              CheckLine(
                riskOk ? s.m4RiskOk(_riskPct(desk.tutorialRiskPct).replaceAll('%', ''))
                    : s.m4RiskHigh(_riskPct(desk.tutorialRiskPct).replaceAll('%', '')),
                ok: riskOk,
              ),
              CheckLine(s.m4Check3, divider: false),
            ],
          ),
        ),
        PathCard(
          accent: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.m4Takeaway, style: pathCapStyle.copyWith(color: PlColors.accent)),
              const SizedBox(height: 8),
              Text(
                riskOk ? s.m4TakeawayBody : s.m4TakeawayRisk,
                style: const TextStyle(fontSize: 17, height: 1.45, fontWeight: FontWeight.w500, color: PlColors.text),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_rounded, size: 14, color: PlColors.faint),
            const SizedBox(width: 6),
            Text(s.m4Saved, style: pathFineStyle),
          ],
        ),
      ],
      actions: [PathButton(s.m4Accept, onPressed: _busy ? null : _accept)],
    );
  }
}
