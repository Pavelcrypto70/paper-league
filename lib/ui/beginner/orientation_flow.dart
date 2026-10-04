import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/l10n/s_path.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/beginner/path_kit.dart';
import 'package:paper_league/ui/format.dart';
import 'package:paper_league/ui/widgets/candle_chart.dart';
import 'package:provider/provider.dart';

/// Floor 0: chart → BTC → “this is a candle” before the mission rail.
class OrientationFlow extends StatelessWidget {
  const OrientationFlow({super.key});

  @override
  Widget build(BuildContext context) {
    final step = context.watch<DeskController>().orientStep.clamp(0, 2);
    return AnimatedSwitcher(
      duration: PlMotion.emphasis,
      child: KeyedSubtree(
        key: ValueKey(step),
        child: switch (step) {
          0 => const _OrientChart(),
          1 => const _OrientBtc(),
          _ => const _OrientCandle(),
        },
      ),
    );
  }
}

Future<void> _next(BuildContext context) async {
  pathTap(strong: true);
  await context.read<DeskController>().advanceOrientation();
}

class _Shell extends StatelessWidget {
  const _Shell({
    required this.step,
    required this.title,
    required this.body,
    required this.cta,
    required this.child,
  });

  final int step;
  final String title;
  final String body;
  final String cta;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.orientOf, style: pathCapStyle.copyWith(color: PlColors.accent)),
          const SizedBox(height: 4),
          Text(s.orientStepOf(step), style: pathMono(size: 12, color: PlColors.muted)),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 1; i <= 3; i++) ...[
                if (i > 1) const SizedBox(width: 6),
                Expanded(
                  child: AnimatedContainer(
                    duration: PlMotion.standard,
                    height: 5,
                    decoration: BoxDecoration(
                      color: i < step
                          ? PlColors.bull
                          : i == step
                              ? PlColors.accent
                              : PlColors.surface3,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: pathTitleStyle(context)),
          const SizedBox(height: 8),
          Text(body, style: pathSubStyle),
          const SizedBox(height: 14),
          Expanded(child: child),
          const SizedBox(height: 14),
          PathButton(
            cta,
            trailingIcon: Icons.arrow_forward_rounded,
            pulse: true,
            onPressed: () => _next(context),
          ),
        ],
      ),
    );
  }
}

class _ChartFrame extends StatelessWidget {
  const _ChartFrame({this.highlightLast = false, this.showPair = false});

  final bool highlightLast;
  final bool showPair;

  @override
  Widget build(BuildContext context) {
    final desk = context.watch<DeskController>();
    final s = S.of(context);
    final candles = desk.candles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showPair) ...[
          Row(
            children: [
              Text(
                desk.activeSymbol.replaceAll('USDT', '/USDT'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 10),
              PathChip(desk.timeframe),
              const Spacer(),
              if (desk.mark > 0)
                Text(priceFmt(desk.mark), style: pathMono(size: 16, weight: FontWeight.w700, color: PlColors.accent)),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: PlColors.surface,
              borderRadius: BorderRadius.circular(PlRadius.lg),
              border: Border.all(color: highlightLast ? PlColors.accent : PlColors.lineSoft, width: highlightLast ? 1.5 : 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: candles.isEmpty
                ? Center(child: Text(s.homeLoading, style: pathCapStyle))
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      IgnorePointer(child: CandleChart(candles: candles)),
                      if (highlightLast)
                        IgnorePointer(
                          child: CustomPaint(painter: _HighlightLastPainter(count: candles.length)),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _OrientChart extends StatelessWidget {
  const _OrientChart();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return _Shell(
      step: 1,
      title: s.orientChartTitle,
      body: s.orientChartBody,
      cta: s.orientNext,
      child: const _ChartFrame(),
    );
  }
}

class _OrientBtc extends StatelessWidget {
  const _OrientBtc();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final mark = context.watch<DeskController>().mark;
    return _Shell(
      step: 2,
      title: s.orientBtcTitle,
      body: s.orientBtcBody,
      cta: s.orientNext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PathCard(
            accent: true,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.orientPriceNow, style: pathCapStyle.copyWith(color: PlColors.accent)),
                      const SizedBox(height: 4),
                      Text(
                        mark > 0 ? priceFmt(mark) : '—',
                        style: pathMono(size: 28, weight: FontWeight.w700, color: PlColors.text),
                      ),
                    ],
                  ),
                ),
                PathChip('BTC/USDT', tone: PathTone.accent),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Expanded(child: _ChartFrame(showPair: true)),
        ],
      ),
    );
  }
}

class _OrientCandle extends StatelessWidget {
  const _OrientCandle();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return _Shell(
      step: 3,
      title: s.orientCandleTitle,
      body: s.orientCandleBody,
      cta: s.orientToMissions,
      child: const _ChartFrame(highlightLast: true, showPair: true),
    );
  }
}

/// Dashed frame around the last visible candle so “this is a candle” is obvious.
class _HighlightLastPainter extends CustomPainter {
  _HighlightLastPainter({required this.count});
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    if (count <= 0) return;
    final window = math.min(80, count);
    final slot = (size.width - 56) / window;
    final cx = slot * (window - 0.5);
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, size.height * 0.38), width: slot * 2.4, height: size.height * 0.42),
      const Radius.circular(12),
    );
    final dash = Path()..addRRect(rect);
    final paint = Paint()
      ..color = PlColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final metric in dash.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, math.min(d + 6, metric.length)), paint);
        d += 12;
      }
    }
    // pointer pulse
    canvas.drawCircle(Offset(cx, size.height * 0.18), 8, Paint()..color = PlColors.accent.withValues(alpha: 0.25));
    canvas.drawCircle(Offset(cx, size.height * 0.18), 3.5, Paint()..color = PlColors.accent);
  }

  @override
  bool shouldRepaint(covariant _HighlightLastPainter oldDelegate) => oldDelegate.count != count;
}
