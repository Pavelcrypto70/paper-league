import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:paper_league/domain/models.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/format.dart';

/// Renders a story-ready recap card and shares it (or copies text on web fallback).
Future<void> shareRecapCard(
  BuildContext context, {
  required ClosedTrade trade,
  required String nickname,
}) async {
  final s = S.of(context);
  final key = GlobalKey();
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => Positioned(
      left: -2000,
      top: 0,
      child: Material(
        color: Colors.transparent,
        child: RepaintBoundary(
          key: key,
          child: RecapShareCard(trade: trade, nickname: nickname, ru: s.isRu),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  await Future<void>.delayed(const Duration(milliseconds: 50));
  await WidgetsBinding.instance.endOfFrame;

  try {
    final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) throw StateError('no boundary');
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) throw StateError('encode failed');
    final png = bytes.buffer.asUint8List();

    final text =
        'Paper League · ${trade.symbol} ${trade.side.name.toUpperCase()} · '
        '${trade.rMultiple >= 0 ? '+' : ''}${trade.rMultiple.toStringAsFixed(2)}R · '
        '${s.shareTagline}';

    if (kIsWeb) {
      await SharePlus.instance.share(ShareParams(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.shareWebHint)),
        );
      }
    } else {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/pl_recap_${trade.id}.png');
      await file.writeAsBytes(png);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: text,
        ),
      );
    }
    HapticFeedback.mediumImpact();
  } catch (_) {
    final text =
        '${trade.symbol} ${trade.side.name.toUpperCase()}\n'
        '${trade.rMultiple >= 0 ? '+' : ''}${trade.rMultiple.toStringAsFixed(2)}R · ${money(trade.pnl)}\n'
        '${priceFmt(trade.entry)} → ${priceFmt(trade.exit)}\n'
        'Paper League · ${s.shareTagline}';
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.shareCopied)),
      );
    }
  } finally {
    entry.remove();
  }
}

class RecapShareCard extends StatelessWidget {
  const RecapShareCard({
    super.key,
    required this.trade,
    required this.nickname,
    required this.ru,
  });

  final ClosedTrade trade;
  final String nickname;
  final bool ru;

  @override
  Widget build(BuildContext context) {
    final win = trade.pnl >= 0;
    final color = win ? PlColors.bull : PlColors.bear;
    final flags = [
      if (trade.flags.contains(RecapFlag.stopSet)) (ru ? 'Стоп' : 'Stop'),
      if (trade.flags.contains(RecapFlag.sizeOk)) (ru ? 'Размер' : 'Size'),
      if (trade.flags.contains(RecapFlag.noWiden)) (ru ? 'Без widen' : 'No widen'),
      if (trade.flags.contains(RecapFlag.noRevenge)) (ru ? 'Без revenge' : 'No revenge'),
    ];

    return Container(
      width: 360,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: PlColors.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PlColors.lineSoft),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlColors.bgElevated,
            PlColors.bg,
            color.withValues(alpha: 0.12),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: PlColors.accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              const Text(
                'PAPER LEAGUE',
                style: TextStyle(
                  color: PlColors.accent,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                '@$nickname',
                style: const TextStyle(color: PlColors.muted, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '${trade.symbol} · ${trade.side.name.toUpperCase()}',
            style: const TextStyle(color: PlColors.muted, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '${trade.rMultiple >= 0 ? '+' : ''}${trade.rMultiple.toStringAsFixed(2)}R',
            style: TextStyle(
              color: color,
              fontSize: 52,
              height: 1,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${money(trade.pnl)} · ${priceFmt(trade.entry)} → ${priceFmt(trade.exit)}',
            style: const TextStyle(color: PlColors.text, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: PlColors.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PlColors.lineSoft),
            ),
            child: Row(
              children: [
                _io('IN', priceFmt(trade.entry), PlColors.accent),
                const Spacer(),
                Icon(Icons.arrow_forward_rounded, size: 16, color: color.withValues(alpha: 0.8)),
                const Spacer(),
                _io('OUT', priceFmt(trade.exit), color),
              ],
            ),
          ),
          if (flags.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: flags
                  .map(
                    (f) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: PlColors.accentSoft,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: PlColors.accent.withValues(alpha: 0.35)),
                      ),
                      child: Text(
                        f,
                        style: const TextStyle(color: PlColors.accent, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            ru ? 'Дисциплина считается.' : 'Discipline gets scored.',
            style: const TextStyle(color: PlColors.faint, fontSize: 11, letterSpacing: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _io(String k, String v, Color c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.6)),
        const SizedBox(height: 2),
        Text(v, style: const TextStyle(color: PlColors.text, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
