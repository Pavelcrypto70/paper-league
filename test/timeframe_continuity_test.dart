import 'package:flutter_test/flutter_test.dart';
import 'package:paper_league/data/market_feed.dart';
import 'package:paper_league/domain/models.dart';
import 'package:paper_league/state/desk_controller.dart';

void main() {
  test('pinLastClose keeps mark flat', () {
    final feed = MarketFeed(seed: 1);
    final series = feed.generateVolatileSeries(start: 100, count: 40);
    final pinned = feed.pinLastClose(series, 123.45);
    expect(pinned.last.close, 123.45);
    expect(pinned.last.high, 123.45);
    expect(pinned.last.low, 123.45);
  });

  test('setTimeframe preserves mark and does not stop-out', () async {
    final desk = DeskController(feed: MarketFeed(seed: 7));
    for (final s in MarketFeed.symbols) {
      desk.books[s.id] = MarketFeed(seed: 7).generateVolatileSeries(
        start: s.start,
        count: 80,
        endAt: s.start,
      );
    }
    desk.activeSymbol = 'BTCUSDT';
    desk.loading = false;
    final markBefore = desk.mark;
    desk.position = Position(
      id: 't1',
      symbol: 'BTCUSDT',
      side: Side.long,
      qty: 0.01,
      entry: markBefore,
      openedAt: DateTime.now(),
      stop: markBefore * 0.97,
      tp: markBefore * 1.04,
      entryAbsIndex: desk.candles.length - 1,
    );

    await desk.setTimeframe('5m');
    expect(desk.mark, closeTo(markBefore, 1e-9));
    expect(desk.position, isNotNull);
    expect(desk.candles.last.high, desk.mark);
    expect(desk.candles.last.low, desk.mark);

    // Deferred stop check clears without closing.
    desk.candles; // touch
    // Simulate deferred clear path via public timeframe already set.
    expect(desk.timeframe, '5m');
    expect(desk.position, isNotNull);

    await desk.setTimeframe('1h');
    expect(desk.mark, closeTo(markBefore, 1e-9));
    expect(desk.position, isNotNull);
  });

  test('barsPerDay scales with TF', () {
    expect(MarketFeed.barsPerDay('5m'), 288);
    expect(MarketFeed.barsPerDay('15m'), 96);
    expect(MarketFeed.barsPerDay('1h'), 24);
  });
}
