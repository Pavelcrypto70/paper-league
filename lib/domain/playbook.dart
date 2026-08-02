import 'dart:convert';

import 'package:paper_league/domain/models.dart';

/// Saved setup template — stop / TP structure relative to mark + ATR.
class Playbook {
  const Playbook({
    required this.id,
    required this.name,
    required this.side,
    required this.stopAtrMult,
    required this.tpR,
    this.symbol,
    this.notes = '',
  });

  final String id;
  final String name;
  final Side side;
  /// Stop distance as ATR multiple (e.g. 1.2).
  final double stopAtrMult;
  /// Take-profit as R multiple from stop distance.
  final double tpR;
  final String? symbol;
  final String notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'side': side.name,
        'stopAtr': stopAtrMult,
        'tpR': tpR,
        'symbol': symbol,
        'notes': notes,
      };

  factory Playbook.fromJson(Map<String, dynamic> m) => Playbook(
        id: m['id'] as String,
        name: m['name'] as String? ?? 'Setup',
        side: (m['side'] as String?) == 'short' ? Side.short : Side.long,
        stopAtrMult: (m['stopAtr'] as num?)?.toDouble() ?? 1.2,
        tpR: (m['tpR'] as num?)?.toDouble() ?? 2.0,
        symbol: m['symbol'] as String?,
        notes: m['notes'] as String? ?? '',
      );

  static List<Playbook> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return defaultPack();
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Playbook.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return defaultPack();
    }
  }

  static String encodeList(List<Playbook> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<Playbook> defaultPack() => const [
        Playbook(
          id: 'pb_impulse',
          name: 'Impulse 1.2ATR',
          side: Side.long,
          stopAtrMult: 1.2,
          tpR: 2.0,
          notes: 'Long impulse · stop beyond swing',
        ),
        Playbook(
          id: 'pb_fade',
          name: 'Fade spike',
          side: Side.short,
          stopAtrMult: 1.0,
          tpR: 1.5,
          notes: 'Short spike · tight risk',
        ),
        Playbook(
          id: 'pb_swing',
          name: 'Swing 2R',
          side: Side.long,
          stopAtrMult: 1.6,
          tpR: 2.5,
          notes: 'Wider stop · patient TP',
        ),
      ];
}

class PlaybookLevels {
  const PlaybookLevels({
    required this.entry,
    required this.stop,
    required this.tp,
    required this.side,
  });

  final double entry;
  final double stop;
  final double tp;
  final Side side;

  List<double> get prices => [entry, stop, tp];
}

PlaybookLevels resolvePlaybook(Playbook pb, {required double mark, required double atrPct}) {
  final atr = mark * (atrPct / 100).clamp(0.002, 0.08);
  final stopDist = atr * pb.stopAtrMult;
  if (pb.side == Side.long) {
    return PlaybookLevels(
      entry: mark,
      stop: mark - stopDist,
      tp: mark + stopDist * pb.tpR,
      side: Side.long,
    );
  }
  return PlaybookLevels(
    entry: mark,
    stop: mark + stopDist,
    tp: mark - stopDist * pb.tpR,
    side: Side.short,
  );
}
