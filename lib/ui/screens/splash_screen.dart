import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/theme/tokens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _ambient;
  late final AnimationController _ctaPulse;

  late final Animation<double> _brandOp;
  late final Animation<double> _brandY;
  late final Animation<double> _titleOp;
  late final Animation<double> _titleY;
  late final Animation<double> _subOp;
  late final Animation<double> _ctaOp;
  late final Animation<double> _heroOp;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();
    _ambient = AnimationController(vsync: this, duration: const Duration(milliseconds: 4800))..repeat();
    _ctaPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);

    _heroOp = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    );
    _brandOp = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.12, 0.55, curve: Curves.easeOutCubic),
    );
    _brandY = Tween(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(parent: _enter, curve: const Interval(0.12, 0.55, curve: Curves.easeOutCubic)),
    );
    _titleOp = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.28, 0.7, curve: Curves.easeOutCubic),
    );
    _titleY = Tween(begin: 28.0, end: 0.0).animate(
      CurvedAnimation(parent: _enter, curve: const Interval(0.28, 0.7, curve: Curves.easeOutCubic)),
    );
    _subOp = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.42, 0.82, curve: Curves.easeOutCubic),
    );
    _ctaOp = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _enter.dispose();
    _ambient.dispose();
    _ctaPulse.dispose();
    super.dispose();
  }

  void _enterDesk() {
    HapticFeedback.mediumImpact();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: PlColors.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Atmosphere
          const _Atmosphere(),

          // Full-bleed live tape hero
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: MediaQuery.sizeOf(context).height * 0.62,
            child: FadeTransition(
              opacity: reduce ? const AlwaysStoppedAnimation(1) : _heroOp,
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: reduce ? const AlwaysStoppedAnimation(0.0) : _ambient,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _HeroTapePainter(
                        t: reduce ? 0.35 : _ambient.value,
                      ),
                      child: const SizedBox.expand(),
                    );
                  },
                ),
              ),
            ),
          ),

          // Readability veil over tape
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.sizeOf(context).height * 0.28,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    PlColors.bg.withValues(alpha: 0),
                    PlColors.bg.withValues(alpha: 0.55),
                    PlColors.bg,
                    PlColors.bg,
                  ],
                  stops: const [0, 0.28, 0.55, 1],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top meta row
                  FadeTransition(
                    opacity: _brandOp,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: PlColors.accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: PlColors.accent.withValues(alpha: 0.55),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          s.splashTag,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: PlColors.accent,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.6,
                              ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),

                  const Spacer(flex: 5),

                  // Brand — hero signal
                  AnimatedBuilder(
                    animation: _enter,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _brandOp.value,
                        child: Transform.translate(
                          offset: Offset(0, _brandY.value),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      s.splashMark,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 34,
                            height: 1,
                            letterSpacing: 2.4,
                            fontWeight: FontWeight.w700,
                            color: PlColors.text,
                          ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Headline
                  AnimatedBuilder(
                    animation: _enter,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _titleOp.value,
                        child: Transform.translate(
                          offset: Offset(0, _titleY.value),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      s.splashTitle,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontSize: 46,
                            height: 0.98,
                            letterSpacing: -1.8,
                            fontWeight: FontWeight.w600,
                            color: PlColors.text,
                          ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  FadeTransition(
                    opacity: _subOp,
                    child: Text(
                      s.splashSub,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: PlColors.muted,
                            height: 1.4,
                            fontSize: 15,
                          ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  FadeTransition(
                    opacity: _ctaOp,
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: reduce ? const AlwaysStoppedAnimation(0.5) : _ctaPulse,
                          builder: (context, child) {
                            final g = 0.22 + 0.18 * (reduce ? 0.5 : _ctaPulse.value);
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(PlRadius.md),
                                boxShadow: [
                                  BoxShadow(
                                    color: PlColors.accent.withValues(alpha: g),
                                    blurRadius: 28,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: child,
                            );
                          },
                          child: SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: PlColors.accent,
                                foregroundColor: PlColors.onAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(PlRadius.md),
                                ),
                              ),
                              onPressed: _enterDesk,
                              child: Text(
                                s.enterDesk,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          s.eduOnly,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: PlColors.faint,
                                letterSpacing: 0.2,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Atmosphere extends StatelessWidget {
  const _Atmosphere();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: PlColors.bg),
        // Deep cyan bloom — top right (tape region)
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.75, -0.55),
              radius: 1.15,
              colors: [
                PlColors.accent.withValues(alpha: 0.14),
                PlColors.accent.withValues(alpha: 0.04),
                Colors.transparent,
              ],
              stops: const [0, 0.4, 1],
            ),
          ),
        ),
        // Soft bull wash — mid left
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.9, 0.1),
              radius: 0.95,
              colors: [
                PlColors.bull.withValues(alpha: 0.07),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Bottom ink weight
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                const Color(0xFF02040A).withValues(alpha: 0.85),
              ],
              stops: const [0.45, 1],
            ),
          ),
        ),
        // Fine scanline texture (cheap, readable)
        CustomPaint(painter: _ScanPainter(), child: const SizedBox.expand()),
      ],
    );
  }
}

class _ScanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PlColors.text.withValues(alpha: 0.018)
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Full-bleed procedural terminal tape — the product visual, not a toy chart card.
class _HeroTapePainter extends CustomPainter {
  _HeroTapePainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Perspective floor grid
    final grid = Paint()
      ..color = PlColors.accent.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    final horizon = h * 0.42;
    for (var i = 0; i < 14; i++) {
      final y = horizon + math.pow(i / 13, 1.55) * (h - horizon);
      canvas.drawLine(Offset(0, y), Offset(w, y), grid);
    }
    for (var i = -8; i <= 8; i++) {
      final xTop = w * 0.5 + i * 28;
      canvas.drawLine(Offset(xTop, horizon), Offset(w * 0.5 + i * 90, h), grid);
    }

    // Candle window
    final top = h * 0.12;
    final bottom = h * 0.78;
    final chartH = bottom - top;
    final n = 36;
    final slot = w / n;
    final phase = t * math.pi * 2;

    double series(int i) {
      final x = i / n;
      final wave = math.sin(x * 9 + phase) * 0.07 +
          math.sin(x * 3.2 - phase * 0.6) * 0.11 +
          math.cos(x * 17 + phase * 1.3) * 0.03;
      final drift = (x - 0.15) * 0.22;
      return 0.55 - drift - wave;
    }

    // Equity area fill under last path
    final area = Path();
    for (var i = 0; i < n; i++) {
      final cx = slot * i + slot / 2;
      final mid = series(i);
      final y = top + chartH * mid.clamp(0.08, 0.92);
      if (i == 0) {
        area.moveTo(cx, bottom);
        area.lineTo(cx, y);
      } else {
        area.lineTo(cx, y);
      }
    }
    area.lineTo(slot * (n - 1) + slot / 2, bottom);
    area.close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, top),
          Offset(0, bottom),
          [
            PlColors.accent.withValues(alpha: 0.18),
            PlColors.accent.withValues(alpha: 0.0),
          ],
        ),
    );

    // Candles
    for (var i = 0; i < n; i++) {
      final mid = series(i);
      final jitter = math.sin(i * 2.7 + phase * 2) * 0.035;
      final openN = (mid + jitter).clamp(0.05, 0.95);
      final closeN = (mid - jitter * 0.8).clamp(0.05, 0.95);
      final highN = math.min(openN, closeN) - 0.04 - (i % 3) * 0.008;
      final lowN = math.max(openN, closeN) + 0.04 + ((i + 1) % 4) * 0.006;
      final bull = closeN <= openN;
      final color = bull ? PlColors.bull : PlColors.bear;
      final cx = slot * i + slot / 2;
      final yO = top + chartH * openN;
      final yC = top + chartH * closeN;
      final yH = top + chartH * highN.clamp(0.02, 0.98);
      final yL = top + chartH * lowN.clamp(0.02, 0.98);

      canvas.drawLine(
        Offset(cx, yH),
        Offset(cx, yL),
        Paint()
          ..color = color.withValues(alpha: 0.55)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round,
      );
      final bodyTop = math.min(yO, yC);
      final bodyH = math.max((yO - yC).abs(), 2.0);
      final bodyW = (slot * 0.55).clamp(3.0, 9.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, bodyTop + bodyH / 2), width: bodyW, height: bodyH),
          const Radius.circular(1.2),
        ),
        Paint()..color = color.withValues(alpha: 0.88),
      );
    }

    // Live price rail + pulse
    final lastY = top + chartH * series(n - 1).clamp(0.08, 0.92);
    canvas.drawLine(
      Offset(0, lastY),
      Offset(w, lastY),
      Paint()
        ..color = PlColors.accent.withValues(alpha: 0.35)
        ..strokeWidth = 1,
    );
    final pulse = 0.5 + 0.5 * math.sin(phase * 2);
    canvas.drawCircle(
      Offset(w - 28, lastY),
      10 + pulse * 4,
      Paint()..color = PlColors.accent.withValues(alpha: 0.12),
    );
    canvas.drawCircle(
      Offset(w - 28, lastY),
      3.5,
      Paint()..color = PlColors.accent,
    );

    // Soft vignette on tape edges
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, h),
          [
            PlColors.bg.withValues(alpha: 0.55),
            Colors.transparent,
            Colors.transparent,
            PlColors.bg.withValues(alpha: 0.35),
          ],
          [0, 0.18, 0.7, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _HeroTapePainter oldDelegate) => oldDelegate.t != t;
}
