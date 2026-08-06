import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:paper_league/domain/models.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MarketSymbol {
  const MarketSymbol({
    required this.id,
    required this.base,
    required this.start,
  });

  final String id;
  final String base;
  final double start;
}

/// Binance trade stream → last price. No-op on web / when WS fails.
class LiveTapeBridge {
  LiveTapeBridge();

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  String? _symbol;
  double? lastPrice;
  DateTime? lastAt;
  bool get isLive =>
      lastPrice != null &&
      lastAt != null &&
      DateTime.now().difference(lastAt!) < const Duration(seconds: 4);

  Future<void> connect(String symbolId) async {
    if (kIsWeb) return;
    final sym = symbolId.toLowerCase();
    if (_symbol == sym && _channel != null) return;
    await disconnect();
    _symbol = sym;
    try {
      final uri = Uri.parse('wss://stream.binance.com:9443/ws/$sym@trade');
      _channel = WebSocketChannel.connect(uri);
      _sub = _channel!.stream.listen(
        (raw) {
          try {
            final m = jsonDecode(raw as String) as Map<String, dynamic>;
            final p = double.tryParse(m['p']?.toString() ?? '');
            if (p == null || p <= 0) return;
            lastPrice = p;
            lastAt = DateTime.now();
          } catch (_) {}
        },
        onError: (_) {},
        onDone: () {},
        cancelOnError: false,
      );
    } catch (_) {
      _channel = null;
    }
  }

  Future<void> disconnect() async {
    await _sub?.cancel();
    _sub = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _symbol = null;
  }
}

class MarketFeed {
  MarketFeed({http.Client? client, int? seed, LiveTapeBridge? tape})
      : _client = client ?? http.Client(),
        _rng = Random(seed ?? 42),
        liveTape = tape ?? LiveTapeBridge();

  final http.Client _client;
  final Random _rng;
  final LiveTapeBridge liveTape;

  static const feeRate = 0.0005;

  /// Top liquid high-vol names for the paper desk (demo starts).
  static const symbols = <MarketSymbol>[
    MarketSymbol(id: 'BTCUSDT', base: 'BTC', start: 64210),
    MarketSymbol(id: 'ETHUSDT', base: 'ETH', start: 3420),
    MarketSymbol(id: 'SOLUSDT', base: 'SOL', start: 148.6),
    MarketSymbol(id: 'DOGEUSDT', base: 'DOGE', start: 0.168),
    MarketSymbol(id: 'AVAXUSDT', base: 'AVAX', start: 28.4),
    MarketSymbol(id: 'LINKUSDT', base: 'LINK', start: 14.2),
    MarketSymbol(id: 'NEARUSDT', base: 'NEAR', start: 4.85),
    MarketSymbol(id: 'APTUSDT', base: 'APT', start: 8.9),
    MarketSymbol(id: 'SUIUSDT', base: 'SUI', start: 2.15),
    MarketSymbol(id: 'WIFUSDT', base: 'WIF', start: 1.85),
  ];

  static String binanceInterval(String tf) => switch (tf) {
        '5m' => '5m',
        '15m' => '15m',
        '30m' => '30m',
        '1h' => '1h',
        _ => '15m',
      };

  static Duration stepFor(String tf) => switch (tf) {
        '5m' => const Duration(minutes: 5),
        '15m' => const Duration(minutes: 15),
        '30m' => const Duration(minutes: 30),
        '1h' => const Duration(hours: 1),
        _ => const Duration(minutes: 15),
      };

  /// Bars covering ~24h for the given timeframe.
  static int barsPerDay(String tf) {
    final m = stepFor(tf).inMinutes;
    if (m <= 0) return 96;
    return (24 * 60 / m).round().clamp(8, 288);
  }

  /// Load history for [interval] TF. Returns (candles, usedLive).
  Future<({List<Candle> candles, bool live})> loadHistory(
    String symbolId, {
    int limit = 200,
    String interval = '15m',
  }) async {
    if (!kIsWeb) {
      try {
        final remote = await _fetchBinance(
          symbolId,
          limit: limit,
          interval: binanceInterval(interval),
        );
        if (remote.length >= 40) {
          return (candles: remote, live: true);
        }
      } catch (_) {}
    }
    final meta = symbols.firstWhere(
      (s) => s.id == symbolId,
      orElse: () => symbols.first,
    );
    return (
      candles: generateVolatileSeries(
        count: limit,
        start: meta.start,
        step: stepFor(interval),
      ),
      live: false,
    );
  }

  Future<List<Candle>> _fetchBinance(
    String symbol, {
    required int limit,
    required String interval,
  }) async {
    final uri = Uri.parse(
      'https://api.binance.com/api/v3/klines?symbol=$symbol&interval=$interval&limit=$limit',
    );
    final res = await _client.get(uri).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) throw StateError('Binance ${res.statusCode}');
    final raw = jsonDecode(res.body) as List<dynamic>;
    return raw.map((row) {
      final item = row as List<dynamic>;
      return Candle(
        openTime: DateTime.fromMillisecondsSinceEpoch(item[0] as int),
        open: double.parse(item[1] as String),
        high: double.parse(item[2] as String),
        low: double.parse(item[3] as String),
        close: double.parse(item[4] as String),
        volume: double.parse(item[5] as String),
      );
    }).toList();
  }

  /// Rebuild history for a TF while keeping the live mark continuous.
  List<Candle> bookForTimeframe({
    required double mark,
    required String timeframe,
    int count = 200,
  }) {
    final step = stepFor(timeframe);
    final seed = mark > 0 ? mark : 1.0;
    final series = generateVolatileSeries(
      count: count,
      start: seed,
      step: step,
      endAt: mark,
    );
    return pinLastClose(series, mark);
  }

  /// Force last candle OHLC to [mark] (no wick past mark).
  List<Candle> pinLastClose(List<Candle> candles, double mark) {
    if (candles.isEmpty) return candles;
    final list = List<Candle>.from(candles);
    final last = list.last;
    list[list.length - 1] = Candle(
      openTime: last.openTime,
      open: mark,
      high: mark,
      low: mark,
      close: mark,
      volume: last.volume,
    );
    return list;
  }

  List<Candle> generateVolatileSeries({
    int count = 200,
    double start = 64210,
    Duration step = const Duration(minutes: 15),
    double? endAt,
  }) {
    final candles = <Candle>[];
    var price = start;
    var t = DateTime.now().toUtc().subtract(step * count);
    final scale = start > 1000 ? 1.0 : start > 10 ? 1.35 : start > 1 ? 1.7 : 2.2;
    final target = endAt ?? start;

    for (var i = 0; i < count; i++) {
      final regime = (i ~/ 14) % 5;
      final drift = switch (regime) {
        0 => 0.0011,
        1 => -0.0018,
        2 => 0.0002,
        3 => 0.0014,
        _ => -0.0008,
      };
      final shock = (i % 23 == 0) ? (_rng.nextBool() ? 0.018 : -0.02) * scale : 0.0;
      final noise = (_rng.nextDouble() - 0.5) * 0.007 * scale;
      final open = price;
      var close = (open * (1 + drift + shock + noise)).clamp(start * 0.25, start * 3.5);
      if (endAt != null && i >= count - 12) {
        final tPull = (i - (count - 12) + 1) / 12.0;
        close = close + (target - close) * tPull.clamp(0.0, 1.0);
      }
      final wick = open * (0.0015 + _rng.nextDouble() * 0.005) * scale;
      final high = max(open, close) + wick * _rng.nextDouble();
      final low = min(open, close) - wick * _rng.nextDouble();
      candles.add(
        Candle(
          openTime: t,
          open: open,
          high: high,
          low: low,
          close: close,
          volume: 40 + _rng.nextDouble() * 620,
        ),
      );
      price = close;
      t = t.add(step);
    }
    if (endAt != null && candles.isNotEmpty) {
      return pinLastClose(candles, endAt);
    }
    return candles;
  }

  /// Apply live WS price onto the forming candle.
  Candle applyLivePrice(Candle current, double price) {
    return current.copyWith(
      close: price,
      high: max(current.high, price),
      low: min(current.low, price),
      volume: current.volume + _rng.nextDouble() * 2,
    );
  }

  /// Synthetic tick with occasional jumps / volume bursts.
  Candle tickLive(Candle current) {
    final jump = _rng.nextDouble() < 0.018;
    final burst = _rng.nextDouble() < 0.04;
    final amp = current.close * (jump ? (0.0018 + _rng.nextDouble() * 0.0022) : (0.00035 + _rng.nextDouble() * 0.001));
    final bias = jump ? (_rng.nextBool() ? 1.0 : -1.0) : (_rng.nextDouble() - 0.48);
    final next = (current.close + bias * amp).clamp(
      current.low * 0.997,
      current.high * 1.003 + amp,
    );
    return current.copyWith(
      close: next,
      high: max(current.high, next),
      low: min(current.low, next),
      volume: current.volume + _rng.nextDouble() * (burst ? 18 : 3),
    );
  }
}
