import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paper_league/domain/models.dart';
import 'package:paper_league/theme/tokens.dart';

enum ChartTool { pointer, level, line, erase }

enum _ShapeKind { level, line }

enum _DragKind { none, pan, stop, tp, shapeLevel, shapeLine }

class _Shape {
  _Shape.level(this.price)
      : kind = _ShapeKind.level,
        a0 = 0,
        p0 = price,
        a1 = 0,
        p1 = price;

  _Shape.line({
    required this.a0,
    required this.p0,
    required this.a1,
    required this.p1,
  })  : kind = _ShapeKind.line,
        price = p0;

  final _ShapeKind kind;
  double price;
  /// Absolute indices into the full candle series.
  int a0;
  double p0;
  int a1;
  double p1;
}

class CandleChart extends StatefulWidget {
  const CandleChart({
    super.key,
    required this.candles,
    this.entry,
    this.stop,
    this.tp,
    this.side,
    this.tool = ChartTool.pointer,
    this.onStopDrag,
    this.onTpDrag,
    this.seedLevels = const [],
    this.seedToken = 0,
  });

  final List<Candle> candles;
  final double? entry;
  final double? stop;
  final double? tp;
  final Side? side;
  final ChartTool tool;
  final ValueChanged<double>? onStopDrag;
  final ValueChanged<double>? onTpDrag;
  /// Absolute price levels injected from playbooks.
  final List<double> seedLevels;
  final int seedToken;

  @override
  State<CandleChart> createState() => _CandleChartState();
}

class _CandleChartState extends State<CandleChart> {
  static const _window = 80;

  final List<_Shape> _shapes = [];
  int _shapesEpoch = 0;
  Offset? _cross;
  Offset? _draftStart;
  Offset? _draftEnd;
  _ChartMetrics? _metrics;
  Candle? _inspect;

  /// Continuous candles clipped from the live edge.
  double _panFromEnd = 0;
  bool _followLive = true;

  _DragKind _drag = _DragKind.none;
  int? _dragShapeIndex;
  double _lastDx = 0;

  @override
  void initState() {
    super.initState();
    if (widget.seedLevels.isNotEmpty) {
      _shapes.addAll(widget.seedLevels.map(_Shape.level));
    }
  }

  int get _endIndex {
    final all = widget.candles;
    if (all.isEmpty) return 0;
    if (_followLive) return all.length;
    final maxPan = math.max(0.0, all.length - _window.toDouble());
    final clipped = _panFromEnd.clamp(0.0, maxPan);
    return (all.length - clipped).round().clamp(_window, all.length);
  }

  int get _startIndex {
    final end = _endIndex;
    return (end - _window).clamp(0, end);
  }

  List<Candle> get _visible {
    final all = widget.candles;
    if (all.isEmpty) return const [];
    return all.sublist(_startIndex, _endIndex);
  }

  @override
  void didUpdateWidget(covariant CandleChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_followLive) _panFromEnd = 0;
    if (widget.candles.length != oldWidget.candles.length && _followLive) {
      // keep inspect on last bar when live
      if (_inspect != null && widget.candles.isNotEmpty) {
        _inspect = widget.candles.last;
      }
    }
    if (widget.seedToken != oldWidget.seedToken) {
      _shapes
        ..clear()
        ..addAll(widget.seedLevels.map(_Shape.level));
      _shapesEpoch++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return ClipRRect(
      borderRadius: BorderRadius.circular(PlRadius.md),
      child: ColoredBox(
        color: PlColors.bgElevated,
        child: visible.isEmpty
            ? Center(
                child: Text(
                  '…',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PlColors.muted),
                ),
              )
            : LayoutBuilder(
                builder: (context, box) {
                  _metrics = _ChartMetrics.from(
                    size: Size(box.maxWidth, box.maxHeight),
                    visible: visible,
                    entry: widget.entry,
                    stop: widget.stop,
                    tp: widget.tp,
                    shapes: _shapes,
                  );
                  return GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    onTapUp: _onTap,
                    child: Stack(
                      children: [
                        RepaintBoundary(
                          child: CustomPaint(
                            size: Size(box.maxWidth, box.maxHeight),
                            painter: _CandlePainter(
                              metrics: _metrics!,
                              shapes: _shapes,
                              shapesEpoch: _shapesEpoch,
                              tool: widget.tool,
                              dragging: _drag,
                              startAbs: _startIndex,
                              entry: widget.entry,
                              stop: widget.stop,
                              tp: widget.tp,
                              cross: _cross,
                              draftStart: _draftStart,
                              draftEnd: _draftEnd,
                              inspect: _inspect,
                            ),
                          ),
                        ),
                        if (!_followLive)
                          Positioned(
                            right: 66,
                            top: 10,
                            child: Material(
                              color: PlColors.accent,
                              borderRadius: BorderRadius.circular(PlRadius.sm),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(PlRadius.sm),
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _followLive = true;
                                    _panFromEnd = 0;
                                    _cross = null;
                                    if (widget.candles.isNotEmpty) {
                                      _inspect = widget.candles.last;
                                    }
                                  });
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  child: Text(
                                    'LIVE',
                                    style: TextStyle(
                                      color: PlColors.onAccent,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _onPanStart(DragStartDetails d) {
    final m = _metrics;
    if (m == null) return;
    final pos = d.localPosition;
    _lastDx = pos.dx;

    if (widget.tool == ChartTool.erase) {
      _eraseNear(pos);
      return;
    }
    if (widget.tool == ChartTool.level) {
      setState(() {
        _drag = _DragKind.none;
        _draftStart = pos;
        _draftEnd = pos;
      });
      return;
    }
    if (widget.tool == ChartTool.line) {
      setState(() {
        _draftStart = pos;
        _draftEnd = pos;
      });
      return;
    }

    final hit = _hitTest(pos, m);
    setState(() {
      _drag = hit.$1;
      _dragShapeIndex = hit.$2;
      if (_drag == _DragKind.none || _drag == _DragKind.pan) {
        _drag = _DragKind.pan;
        _cross = pos;
        _inspect = _candleAt(pos, m);
      } else {
        HapticFeedback.selectionClick();
      }
    });
  }

  (_DragKind, int?) _hitTest(Offset pos, _ChartMetrics m) {
    const thr = 22.0;
    if (widget.stop != null && (m.yFor(widget.stop!) - pos.dy).abs() < thr) {
      return (_DragKind.stop, null);
    }
    if (widget.tp != null && (m.yFor(widget.tp!) - pos.dy).abs() < thr) {
      return (_DragKind.tp, null);
    }
    for (var i = _shapes.length - 1; i >= 0; i--) {
      final s = _shapes[i];
      if (s.kind == _ShapeKind.level) {
        if ((m.yFor(s.price) - pos.dy).abs() < thr) return (_DragKind.shapeLevel, i);
      } else {
        final i0 = s.a0 - _startIndex;
        final i1 = s.a1 - _startIndex;
        if (i0 < 0 && i1 < 0) continue;
        if (i0 >= m.visible.length && i1 >= m.visible.length) continue;
        final dist = _distToSegment(
          pos,
          Offset(m.xFor(i0.clamp(0, m.visible.length - 1)), m.yFor(s.p0)),
          Offset(m.xFor(i1.clamp(0, m.visible.length - 1)), m.yFor(s.p1)),
        );
        if (dist < thr) return (_DragKind.shapeLine, i);
      }
    }
    return (_DragKind.pan, null);
  }

  Candle? _candleAt(Offset pos, _ChartMetrics m) {
    final i = m.indexFor(pos.dx);
    if (i < 0 || i >= m.visible.length) return null;
    return m.visible[i];
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final m = _metrics;
    if (m == null) return;
    final pos = d.localPosition;

    if (widget.tool == ChartTool.level || widget.tool == ChartTool.line) {
      setState(() => _draftEnd = pos);
      return;
    }
    if (widget.tool == ChartTool.erase) {
      _eraseNear(pos);
      return;
    }

    switch (_drag) {
      case _DragKind.pan:
        final dx = pos.dx - _lastDx;
        _lastDx = pos.dx;
        setState(() {
          _followLive = false;
          final maxPan = math.max(0.0, widget.candles.length - _window.toDouble());
          _panFromEnd = (_panFromEnd - dx / m.slot).clamp(0.0, maxPan);
          if (_panFromEnd < 0.15) {
            _followLive = true;
            _panFromEnd = 0;
          }
          _cross = pos;
          _inspect = _candleAt(pos, m);
        });
        break;
      case _DragKind.stop:
        widget.onStopDrag?.call(m.priceFor(pos.dy));
        break;
      case _DragKind.tp:
        widget.onTpDrag?.call(m.priceFor(pos.dy));
        break;
      case _DragKind.shapeLevel:
        final i = _dragShapeIndex;
        if (i != null && i < _shapes.length) {
          setState(() {
            final p = m.priceFor(pos.dy);
            _shapes[i].price = p;
            _shapes[i].p0 = p;
            _shapes[i].p1 = p;
            _shapesEpoch++;
          });
        }
        break;
      case _DragKind.shapeLine:
        final i = _dragShapeIndex;
        if (i != null && i < _shapes.length) {
          final dyPrice = m.priceFor(pos.dy) - m.priceFor(pos.dy - d.delta.dy);
          setState(() {
            _shapes[i].p0 += dyPrice;
            _shapes[i].p1 += dyPrice;
            _shapes[i].price = _shapes[i].p0;
            final di = (d.delta.dx / m.slot).round();
            if (di != 0) {
              final maxA = widget.candles.length - 1;
              _shapes[i].a0 = (_shapes[i].a0 + di).clamp(0, maxA);
              _shapes[i].a1 = (_shapes[i].a1 + di).clamp(0, maxA);
            }
            _shapesEpoch++;
          });
        }
        break;
      case _DragKind.none:
        break;
    }
  }

  void _onPanEnd(DragEndDetails d) {
    final m = _metrics;
    final a = _draftStart;
    final b = _draftEnd;

    if (widget.tool == ChartTool.level && a != null && m != null) {
      setState(() {
        _shapes.add(_Shape.level(m.priceFor(a.dy)));
        _shapesEpoch++;
        _draftStart = null;
        _draftEnd = null;
      });
      HapticFeedback.selectionClick();
    } else if (widget.tool == ChartTool.line && a != null && b != null && m != null) {
      setState(() {
        _shapes.add(
          _Shape.line(
            a0: _startIndex + m.indexFor(a.dx),
            p0: m.priceFor(a.dy),
            a1: _startIndex + m.indexFor(b.dx),
            p1: m.priceFor(b.dy),
          ),
        );
        _shapesEpoch++;
        _draftStart = null;
        _draftEnd = null;
      });
      HapticFeedback.selectionClick();
    }

    setState(() {
      // Keep crosshair/inspect after pan for analysis.
      if (_drag != _DragKind.pan) {
        _cross = null;
      }
      _drag = _DragKind.none;
      _dragShapeIndex = null;
      _draftStart = null;
      _draftEnd = null;
    });
  }

  void _onTap(TapUpDetails d) {
    if (widget.tool == ChartTool.erase) {
      _eraseNear(d.localPosition);
      return;
    }
    final m = _metrics;
    if (m == null) return;
    if (widget.tool == ChartTool.level) {
      setState(() {
        _shapes.add(_Shape.level(m.priceFor(d.localPosition.dy)));
        _shapesEpoch++;
      });
      HapticFeedback.selectionClick();
      return;
    }
    if (widget.tool == ChartTool.pointer) {
      setState(() {
        _cross = d.localPosition;
        _inspect = _candleAt(d.localPosition, m);
      });
    }
  }

  void _eraseNear(Offset pos) {
    final m = _metrics;
    if (m == null || _shapes.isEmpty) return;
    var best = -1;
    var bestDist = 28.0;
    for (var i = 0; i < _shapes.length; i++) {
      final s = _shapes[i];
      final dist = switch (s.kind) {
        _ShapeKind.level => (m.yFor(s.price) - pos.dy).abs(),
        _ShapeKind.line => _distToSegment(
            pos,
            Offset(m.xFor((s.a0 - _startIndex).clamp(0, m.visible.length - 1)), m.yFor(s.p0)),
            Offset(m.xFor((s.a1 - _startIndex).clamp(0, m.visible.length - 1)), m.yFor(s.p1)),
          ),
      };
      if (dist < bestDist) {
        bestDist = dist;
        best = i;
      }
    }
    if (best >= 0) {
      setState(() {
        _shapes.removeAt(best);
        _shapesEpoch++;
      });
      HapticFeedback.lightImpact();
    }
  }

  double _distToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / (ab.distanceSquared + 1e-9)).clamp(0.0, 1.0);
    return (p - (a + ab * t)).distance;
  }
}

class _ChartMetrics {
  _ChartMetrics({
    required this.size,
    required this.visible,
    required this.minP,
    required this.maxP,
    required this.plotW,
    required this.chartTop,
    required this.chartH,
    required this.volH,
  });

  final Size size;
  final List<Candle> visible;
  final double minP;
  final double maxP;
  final double plotW;
  final double chartTop;
  final double chartH;
  final double volH;

  static const rightAxis = 58.0;
  static const topPad = 10.0;
  static const bottomPad = 6.0;

  factory _ChartMetrics.from({
    required Size size,
    required List<Candle> visible,
    double? entry,
    double? stop,
    double? tp,
    List<_Shape> shapes = const [],
  }) {
    final volH = size.height * 0.14;
    const chartTop = topPad;
    final chartH = size.height - volH - bottomPad - chartTop;
    final plotW = size.width - rightAxis;

    var minP = visible.first.low;
    var maxP = visible.first.high;
    for (final c in visible) {
      minP = math.min(minP, c.low);
      maxP = math.max(maxP, c.high);
    }
    for (final p in [entry, stop, tp]) {
      if (p == null) continue;
      minP = math.min(minP, p);
      maxP = math.max(maxP, p);
    }
    for (final s in shapes) {
      if (s.kind == _ShapeKind.level) {
        minP = math.min(minP, s.price);
        maxP = math.max(maxP, s.price);
      } else {
        minP = math.min(minP, math.min(s.p0, s.p1));
        maxP = math.max(maxP, math.max(s.p0, s.p1));
      }
    }
    var pad = (maxP - minP) * 0.14;
    if (pad <= 0) pad = maxP * 0.005;
    return _ChartMetrics(
      size: size,
      visible: visible,
      minP: minP - pad,
      maxP: maxP + pad,
      plotW: plotW,
      chartTop: chartTop,
      chartH: chartH,
      volH: volH,
    );
  }

  double get range => (maxP - minP).clamp(1e-9, double.infinity);
  double get slot => plotW / visible.length;

  double yFor(double price) {
    final t = ((price - minP) / range).clamp(0.0, 1.0);
    return chartTop + chartH * (1 - t);
  }

  double priceFor(double y) {
    final t = ((y - chartTop) / chartH).clamp(0.0, 1.0);
    return maxP - t * range;
  }

  double xFor(int index) => slot * index.clamp(0, visible.length - 1) + slot / 2;
  int indexFor(double x) => (x / slot).floor().clamp(0, visible.length - 1);
}

class _CandlePainter extends CustomPainter {
  _CandlePainter({
    required this.metrics,
    required this.shapes,
    required this.shapesEpoch,
    required this.tool,
    required this.dragging,
    required this.startAbs,
    this.entry,
    this.stop,
    this.tp,
    this.cross,
    this.draftStart,
    this.draftEnd,
    this.inspect,
  });

  final _ChartMetrics metrics;
  final List<_Shape> shapes;
  final int shapesEpoch;
  final ChartTool tool;
  final _DragKind dragging;
  final int startAbs;
  final double? entry;
  final double? stop;
  final double? tp;
  final Offset? cross;
  final Offset? draftStart;
  final Offset? draftEnd;
  final Candle? inspect;

  @override
  void paint(Canvas canvas, Size size) {
    final m = metrics;
    final visible = m.visible;
    final plotW = m.plotW;

    // Depth gradient
    final bg = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, size.height),
        [PlColors.bgElevated, const Color(0xFF05080F)],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    if (entry != null && stop != null) {
      final y1 = m.yFor(entry!);
      final y2 = m.yFor(stop!);
      canvas.drawRect(
        Rect.fromLTRB(0, math.min(y1, y2), plotW, math.max(y1, y2)),
        Paint()..color = PlColors.bear.withValues(alpha: 0.08),
      );
    }
    if (entry != null && tp != null) {
      final y1 = m.yFor(entry!);
      final y2 = m.yFor(tp!);
      canvas.drawRect(
        Rect.fromLTRB(0, math.min(y1, y2), plotW, math.max(y1, y2)),
        Paint()..color = PlColors.bull.withValues(alpha: 0.08),
      );
    }

    final grid = Paint()
      ..color = PlColors.grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = m.chartTop + m.chartH * i / 4;
      canvas.drawLine(Offset(0, y), Offset(plotW, y), grid);
      _text(
        canvas,
        _fmt(m.maxP - m.range * i / 4),
        Offset(plotW + 6, y - 6),
        const TextStyle(color: PlColors.faint, fontSize: 10, fontWeight: FontWeight.w600),
      );
    }

    // Volume separator
    final volTop = size.height - m.volH - _ChartMetrics.bottomPad;
    canvas.drawLine(
      Offset(0, volTop),
      Offset(plotW, volTop),
      Paint()
        ..color = PlColors.lineSoft
        ..strokeWidth = 1,
    );

    var maxV = 1.0;
    for (final c in visible) {
      maxV = math.max(maxV, c.volume);
    }
    final slot = m.slot;
    final volBase = size.height - _ChartMetrics.bottomPad;
    for (var i = 0; i < visible.length; i++) {
      final c = visible[i];
      final h = (c.volume / maxV) * (m.volH - 8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(slot * i + slot * 0.18, volBase - h, slot * 0.64, h),
          const Radius.circular(1),
        ),
        Paint()..color = (c.isBull ? PlColors.bull : PlColors.bear).withValues(alpha: 0.28),
      );
    }

    final bodyW = (slot * 0.68).clamp(2.6, 10.5);
    for (var i = 0; i < visible.length; i++) {
      final c = visible[i];
      final cx = slot * i + slot / 2;
      final color = c.isBull ? PlColors.bull : PlColors.bear;
      canvas.drawLine(
        Offset(cx, m.yFor(c.high)),
        Offset(cx, m.yFor(c.low)),
        Paint()
          ..color = PlColors.wick.withValues(alpha: 0.85)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset(cx, m.yFor(c.high)),
        Offset(cx, m.yFor(c.low)),
        Paint()
          ..color = color.withValues(alpha: 0.55)
          ..strokeWidth = 1.1
          ..strokeCap = StrokeCap.round,
      );
      final top = math.min(m.yFor(c.open), m.yFor(c.close));
      final bot = math.max(m.yFor(c.open), m.yFor(c.close));
      final bodyH = math.max(bot - top, 1.5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, top + bodyH / 2), width: bodyW, height: bodyH),
          const Radius.circular(1.5),
        ),
        Paint()..color = color,
      );
    }

    for (final s in shapes) {
      if (s.kind == _ShapeKind.level) {
        final thick = dragging == _DragKind.shapeLevel;
        _dashH(canvas, m.yFor(s.price), plotW, PlColors.accent, thick ? 2.2 : 1.15);
        _pill(canvas, plotW, m.yFor(s.price), 'LVL ${_fmt(s.price)}', PlColors.accent, m);
      } else {
        final i0 = (s.a0 - startAbs).clamp(0, visible.length - 1);
        final i1 = (s.a1 - startAbs).clamp(0, visible.length - 1);
        canvas.drawLine(
          Offset(m.xFor(i0), m.yFor(s.p0)),
          Offset(m.xFor(i1), m.yFor(s.p1)),
          Paint()
            ..color = PlColors.warn
            ..strokeWidth = dragging == _DragKind.shapeLine ? 2.4 : 1.6
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    if (draftStart != null && draftEnd != null) {
      if (tool == ChartTool.level) {
        _dashH(canvas, draftStart!.dy, plotW, PlColors.accent.withValues(alpha: 0.7), 1.4);
      } else if (tool == ChartTool.line) {
        canvas.drawLine(
          draftStart!,
          draftEnd!,
          Paint()
            ..color = PlColors.warn.withValues(alpha: 0.85)
            ..strokeWidth = 1.6,
        );
      }
    }

    void level(double? price, Color color, String tag, bool active) {
      if (price == null) return;
      final y = m.yFor(price);
      _dashH(canvas, y, plotW, color, active ? 2.6 : 1.2);
      _pill(canvas, plotW, y, '$tag ${_fmt(price)}', color, m);
      if (active) {
        canvas.drawCircle(
          Offset(12, y),
          4.5,
          Paint()..color = color,
        );
      }
    }

    level(entry, PlColors.accent, 'IN', false);
    level(tp, PlColors.bull, 'TP', dragging == _DragKind.tp);
    level(stop, PlColors.bear, 'SL', dragging == _DragKind.stop);

    final last = visible.last.close;
    final ly = m.yFor(last);
    canvas.drawLine(
      Offset(0, ly),
      Offset(plotW, ly),
      Paint()
        ..color = PlColors.accent.withValues(alpha: 0.35)
        ..strokeWidth = 1,
    );
    // Soft pulse ring on live last
    canvas.drawCircle(Offset(plotW - 8, ly), 5, Paint()..color = PlColors.accent.withValues(alpha: 0.18));
    canvas.drawCircle(Offset(plotW - 8, ly), 2.5, Paint()..color = PlColors.accent);

    final lastTp = TextPainter(
      text: TextSpan(
        text: _fmt(last),
        style: const TextStyle(color: PlColors.onAccent, fontSize: 10.5, fontWeight: FontWeight.w800),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(plotW + 2, ly - 10, _ChartMetrics.rightAxis - 4, 20),
        const Radius.circular(5),
      ),
      Paint()..color = PlColors.accent,
    );
    lastTp.paint(canvas, Offset(plotW + 7, ly - 6));

    final cxy = cross;
    if (cxy != null && cxy.dx <= plotW) {
      final cx = cxy.dx.clamp(0.0, plotW);
      final cy = cxy.dy.clamp(m.chartTop, m.chartTop + m.chartH);
      final hair = Paint()
        ..color = PlColors.crosshair.withValues(alpha: 0.45)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(cx, m.chartTop), Offset(cx, volTop), hair);
      canvas.drawLine(Offset(0, cy), Offset(plotW, cy), hair);
      canvas.drawCircle(Offset(cx, cy), 3.2, Paint()..color = PlColors.accent);
    }

    final bar = inspect;
    if (bar != null) {
      final ohlc =
          'O ${_fmt(bar.open)}  H ${_fmt(bar.high)}  L ${_fmt(bar.low)}  C ${_fmt(bar.close)}';
      final tp = TextPainter(
        text: TextSpan(
          text: ohlc,
          style: TextStyle(
            color: bar.isBull ? PlColors.bull : PlColors.bear,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            fontFamily: 'JetBrains Mono',
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: plotW - 16);
      final bw = tp.width + 14;
      final bh = 22.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(8, 8, bw, bh), const Radius.circular(6)),
        Paint()..color = PlColors.surface.withValues(alpha: 0.92),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(8, 8, bw, bh), const Radius.circular(6)),
        Paint()
          ..color = PlColors.lineSoft
          ..style = PaintingStyle.stroke,
      );
      tp.paint(canvas, const Offset(15, 13));
    }
  }

  void _dashH(Canvas canvas, double y, double plotW, Color color, double width) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width;
    const dash = 4.0;
    var x = 0.0;
    while (x < plotW) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + dash, plotW), y), paint);
      x += dash * 1.8;
    }
  }

  void _pill(Canvas canvas, double plotW, double y, String label, Color color, _ChartMetrics m) {
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: PlColors.onAccent, fontSize: 9.5, fontWeight: FontWeight.w800),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    final w = tp.width + 10;
    const h = 17.0;
    final py = y.clamp(m.chartTop + 2, m.chartTop + m.chartH - h - 2);
    final px = plotW - w - 4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(px, py, w, h), const Radius.circular(4)),
      Paint()..color = color,
    );
    tp.paint(canvas, Offset(px + 5, py + 3));
  }

  void _text(Canvas canvas, String text, Offset at, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: ui.TextDirection.ltr)
      ..layout();
    tp.paint(canvas, at);
  }

  String _fmt(double v) {
    if (v >= 1000) return v.toStringAsFixed(1);
    if (v >= 100) return v.toStringAsFixed(2);
    if (v >= 1) return v.toStringAsFixed(3);
    return v.toStringAsFixed(5);
  }

  @override
  bool shouldRepaint(covariant _CandlePainter old) {
    return old.metrics.visible.length != metrics.visible.length ||
        old.metrics.minP != metrics.minP ||
        old.metrics.maxP != metrics.maxP ||
        old.entry != entry ||
        old.stop != stop ||
        old.tp != tp ||
        old.cross != cross ||
        old.draftStart != draftStart ||
        old.draftEnd != draftEnd ||
        old.dragging != dragging ||
        old.tool != tool ||
        old.startAbs != startAbs ||
        old.inspect != inspect ||
        old.shapesEpoch != shapesEpoch ||
        old.shapes.length != shapes.length ||
        (metrics.visible.isNotEmpty &&
            old.metrics.visible.isNotEmpty &&
            metrics.visible.last.close != old.metrics.visible.last.close);
  }
}
