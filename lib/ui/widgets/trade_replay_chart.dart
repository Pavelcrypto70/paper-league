import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:paper_league/domain/models.dart';
import 'package:paper_league/theme/tokens.dart';

/// Trade path replay — IN/OUT sit on the same price scale as candles.
class TradeReplayChart extends StatelessWidget {
  const TradeReplayChart({super.key, required this.trade});

  final ClosedTrade trade;

  @override
  Widget build(BuildContext context) {
    final tape = trade.tape;
    if (tape.length < 2) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: PlColors.bgElevated,
          borderRadius: BorderRadius.circular(PlRadius.md),
          border: Border.all(color: PlColors.lineSoft),
        ),
        child: Text('—', style: Theme.of(context).textTheme.bodySmall),
      );
    }

    return Container(
      height: 210,
      decoration: BoxDecoration(
        color: PlColors.bgElevated,
        borderRadius: BorderRadius.circular(PlRadius.md),
        border: Border.all(color: PlColors.lineSoft),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PlRadius.md),
        child: CustomPaint(
          painter: _ReplayPainter(trade: trade),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _ReplayPainter extends CustomPainter {
  _ReplayPainter({required this.trade});
  final ClosedTrade trade;

  @override
  void paint(Canvas canvas, Size size) {
    final tape = trade.tape;
    final ei = trade.entryIndex.clamp(0, tape.length - 1);
    final xi = trade.exitIndex.clamp(0, tape.length - 1);
    final lo = math.min(ei, xi);
    final hi = math.max(ei, xi);

    const padL = 10.0;
    const padR = 54.0;
    const padT = 22.0;
    const padB = 28.0;
    final plotW = size.width - padL - padR;
    final plotH = size.height - padT - padB;

    // Scale from the TRADE PATH only (+ stop/tp), not unrelated context wicks.
    var minP = math.min(trade.entry, trade.exit);
    var maxP = math.max(trade.entry, trade.exit);
    for (var i = lo; i <= hi; i++) {
      minP = math.min(minP, tape[i].low);
      maxP = math.max(maxP, tape[i].high);
    }
    // Light context bars — still include, but don't explode scale with outliers far from path.
    for (var i = 0; i < tape.length; i++) {
      if (i >= lo && i <= hi) continue;
      final c = tape[i];
      final mid = (c.high + c.low) / 2;
      if (mid < minP || mid > maxP) continue;
      minP = math.min(minP, c.low);
      maxP = math.max(maxP, c.high);
    }
    if (trade.stop != null) {
      minP = math.min(minP, trade.stop!);
      maxP = math.max(maxP, trade.stop!);
    }
    if (trade.tp != null) {
      minP = math.min(minP, trade.tp!);
      maxP = math.max(maxP, trade.tp!);
    }

    var pad = (maxP - minP) * 0.18;
    if (pad <= 0) pad = math.max(trade.entry.abs() * 0.004, 1e-6);
    minP -= pad;
    maxP += pad;
    final range = (maxP - minP).clamp(1e-12, double.infinity);

    double yFor(double p) => padT + plotH * (1 - ((p - minP) / range).clamp(0.0, 1.0));
    final slot = plotW / tape.length;

    // Shade trade window
    final winL = padL + slot * lo;
    final winR = padL + slot * (hi + 1);
    canvas.drawRect(
      Rect.fromLTRB(winL, padT, winR, padT + plotH),
      Paint()..color = PlColors.accent.withValues(alpha: 0.05),
    );

    // Stop / TP bands (subtle)
    if (trade.stop != null) {
      final y1 = yFor(trade.entry);
      final y2 = yFor(trade.stop!);
      canvas.drawRect(
        Rect.fromLTRB(winL, math.min(y1, y2), winR, math.max(y1, y2)),
        Paint()..color = PlColors.bear.withValues(alpha: 0.1),
      );
    }
    if (trade.tp != null) {
      final y1 = yFor(trade.entry);
      final y2 = yFor(trade.tp!);
      canvas.drawRect(
        Rect.fromLTRB(winL, math.min(y1, y2), winR, math.max(y1, y2)),
        Paint()..color = PlColors.bull.withValues(alpha: 0.1),
      );
    }

    // Grid
    final grid = Paint()
      ..color = PlColors.grid
      ..strokeWidth = 1;
    for (var g = 0; g <= 3; g++) {
      final y = padT + plotH * g / 3;
      canvas.drawLine(Offset(padL, y), Offset(padL + plotW, y), grid);
    }

    // Candles — dim outside trade window, strong inside
    final bodyW = (slot * 0.7).clamp(3.0, 12.0);
    for (var i = 0; i < tape.length; i++) {
      final c = tape[i];
      final inPath = i >= lo && i <= hi;
      final cx = padL + slot * i + slot / 2;
      final base = c.isBull ? PlColors.bull : PlColors.bear;
      final color = base.withValues(alpha: inPath ? 0.95 : 0.28);
      canvas.drawLine(
        Offset(cx, yFor(c.high)),
        Offset(cx, yFor(c.low)),
        Paint()
          ..color = color
          ..strokeWidth = inPath ? 1.6 : 1.0
          ..strokeCap = StrokeCap.round,
      );
      final top = math.min(yFor(c.open), yFor(c.close));
      final bot = math.max(yFor(c.open), yFor(c.close));
      final bh = math.max(bot - top, 2.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, top + bh / 2), width: bodyW, height: bh),
          const Radius.circular(1.5),
        ),
        Paint()..color = color,
      );
    }

    final outColor = trade.pnl >= 0 ? PlColors.bull : PlColors.bear;
    final ex = padL + slot * ei + slot / 2;
    final ox = padL + slot * xi + slot / 2;
    final ey = yFor(trade.entry);
    final oy = yFor(trade.exit);

    // Vertical guides at IN / OUT bars
    final vGuide = Paint()
      ..color = PlColors.crosshair.withValues(alpha: 0.25)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(ex, padT), Offset(ex, padT + plotH), vGuide);
    canvas.drawLine(Offset(ox, padT), Offset(ox, padT + plotH), vGuide);

    // Horizontal price rails only across the trade window
    void rail(double y, Color color) {
      canvas.drawLine(
        Offset(winL, y),
        Offset(winR, y),
        Paint()
          ..color = color.withValues(alpha: 0.85)
          ..strokeWidth = 1.4,
      );
    }

    rail(ey, PlColors.accent);
    rail(oy, outColor);

    // Path connector
    canvas.drawLine(
      Offset(ex, ey),
      Offset(ox, oy),
      Paint()
        ..color = outColor.withValues(alpha: 0.55)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Markers on the candles
    void marker(Offset at, String label, Color color, {bool above = true}) {
      canvas.drawCircle(at, 7, Paint()..color = color);
      canvas.drawCircle(
        at,
        7,
        Paint()
          ..color = PlColors.bg
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      final lx = (at.dx - tp.width / 2).clamp(padL, size.width - padR - tp.width);
      final ly = above ? at.dy - 20 : at.dy + 10;
      // Soft plate behind label
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(lx - 4, ly - 1, tp.width + 8, tp.height + 2),
          const Radius.circular(4),
        ),
        Paint()..color = PlColors.bg.withValues(alpha: 0.75),
      );
      tp.paint(canvas, Offset(lx, ly));
    }

    final inAbove = ey > padT + plotH * 0.35;
    final outAbove = oy > padT + plotH * 0.35;
    marker(Offset(ex, ey), 'IN', PlColors.accent, above: inAbove);
    marker(Offset(ox, oy), 'OUT', outColor, above: outAbove);

    // Right axis price tags for IN / OUT
    void priceTag(double y, String text, Color color) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(color: PlColors.onAccent, fontSize: 9.5, fontWeight: FontWeight.w800),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      final bx = padL + plotW + 4;
      final by = y - 9;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(bx, by, padR - 8, 18), const Radius.circular(4)),
        Paint()..color = color,
      );
      tp.paint(canvas, Offset(bx + 4, by + 3));
    }

    priceTag(ey, _fmt(trade.entry), PlColors.accent);
    // Offset if too close
    final tagY = (oy - ey).abs() < 20 ? oy + (oy >= ey ? 14 : -14) : oy;
    priceTag(tagY, _fmt(trade.exit), outColor);

    // Footer
    final legend = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: trade.side == Side.long ? 'LONG  ' : 'SHORT  ',
            style: TextStyle(
              color: trade.side == Side.long ? PlColors.bull : PlColors.bear,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: '${_fmt(trade.entry)}  →  ${_fmt(trade.exit)}',
            style: const TextStyle(color: PlColors.muted, fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    legend.paint(canvas, Offset(padL, size.height - 18));
  }

  String _fmt(double v) {
    if (v >= 1000) return v.toStringAsFixed(1);
    if (v >= 100) return v.toStringAsFixed(2);
    if (v >= 1) return v.toStringAsFixed(4);
    if (v >= 0.1) return v.toStringAsFixed(4);
    return v.toStringAsFixed(5);
  }

  @override
  bool shouldRepaint(covariant _ReplayPainter oldDelegate) => oldDelegate.trade != trade;
}
