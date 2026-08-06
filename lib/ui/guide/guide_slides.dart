enum GuideMockKind { welcome, desk, chart, ticket, position, terms, tabs, recap }

class GuidePoint {
  const GuidePoint({required this.label, required this.detail});
  final String label;
  final String detail;
}

class GuideSlide {
  const GuideSlide({
    required this.kicker,
    required this.title,
    required this.body,
    required this.points,
    required this.mock,
  });

  final String kicker;
  final String title;
  final String body;
  final List<GuidePoint> points;
  final GuideMockKind mock;
}

List<GuideSlide> buildGuideSlides({required bool ru}) {
  if (ru) {
    return const [
      GuideSlide(
        kicker: '01 · ПРОДУКТ',
        title: 'Paper League —\nдеск дисциплины',
        body:
            'Это не слоты «угадай свечу». Ты торгуешь бумажным счётом \$10k, а лига считает контроль риска, а не лотерейный PnL.',
        points: [
          GuidePoint(label: 'Эквити', detail: 'Виртуальные \$10,000. Без реальных денег.'),
          GuidePoint(label: 'Стоп обязателен', detail: 'Нельзя войти без защитного стопа.'),
          GuidePoint(label: 'Лига', detail: '60% дисциплина · 25% просадка · 15% доходность.'),
        ],
        mock: GuideMockKind.welcome,
      ),
      GuideSlide(
        kicker: '02 · ДЕСК',
        title: 'Главный экран\nтерминала',
        body: 'Всё важное сверху: рынок, цена, метрики. График — центр. Снизу — вход в сделку или управление позицией.',
        points: [
          GuidePoint(label: 'Символ + VOL%', detail: 'Тап открывает топ рынков по суточной волатильности.'),
          GuidePoint(label: '5m / 15m / 30m / 1h', detail: 'Таймфрейм свечей (цена и позиция сохраняются).'),
          GuidePoint(label: 'EQUITY / SESSION / MAX DD / DISC', detail: 'Счёт, сессия, макс. просадка, очки дисциплины.'),
          GuidePoint(label: 'LONG / SHORT', detail: 'Открывает тикет ордера. Если позиция уже есть — кнопка «Закрыть всё».'),
        ],
        mock: GuideMockKind.desk,
      ),
      GuideSlide(
        kicker: '03 · ГРАФИК',
        title: 'Жесты и\nинструменты',
        body: 'График — рабочий стол. Тяни ленту, перетаскивай уровни и стопы, рисуй разметку.',
        points: [
          GuidePoint(label: 'Пан', detail: 'Свайп влево/вправо по свечам. LIVE возвращает к краю.'),
          GuidePoint(label: 'Тап', detail: 'Кроссхейр + OHLC выбранной свечи.'),
          GuidePoint(label: 'SL / TP', detail: 'Потяни красную/зелёную линию — стоп и тейк двигаются.'),
          GuidePoint(label: 'Уровень / Линия / Ластик', detail: 'Горизонталь, свободная линия, стереть. CLEAR — всё сразу.'),
        ],
        mock: GuideMockKind.chart,
      ),
      GuideSlide(
        kicker: '04 · ТИКЕТ',
        title: 'Как открыть\nсделку',
        body: 'Тикет считает размер от риска. Стоп задаёт дистанцию, риск — сколько эквити поставить на кон.',
        points: [
          GuidePoint(label: 'STOP DISTANCE', detail: 'Насколько далеко стоп от марки (0.8% / 1.5% / 2.5%).'),
          GuidePoint(label: 'RISK / EQUITY', detail: 'Слайдер 0.5–5%. Показывает убыток «если стоп».'),
          GuidePoint(label: 'TAKE PROFIT', detail: 'Цель в R (1.0R … 3.0R) от стоп-дистанции.'),
          GuidePoint(label: 'PLACE LONG / SHORT', detail: 'Маркет-вход. Звук fill + позиция на графике.'),
        ],
        mock: GuideMockKind.ticket,
      ),
      GuideSlide(
        kicker: '05 · ПОЗИЦИЯ',
        title: 'Управление\nриском',
        body: 'Открытая позиция подсвечена PnL. Не отодвигай стоп «надеясь» — это бьёт по DISC.',
        points: [
          GuidePoint(label: '50%', detail: 'Закрыть половину. Остаток остаётся со стопом.'),
          GuidePoint(label: 'ПОДТЯНУТЬ', detail: 'Приближает стоп к цене (фиксирует часть риска).'),
          GuidePoint(label: 'ЗАКРЫТЬ', detail: 'Полный выход → рекап с лентой IN/OUT и советами.'),
          GuidePoint(label: 'Авто SL / TP', detail: 'Если цена ударила уровень — выход сам + рекап.'),
        ],
        mock: GuideMockKind.position,
      ),
      GuideSlide(
        kicker: '06 · ТЕРМИНЫ',
        title: 'Глоссарий\nдеска',
        body: 'Короткие определения — чтобы читать терминал без «что это было».',
        points: [
          GuidePoint(label: 'R (R-multiple)', detail: 'Прибыль/убыток в единицах начального риска. +2R = два риска в плюс.'),
          GuidePoint(label: 'MFE / MAE', detail: 'Макс. плюс и макс. минус по пути сделки (в рекапе).'),
          GuidePoint(label: 'DISC', detail: 'Дисциплина 0–100. Широкий стоп и реванш режут счёт.'),
          GuidePoint(label: 'MAX DD', detail: 'Максимальная просадка эквити от пика.'),
          GuidePoint(label: 'Mark / Last', detail: 'Текущая цена ленты активного рынка.'),
        ],
        mock: GuideMockKind.terms,
      ),
      GuideSlide(
        kicker: '07 · НАВИГАЦИЯ',
        title: 'Четыре вкладки\nтерминала',
        body: 'Низ экрана — переключение зон. Та же история сделок доступна в Книге и в профиле.',
        points: [
          GuidePoint(label: 'Деск', detail: 'График, ордера, живой риск.'),
          GuidePoint(label: 'Книга', detail: 'Открытая позиция + история закрытий.'),
          GuidePoint(label: 'Лига', detail: 'Недельный рейтинг по формуле дисциплины.'),
          GuidePoint(label: 'Вы', detail: 'Профиль, язык, кривая эквити, этот гид.'),
        ],
        mock: GuideMockKind.tabs,
      ),
      GuideSlide(
        kicker: '08 · РЕКАП',
        title: 'Разбор после\nзакрытия',
        body: 'Каждая закрытая сделка получает ленту с IN/OUT и мини-коучинг: почему минус или как усилить плюс.',
        points: [
          GuidePoint(label: 'Лента сделки', detail: 'Снимок свечей вокруг входа и выхода.'),
          GuidePoint(label: 'MFE / MAE', detail: 'Сколько «оставили на столе» или как глубоко просели.'),
          GuidePoint(label: 'Флаги', detail: 'Стоп до входа, размер, без widen, без реванша.'),
          GuidePoint(label: 'Советы', detail: 'Правила по структуре ленты и пути цены — на RU/EN.'),
        ],
        mock: GuideMockKind.recap,
      ),
    ];
  }

  return const [
    GuideSlide(
      kicker: '01 · PRODUCT',
      title: 'Paper League —\ndiscipline desk',
      body:
          'Not a candle lottery. You trade a \$10k paper book. The league scores risk control — not lucky PnL.',
      points: [
        GuidePoint(label: 'Equity', detail: 'Virtual \$10,000. No real money.'),
        GuidePoint(label: 'Mandatory stop', detail: 'No entry without protective stop.'),
        GuidePoint(label: 'League', detail: '60% discipline · 25% drawdown · 15% return.'),
      ],
      mock: GuideMockKind.welcome,
    ),
    GuideSlide(
      kicker: '02 · DESK',
      title: 'Your trading\nterminal',
      body: 'Market, mark, and metrics up top. Chart is the stage. Bottom = open ticket or manage risk.',
      points: [
        GuidePoint(label: 'Symbol + VOL%', detail: 'Tap for top markets by 24h range volatility.'),
          GuidePoint(label: '5m / 15m / 30m / 1h', detail: 'Candle timeframe (mark & open risk stay continuous).'),
        GuidePoint(label: 'EQUITY / SESSION / MAX DD / DISC', detail: 'Book, session PnL, peak drawdown, discipline.'),
        GuidePoint(label: 'LONG / SHORT', detail: 'Opens the order ticket. With a position open → Close all.'),
      ],
      mock: GuideMockKind.desk,
    ),
    GuideSlide(
      kicker: '03 · CHART',
      title: 'Gestures &\ntools',
      body: 'The chart is the workbench. Pan the tape, drag stops, draw levels.',
      points: [
        GuidePoint(label: 'Pan', detail: 'Swipe candles. LIVE snaps back to the edge.'),
        GuidePoint(label: 'Tap', detail: 'Crosshair + OHLC for the selected bar.'),
        GuidePoint(label: 'SL / TP', detail: 'Drag the red/green lines to move stop and take profit.'),
        GuidePoint(label: 'Level / Line / Erase', detail: 'Horizontal, free line, erase. CLEAR wipes drawings.'),
      ],
      mock: GuideMockKind.chart,
    ),
    GuideSlide(
      kicker: '04 · TICKET',
      title: 'How to open\na trade',
      body: 'Size is risk-based. Stop sets distance; risk sets how much equity you put on the line.',
      points: [
        GuidePoint(label: 'STOP DISTANCE', detail: 'How far the stop sits from mark (0.8% / 1.5% / 2.5%).'),
        GuidePoint(label: 'RISK / EQUITY', detail: '0.5–5% slider. Shows cash lost if stopped.'),
        GuidePoint(label: 'TAKE PROFIT', detail: 'Target in R (1.0R … 3.0R) from stop distance.'),
        GuidePoint(label: 'PLACE LONG / SHORT', detail: 'Market fill. Fill SFX + position on the chart.'),
      ],
      mock: GuideMockKind.ticket,
    ),
    GuideSlide(
      kicker: '05 · POSITION',
      title: 'Managing\nrisk live',
      body: 'Open risk is tinted by PnL. Don’t widen the stop “hoping” — DISC takes the hit.',
      points: [
        GuidePoint(label: '50%', detail: 'Close half. Runner keeps the stop.'),
        GuidePoint(label: 'TIGHTEN', detail: 'Pulls stop toward mark (banks some risk).'),
        GuidePoint(label: 'CLOSE', detail: 'Full exit → recap with IN/OUT tape + coaching.'),
        GuidePoint(label: 'Auto SL / TP', detail: 'Level hit = auto exit + recap ceremony.'),
      ],
      mock: GuideMockKind.position,
    ),
    GuideSlide(
      kicker: '06 · TERMS',
      title: 'Desk\nglossary',
      body: 'Short definitions so the terminal reads without “what was that?”',
      points: [
        GuidePoint(label: 'R (R-multiple)', detail: 'PnL in units of initial risk. +2R = two risks won.'),
        GuidePoint(label: 'MFE / MAE', detail: 'Best and worst excursion during the trade (in recap).'),
        GuidePoint(label: 'DISC', detail: 'Discipline 0–100. Widened stops and revenge cuts score.'),
        GuidePoint(label: 'MAX DD', detail: 'Max equity drawdown from peak.'),
        GuidePoint(label: 'Mark / Last', detail: 'Live tape price of the active market.'),
      ],
      mock: GuideMockKind.terms,
    ),
    GuideSlide(
      kicker: '07 · NAV',
      title: 'Four terminal\ntabs',
      body: 'Bottom bar switches zones. Trade history lives in Book and on your card.',
      points: [
        GuidePoint(label: 'Desk', detail: 'Chart, tickets, live risk.'),
        GuidePoint(label: 'Book', detail: 'Open position + closed history.'),
        GuidePoint(label: 'League', detail: 'Weekly board by the discipline formula.'),
        GuidePoint(label: 'You', detail: 'Profile, language, equity curve, this guide.'),
      ],
      mock: GuideMockKind.tabs,
    ),
    GuideSlide(
      kicker: '08 · RECAP',
      title: 'Post-trade\nbreakdown',
      body: 'Every close gets an IN/OUT tape and mini-coach: why red, or how to bank more green.',
      points: [
        GuidePoint(label: 'Trade tape', detail: 'Candle snapshot around entry and exit.'),
        GuidePoint(label: 'MFE / MAE', detail: 'How much left on the table — or how deep you dipped.'),
        GuidePoint(label: 'Flags', detail: 'Stop set, size OK, no widen, no revenge.'),
        GuidePoint(label: 'Tips', detail: 'Rule-based coaching from path + structure — RU/EN.'),
      ],
      mock: GuideMockKind.recap,
    ),
  ];
}
