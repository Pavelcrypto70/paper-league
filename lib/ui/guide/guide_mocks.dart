import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/guide/guide_slides.dart';

/// Phone-frame “screenshot” mocks for the guide — product chrome, not clipart.
class GuideMockFrame extends StatelessWidget {
  const GuideMockFrame({super.key, required this.kind, required this.ru});

  final GuideMockKind kind;
  final bool ru;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.72,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: PlColors.line, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: PlColors.accent.withValues(alpha: 0.08),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1018), PlColors.bg],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 72,
              height: 5,
              decoration: BoxDecoration(
                color: PlColors.line,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _MockBody(kind: kind, ru: ru)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MockBody extends StatelessWidget {
  const _MockBody({required this.kind, required this.ru});
  final GuideMockKind kind;
  final bool ru;

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      GuideMockKind.welcome => _WelcomeMock(ru: ru),
      GuideMockKind.desk => _DeskMock(ru: ru),
      GuideMockKind.chart => const _ChartMock(),
      GuideMockKind.ticket => _TicketMock(ru: ru),
      GuideMockKind.position => _PositionMock(ru: ru),
      GuideMockKind.terms => _TermsMock(ru: ru),
      GuideMockKind.tabs => _TabsMock(ru: ru),
      GuideMockKind.recap => _RecapMock(ru: ru),
    };
  }
}

class _WelcomeMock extends StatelessWidget {
  const _WelcomeMock({required this.ru});
  final bool ru;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomPaint(
              painter: _MiniHeroPainter(),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'PAPER LEAGUE',
            style: TextStyle(
              color: PlColors.text,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ru ? 'Дисциплина\nсчитается.' : 'Discipline\ngets scored.',
            style: const TextStyle(
              color: PlColors.text,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              height: 1.02,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: PlColors.accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              ru ? 'ВОЙТИ В ДЕСК' : 'ENTER DESK',
              style: const TextStyle(
                color: PlColors.onAccent,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeskMock extends StatelessWidget {
  const _DeskMock({required this.ru});
  final bool ru;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Row(
            children: [
              _pill('BTC  4.2%', PlColors.accentSoft, PlColors.accent),
              const Spacer(),
              _pill('15M', PlColors.accentSoft, PlColors.accent),
              const SizedBox(width: 4),
              _pill('1H', PlColors.surface2, PlColors.muted),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(ru ? 'ЦЕНА' : 'LAST', style: const TextStyle(color: PlColors.faint, fontSize: 9)),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '67,842.1',
              style: TextStyle(
                color: PlColors.bull,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _stat(ru ? 'ЭКВИТИ' : 'EQUITY', '\$10,240'),
              _stat(ru ? 'СЕССИЯ' : 'SESSION', '+2.4%', PlColors.bull),
              _stat('DISC', '84', PlColors.accent),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: PlColors.bgElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: PlColors.lineSoft),
              ),
              child: CustomPaint(painter: _CandlesPainter(showLevels: true), child: const SizedBox.expand()),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _btn(ru ? 'LONG' : 'LONG', PlColors.bull)),
              const SizedBox(width: 6),
              Expanded(child: _btn(ru ? 'SHORT' : 'SHORT', PlColors.bear)),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _ChartMock extends StatelessWidget {
  const _ChartMock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Row(
            children: [
              _tool(true),
              _tool(false, Icons.horizontal_rule),
              _tool(false, Icons.timeline),
              _tool(false, Icons.auto_fix_high),
              const Spacer(),
              const Text('CLEAR', style: TextStyle(color: PlColors.muted, fontSize: 9, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: PlColors.bgElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: PlColors.lineSoft),
              ),
              child: Stack(
                children: [
                  CustomPaint(
                    painter: _CandlesPainter(showLevels: true, showCross: true, showLive: true),
                    child: const SizedBox.expand(),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: PlColors.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: PlColors.lineSoft),
                      ),
                      child: const Text(
                        'O 672 H 681 L 668 C 677',
                        style: TextStyle(color: PlColors.bull, fontSize: 8, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: PlColors.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(color: PlColors.onAccent, fontSize: 9, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  // Drag callouts
                  Positioned(
                    right: 48,
                    top: 72,
                    child: _callout('TP', PlColors.bull),
                  ),
                  Positioned(
                    right: 48,
                    bottom: 56,
                    child: _callout('SL', PlColors.bear),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '← pan  ·  drag SL/TP  ·  tap OHLC',
            style: TextStyle(color: PlColors.faint, fontSize: 9, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _tool(bool on, [IconData icon = Icons.near_me_outlined]) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: on ? PlColors.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: on ? PlColors.accent : PlColors.lineSoft),
      ),
      child: Icon(icon, size: 12, color: on ? PlColors.accent : PlColors.muted),
    );
  }

  Widget _callout(String t, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)),
      child: Text(t, style: const TextStyle(color: PlColors.onAccent, fontSize: 8, fontWeight: FontWeight.w900)),
    );
  }
}

class _TicketMock extends StatelessWidget {
  const _TicketMock({required this.ru});
  final bool ru;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(ru ? 'Тикет' : 'Ticket', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              const Spacer(),
              Text(ru ? 'Марк 67,840' : 'Mark 67,840', style: const TextStyle(color: PlColors.accent, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _btn('LONG', PlColors.bull, h: 34)),
              const SizedBox(width: 6),
              Expanded(child: _btn('SHORT', PlColors.bear.withValues(alpha: 0.35), h: 34, fg: PlColors.muted)),
            ],
          ),
          const SizedBox(height: 10),
          Text(ru ? 'ДИСТАНЦИЯ СТОПА' : 'STOP DISTANCE', style: const TextStyle(color: PlColors.faint, fontSize: 8, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Row(children: [_chip('0.8%'), _chip('1.5%', on: true), _chip('2.5%')]),
          const SizedBox(height: 10),
          Text(ru ? 'РИСК / ЭКВИТИ' : 'RISK / EQUITY', style: const TextStyle(color: PlColors.faint, fontSize: 8)),
          const SizedBox(height: 4),
          Container(
            height: 4,
            decoration: BoxDecoration(color: PlColors.line, borderRadius: BorderRadius.circular(99)),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.4,
              child: Container(
                decoration: BoxDecoration(color: PlColors.bull, borderRadius: BorderRadius.circular(99)),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ru ? '2.0% · если стоп −\$200' : '2.0% · if stopped −\$200',
            style: const TextStyle(color: PlColors.warn, fontSize: 9),
          ),
          const SizedBox(height: 10),
          Text(ru ? 'ТЕЙК-ПРОФИТ' : 'TAKE PROFIT', style: const TextStyle(color: PlColors.faint, fontSize: 8)),
          const SizedBox(height: 6),
          Row(children: [_chip('1.0R'), _chip('1.5R', on: true), _chip('2.0R'), _chip('3.0R')]),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PlColors.bgElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: PlColors.lineSoft),
            ),
            child: const Text(
              'Qty 0.148 · SL 66,822 · TP 69,366',
              style: TextStyle(fontSize: 9, color: PlColors.muted, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          _btn(ru ? 'ОТКРЫТЬ LONG' : 'PLACE LONG', PlColors.bull, h: 38),
        ],
      ),
    );
  }
}

class _PositionMock extends StatelessWidget {
  const _PositionMock({required this.ru});
  final bool ru;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: PlColors.bgElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: PlColors.lineSoft),
              ),
              child: CustomPaint(painter: _CandlesPainter(showLevels: true), child: const SizedBox.expand()),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: PlColors.bull.withValues(alpha: 0.45)),
              gradient: LinearGradient(
                colors: [PlColors.bull.withValues(alpha: 0.1), PlColors.surface],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'LONG BTCUSDT',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                    ),
                    const Spacer(),
                    Text(
                      ru ? 'ЗАКРЫТЬ' : 'CLOSE',
                      style: const TextStyle(color: PlColors.bear, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const Text(
                  '0.148 · +\$86 · +0.92R',
                  style: TextStyle(color: PlColors.bull, fontSize: 10, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _outline(ru ? 'Закрыть 50%' : 'Close 50%')),
                    const SizedBox(width: 6),
                    Expanded(child: _outline(ru ? 'ПОДТЯНУТЬ' : 'TIGHTEN')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _outline(String t) {
    return Container(
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PlColors.line),
      ),
      child: Text(t, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
    );
  }
}

class _TermsMock extends StatelessWidget {
  const _TermsMock({required this.ru});
  final bool ru;

  @override
  Widget build(BuildContext context) {
    final items = ru
        ? const [('R', '+1.40', PlColors.bull), ('MFE', '+2.1R', PlColors.bull), ('MAE', '−0.6R', PlColors.bear), ('DISC', '84', PlColors.accent)]
        : const [('R', '+1.40', PlColors.bull), ('MFE', '+2.1R', PlColors.bull), ('MAE', '−0.6R', PlColors.bear), ('DISC', '84', PlColors.accent)];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          for (final e in items) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: PlColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: PlColors.lineSoft),
              ),
              child: Row(
                children: [
                  Text(e.$1, style: TextStyle(color: e.$3, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.6)),
                  const Spacer(),
                  Text(e.$2, style: TextStyle(color: e.$3, fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
            ),
          ],
          const Spacer(),
          Text(
            ru ? 'Смотри расшифровку слева →' : 'Read definitions on the left →',
            style: const TextStyle(color: PlColors.faint, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _TabsMock extends StatelessWidget {
  const _TabsMock({required this.ru});
  final bool ru;

  @override
  Widget build(BuildContext context) {
    final labels = ru ? ['Деск', 'Книга', 'Лига', 'Вы'] : ['Desk', 'Book', 'League', 'You'];
    final icons = [Icons.show_chart_rounded, Icons.layers_rounded, Icons.military_tech_rounded, Icons.person_rounded];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PlColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PlColors.accent.withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ru ? 'ЛИГА' : 'LEAGUE', style: const TextStyle(color: PlColors.accent, fontSize: 9, fontWeight: FontWeight.w800)),
                  const Text('91.2', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -1)),
                  Text(ru ? 'место #2 · disc 84' : 'rank #2 · disc 84', style: const TextStyle(color: PlColors.muted, fontSize: 10)),
                  const Spacer(),
                  _row('#1  mara', '92.1'),
                  _row('#2  you', '91.2', you: true),
                  _row('#3  diego', '90.4'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: PlColors.bgElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PlColors.lineSoft),
            ),
            child: Row(
              children: List.generate(4, (i) {
                final on = i == 2;
                return Expanded(
                  child: Column(
                    children: [
                      Icon(icons[i], size: 16, color: on ? PlColors.accent : PlColors.faint),
                      const SizedBox(height: 2),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: on ? FontWeight.w800 : FontWeight.w500,
                          color: on ? PlColors.accent : PlColors.faint,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String n, String s, {bool you = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: you ? PlColors.accentSoft.withValues(alpha: 0.6) : PlColors.bgElevated,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(n, style: TextStyle(fontSize: 9, fontWeight: you ? FontWeight.w800 : FontWeight.w500)),
          const Spacer(),
          Text(s, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _RecapMock extends StatelessWidget {
  const _RecapMock({required this.ru});
  final bool ru;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ru ? 'ИТОГ СДЕЛКИ' : 'TRADE RECAP', style: const TextStyle(color: PlColors.faint, fontSize: 8, letterSpacing: 1)),
          const Text('BTCUSDT · LONG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          const Text('+1.40R', style: TextStyle(color: PlColors.bull, fontSize: 28, fontWeight: FontWeight.w700, height: 1.1)),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: PlColors.bgElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: PlColors.lineSoft),
              ),
              child: CustomPaint(painter: _CandlesPainter(showInOut: true), child: const SizedBox.expand()),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _metric('MFE', '+2.1R', PlColors.bull)),
              const SizedBox(width: 6),
              Expanded(child: _metric('MAE', '−0.4R', PlColors.bear)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PlColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: PlColors.lineSoft),
            ),
            child: Text(
              ru
                  ? 'На пике +2.1R — после +1R подтягивай стоп.'
                  : 'Peak +2.1R — trail the stop after +1R.',
              style: const TextStyle(color: PlColors.muted, fontSize: 9, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String k, String v, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(k, style: TextStyle(color: c, fontSize: 8, fontWeight: FontWeight.w800)),
          const Spacer(),
          Text(v, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// —— shared chrome helpers ——

Widget _pill(String t, Color bg, Color fg) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: fg.withValues(alpha: 0.35)),
    ),
    child: Text(t, style: TextStyle(color: fg, fontSize: 8, fontWeight: FontWeight.w800)),
  );
}

Widget _stat(String k, String v, [Color? c]) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: const TextStyle(color: PlColors.faint, fontSize: 7)),
        Text(v, style: TextStyle(color: c ?? PlColors.text, fontSize: 10, fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

Widget _btn(String t, Color bg, {double h = 34, Color? fg}) {
  return Container(
    height: h,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Text(
      t,
      style: TextStyle(color: fg ?? PlColors.onBull, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.4),
    ),
  );
}

Widget _chip(String t, {bool on = false}) {
  return Container(
    margin: const EdgeInsets.only(right: 4),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: on ? PlColors.accentSoft : PlColors.surface2,
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: on ? PlColors.accent : PlColors.line),
    ),
    child: Text(
      t,
      style: TextStyle(color: on ? PlColors.accent : PlColors.muted, fontSize: 8, fontWeight: FontWeight.w700),
    ),
  );
}

class _CandlesPainter extends CustomPainter {
  _CandlesPainter({
    this.showLevels = false,
    this.showCross = false,
    this.showLive = false,
    this.showInOut = false,
  });

  final bool showLevels;
  final bool showCross;
  final bool showLive;
  final bool showInOut;

  @override
  void paint(Canvas canvas, Size size) {
    final n = 22;
    final slot = size.width / n;
    final top = 10.0;
    final h = size.height - 20;

    double s(int i) {
      final x = i / n;
      return 0.55 - x * 0.18 + math.sin(x * 8) * 0.08 + math.cos(x * 3) * 0.05;
    }

    if (showLevels) {
      final entry = top + h * 0.55;
      final tp = top + h * 0.28;
      final sl = top + h * 0.78;
      canvas.drawRect(
        Rect.fromLTRB(0, tp, size.width, entry),
        Paint()..color = PlColors.bull.withValues(alpha: 0.07),
      );
      canvas.drawRect(
        Rect.fromLTRB(0, entry, size.width, sl),
        Paint()..color = PlColors.bear.withValues(alpha: 0.07),
      );
      void dash(double y, Color c) {
        final p = Paint()
          ..color = c
          ..strokeWidth = 1;
        for (var x = 0.0; x < size.width; x += 7) {
          canvas.drawLine(Offset(x, y), Offset(x + 4, y), p);
        }
      }

      dash(entry, PlColors.accent);
      dash(tp, PlColors.bull);
      dash(sl, PlColors.bear);
    }

    for (var i = 0; i < n; i++) {
      final mid = s(i);
      final open = mid + 0.03;
      final close = mid - 0.02;
      final bull = close < open;
      final color = bull ? PlColors.bull : PlColors.bear;
      final cx = slot * i + slot / 2;
      final yO = top + h * open.clamp(0.05, 0.95);
      final yC = top + h * close.clamp(0.05, 0.95);
      canvas.drawLine(
        Offset(cx, top + h * (mid - 0.06)),
        Offset(cx, top + h * (mid + 0.06)),
        Paint()
          ..color = color.withValues(alpha: 0.6)
          ..strokeWidth = 1,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, (yO + yC) / 2),
            width: (slot * 0.55).clamp(2.5, 7),
            height: math.max((yO - yC).abs(), 1.5),
          ),
          const Radius.circular(1),
        ),
        Paint()..color = color,
      );
    }

    if (showCross) {
      final cx = size.width * 0.62;
      final cy = top + h * 0.42;
      final hair = Paint()
        ..color = PlColors.crosshair.withValues(alpha: 0.4)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(cx, 8), Offset(cx, size.height - 8), hair);
      canvas.drawLine(Offset(8, cy), Offset(size.width - 8, cy), hair);
      canvas.drawCircle(Offset(cx, cy), 2.5, Paint()..color = PlColors.accent);
    }

    if (showLive) {
      final y = top + h * s(n - 1);
      canvas.drawCircle(Offset(size.width - 14, y), 3, Paint()..color = PlColors.accent);
    }

    if (showInOut) {
      final ei = 6;
      final xi = 18;
      final ey = top + h * s(ei);
      final oy = top + h * (s(xi) - 0.08);
      final ex = slot * ei + slot / 2;
      final ox = slot * xi + slot / 2;
      canvas.drawLine(
        Offset(ex, ey),
        Offset(ox, oy),
        Paint()
          ..color = PlColors.bull.withValues(alpha: 0.4)
          ..strokeWidth = 1.2,
      );
      void mark(Offset at, String t, Color c) {
        canvas.drawCircle(at, 4, Paint()..color = c);
        final tp = TextPainter(
          text: TextSpan(text: t, style: TextStyle(color: c, fontSize: 8, fontWeight: FontWeight.w900)),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(at.dx - tp.width / 2, at.dy - 14));
      }

      mark(Offset(ex, ey), 'IN', PlColors.accent);
      mark(Offset(ox, oy), 'OUT', PlColors.bull);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final n = 18;
    final slot = size.width / n;
    for (var i = 0; i < n; i++) {
      final x = i / n;
      final mid = 0.55 - x * 0.2 + math.sin(x * 7) * 0.08;
      final bull = i % 3 != 0;
      final c = bull ? PlColors.bull : PlColors.bear;
      final cx = slot * i + slot / 2;
      final y = size.height * mid;
      canvas.drawLine(
        Offset(cx, y - 8),
        Offset(cx, y + 8),
        Paint()
          ..color = c.withValues(alpha: 0.7)
          ..strokeWidth = 1,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, y), width: 4, height: 10),
          const Radius.circular(1),
        ),
        Paint()..color = c,
      );
    }
    canvas.drawCircle(Offset(size.width - 16, size.height * 0.35), 3, Paint()..color = PlColors.accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
