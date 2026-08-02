import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController();

  Locale locale = const Locale('en');

  bool get isRu => locale.languageCode == 'ru';

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final code = p.getString('lang') ?? 'en';
    locale = Locale(code);
    notifyListeners();
  }

  Future<void> setCode(String code) async {
    locale = Locale(code);
    final p = await SharedPreferences.getInstance();
    await p.setString('lang', code);
    notifyListeners();
  }

  void toggle() => setCode(isRu ? 'en' : 'ru');
}

class S {
  S(this._ru);
  final bool _ru;

  bool get isRu => _ru;

  static S of(BuildContext context) {
    final loc = Localizations.localeOf(context);
    return S(loc.languageCode == 'ru');
  }

  String get appName => _ru ? 'Paper League' : 'Paper League';
  String get enterDesk => _ru ? 'ВОЙТИ В ДЕСК' : 'ENTER DESK';
  String get splashTitle => _ru
      ? 'Дисциплина\nсчитается.'
      : 'Discipline\ngets scored.';
  String get splashSub => _ru
      ? 'Бумажный деск с обязательными стопами. Лига за контроль риска — не за удачу.'
      : 'Paper desk. Mandatory stops. League for risk control — not lottery PnL.';
  String get eduOnly => _ru
      ? 'Симуляция · без реальных денег'
      : 'Simulation · no real money';
  String get splashMark => 'PAPER LEAGUE';
  String get splashTag => _ru ? 'SEASON 28D' : 'SEASON 28D';

  String get desk => _ru ? 'Деск' : 'Desk';
  String get book => _ru ? 'Книга' : 'Book';
  String get league => _ru ? 'Лига' : 'League';
  String get you => _ru ? 'Вы' : 'You';

  String get last => _ru ? 'ЦЕНА' : 'LAST';
  String get equity => _ru ? 'ЭКВИТИ' : 'EQUITY';
  String get session => _ru ? 'СЕССИЯ' : 'SESSION';
  String get maxDd => _ru ? 'МАКС. ПР' : 'MAX DD';
  String get disc => _ru ? 'ДИСЦ' : 'DISC';
  String get long => 'LONG';
  String get short => 'SHORT';
  String get close => _ru ? 'ЗАКРЫТЬ' : 'CLOSE';
  String get clear => _ru ? 'ОЧИСТ' : 'CLEAR';
  String get live => 'LIVE';
  String get nicknameField => _ru ? 'Никнейм' : 'Nickname';
  String get qtyLabel => _ru ? 'Объём' : 'Qty';
  String get notionalLabel => _ru ? 'Ноционал' : 'Notional';
  String get slLabel => 'SL';
  String get tpLabel => 'TP';
  String get avgR => _ru ? 'Ср. R' : 'Avg R';
  String get streakLabel => _ru ? 'серия' : 'streak';
  String get scrub => _ru ? 'ЛЕНТА' : 'SCRUB';
  String get chartReset => _ru ? 'СБРОС' : 'RESET';
  String get demoTape => _ru ? 'Демо-лента' : 'Demo tape';
  String orderError(String code) => switch (code) {
        'close_first' => _ru ? 'Сначала закрой текущую позицию' : 'Close current position first',
        'no_data' => _ru ? 'Нет рыночных данных' : 'No market data',
        'stop_long' => _ru ? 'Стоп должен быть ниже входа' : 'Stop must be below entry',
        'stop_short' => _ru ? 'Стоп должен быть выше входа' : 'Stop must be above entry',
        'size_small' => _ru ? 'Слишком маленький размер' : 'Size too small',
        _ => code,
      };
  String get flatHint => _ru
      ? 'Флэт · тяни график · перетаскивай SL/TP и уровни'
      : 'Flat · pan chart · drag SL/TP and levels';
  String get topVol => _ru ? 'Топ волатильности' : 'Top volatility';
  String get topVolSub => _ru
      ? 'Сортировка по суточному range % · самые горячие сверху'
      : 'Sorted by 24h range % · hottest markets first';
  String get markets => _ru ? 'Рынки' : 'Markets';
  String get toolPointer => _ru ? 'Курсор / пан' : 'Pointer / pan';
  String get toolLevel => _ru ? 'Горизонталь' : 'Horizontal level';
  String get toolLine => _ru ? 'Линия' : 'Free line';
  String get toolErase => _ru ? 'Ластик' : 'Erase';

  String get ticket => _ru ? 'Тикет' : 'Ticket';
  String get mark => _ru ? 'Марк' : 'Mark';
  String get stopDistance => _ru ? 'ДИСТАНЦИЯ СТОПА' : 'STOP DISTANCE';
  String get riskEquity => _ru ? 'РИСК / ЭКВИТИ' : 'RISK / EQUITY';
  String get takeProfit => _ru ? 'ТЕЙК-ПРОФИТ' : 'TAKE PROFIT';
  String get placeLong => _ru ? 'ОТКРЫТЬ LONG' : 'PLACE LONG';
  String get placeShort => _ru ? 'ОТКРЫТЬ SHORT' : 'PLACE SHORT';
  String ifStopped(String money) =>
      _ru ? 'если стоп −$money' : 'if stopped −$money';

  String get positions => _ru ? 'Позиции' : 'Positions';
  String get positionsSub => _ru
      ? 'Риск-деск · частичные закрытия · стопы'
      : 'Risk desk · partials · stop management';
  String get history => _ru ? 'История' : 'History';
  String get flat => _ru ? 'Флэт' : 'Flat';
  String get noOpen => _ru
      ? 'Нет открытого риска. Открой сделку со стопом на Деске.'
      : 'No open risk. Open from Desk with a mandatory stop.';
  String get close50 => _ru ? 'Закрыть 50%' : 'Close 50%';
  String get closeAll => _ru ? 'Закрыть всё' : 'Close all';
  String get tighten => _ru ? 'ПОДТЯНУТЬ' : 'TIGHTEN';

  String get leagueTitle => _ru ? 'Сезонная лига' : 'Season League';
  String get leagueRules => _ru
      ? '60% дисциплина · 25% контроль просадки · 15% доходность · сезон 28 дней'
      : '60% discipline · 25% DD control · 15% return · 28-day season';
  String get rank => _ru ? 'МЕСТО' : 'RANK';

  String get profile => _ru ? 'Карточка трейдера' : 'Trader card';
  String get profileSub => _ru
      ? 'Профиль · кривая эквити · статистика'
      : 'Identity · equity curve · session stats';
  String get tapPhoto => _ru ? 'Нажми на аватар для фото' : 'Tap avatar for photo';
  String get equityCurve => _ru ? 'КРИВАЯ ЭКВИТИ' : 'EQUITY CURVE';
  String get trades => _ru ? 'СДЕЛКИ' : 'TRADES';
  String get winRate => _ru ? 'ПЛЮС %' : 'WIN RATE';
  String get lossRate => _ru ? 'МИНУС %' : 'LOSS RATE';
  String get fromStart => _ru ? 'ОТ СТАРТА' : 'FROM START';
  String get ofClosed => _ru ? 'из закрытых' : 'of closed';
  String get vsStart => _ru ? 'к \$10,000' : 'vs \$10,000';
  String get journal => _ru ? 'Журнал' : 'Journal';
  String get noTrades => _ru ? 'Пока нет закрытых сделок.' : 'No closed trades yet.';
  String get resetAccount => _ru ? 'Сбросить бумажный счёт' : 'Reset paper account';
  String get resetTitle => _ru ? 'Сбросить счёт?' : 'Reset paper account?';
  String get resetBody => _ru
      ? 'Снова \$10,000. История очистится.'
      : 'Back to \$10,000. History cleared.';
  String get cancel => _ru ? 'Отмена' : 'Cancel';
  String get reset => _ru ? 'Сбросить' : 'Reset';
  String get language => _ru ? 'Язык' : 'Language';
  String get english => 'English';
  String get russian => 'Русский';

  String get recap => _ru ? 'ИТОГ СДЕЛКИ' : 'TRADE RECAP';
  String get backToDesk => _ru ? 'НА ДЕСК' : 'BACK TO DESK';
  String get discipline => _ru ? 'Дисциплина' : 'Discipline';
  String get flagStop => _ru ? 'Стоп до входа' : 'Stop set before entry';
  String get flagSize => _ru ? 'Размер в лимите риска' : 'Size within risk budget';
  String get flagWiden => _ru ? 'Стоп не отодвигали' : 'Stop not widened';
  String get flagRevenge => _ru ? 'Без реванш-сделок' : 'No revenge burst';

  String get coachTitle => _ru ? 'Первая сделка' : 'First trade';
  String get coachBody => _ru
      ? 'Поставь стоп до входа · риск ≤2.5% · не отодвигай SL'
      : 'Set stop before entry · risk ≤2.5% · don’t widen SL';
  String get dismiss => _ru ? 'Понятно' : 'Got it';
  String get manage => _ru ? 'УПРАВЛЕНИЕ' : 'MANAGE';
  String get waitingMarket => _ru ? 'Ждём рынок…' : 'Waiting for market…';
  String get tapeReplay => _ru ? 'ЛЕНТА СДЕЛКИ' : 'TRADE TAPE';
  String get mfe => 'MFE';
  String get mae => 'MAE';
  String exitLabel(String kind) {
    if (_ru) {
      return switch (kind) {
        'stop' => 'Выход: стоп',
        'tp' => 'Выход: тейк',
        'partial' => 'Выход: частичный',
        _ => 'Выход: вручную',
      };
    }
    return switch (kind) {
      'stop' => 'Exit: stop',
      'tp' => 'Exit: take profit',
      'partial' => 'Exit: partial',
      _ => 'Exit: manual',
    };
  }

  String get guideTitle => _ru ? 'ГИД ДЕСКА' : 'DESK GUIDE';
  String get guideCta => _ru ? 'Гид · глоссарий · кнопки' : 'Guide · glossary · buttons';
  String get guideNext => _ru ? 'ДАЛЬШЕ' : 'NEXT';
  String get guideBack => _ru ? 'НАЗАД' : 'BACK';
  String get guideDone => _ru ? 'НА ДЕСК' : 'GOT IT';

  String get achievements => _ru ? 'Ачивки' : 'Achievements';
  String get achievementsSub => _ru
      ? 'Награды за дисциплину и процесс, не за лудоманство'
      : 'Badges for discipline and process — not lottery wins';
  String get achievementUnlocked => _ru ? 'АЧИВКА' : 'ACHIEVEMENT';

  String get shareRecap => _ru ? 'ПОДЕЛИТЬСЯ' : 'SHARE CARD';
  String get shareTagline => _ru ? 'дисциплина считается' : 'discipline gets scored';
  String get shareCopied => _ru ? 'Текст сделки скопирован' : 'Trade text copied';
  String get shareWebHint => _ru
      ? 'В вебе шарится текст — на телефоне уйдёт картинка'
      : 'Web shares text — on phone you get the image card';

  String get weeklyReport => _ru ? 'НЕДЕЛЬНЫЙ ОТЧЁТ' : 'WEEKLY REPORT';
  String get weeklyReportSub => _ru
      ? 'Паттерны за 7 дней · не лотерея PnL'
      : '7-day patterns · not lottery PnL';
  String get weeklyReportCta => _ru ? 'Недельный отчёт паттернов' : 'Weekly pattern report';
  String get weeklyPatterns => _ru ? 'Что бросается в глаза' : 'What stands out';
  String get widenRate => _ru ? 'WIDEN %' : 'WIDEN %';
  String get leftOnTable => _ru ? 'LEFT R' : 'LEFT R';
  String get revengeShort => _ru ? 'REVENGE' : 'REVENGE';

  String get season => _ru ? 'СЕЗОН' : 'SEASON';
  String get day => _ru ? 'ДЕНЬ' : 'DAY';
  String get seasonHint => _ru
      ? '28 дней · рейтинг сезона сбрасывается · счёт и эквити остаются'
      : '28 days · season rank resets · account & equity stay';
  String get podium => _ru ? 'Пьедестал' : 'Podium';
  String get standings => _ru ? 'Таблица' : 'Standings';
  String get leagueRulesShort => _ru ? '60/25/15' : '60/25/15';
  String get training => _ru ? 'Тренировка' : 'Training';
  String get tapeDrill => _ru ? 'Tape Drill' : 'Tape Drill';
  String get tapeDrillSub => _ru ? 'История · план · очки процесса' : 'History · plan · process pts';
  String get tapeDrillHelp => _ru
      ? 'Крути ленту до маркера. Long / Short / Skip со стопом. Очки за план, не за угадайку.'
      : 'Scrub to the marker. Long / Short / Skip with a stop. Points for plan, not guessing.';
  String get tapeDrillEmpty => _ru ? 'Мало свечей для дрилла' : 'Not enough candles for drill';
  String get processPts => _ru ? 'PTS' : 'PTS';
  String get stopAtr => 'STOP ATR';
  String get tpR => 'TP R';
  String get skip => _ru ? 'СКИП' : 'SKIP';
  String get revealTape => _ru ? 'ПОКАЗАТЬ ЛЕНТУ' : 'REVEAL TAPE';
  String get nextDrill => _ru ? 'ЕЩЁ РАУНД' : 'NEXT ROUND';
  String get back => _ru ? 'НАЗАД' : 'BACK';
  String get playbooks => _ru ? 'Playbooks' : 'Playbooks';
  String get playbooksSub => _ru ? 'Сетапы на график' : 'Setups to chart';
  String get playbooksHelp => _ru
      ? 'Сохранённые SL/TP структуры. Apply рисует уровни на активном инструменте.'
      : 'Saved SL/TP structures. Apply draws levels on the active symbol.';
  String get addPlaybook => _ru ? 'Добавить сетап' : 'Add setup';
  String get applyChart => _ru ? 'НА ГРАФИК' : 'TO CHART';
  String get playbookApplied => _ru ? 'Playbook на графике' : 'Playbook on chart';

  String get dailyDesk => _ru ? 'DAILY DESK' : 'DAILY DESK';
  String get dailyPlan => _ru ? 'План' : 'Plan';
  String get dailyStop => _ru ? 'Стоп' : 'Stop';
  String get dailyDrill => 'Drill';
  String get dailyShare => _ru ? 'Шер' : 'Share';

  String get preTrade => _ru ? 'Pre-trade check' : 'Pre-trade check';
  String get preTradeSub => _ru
      ? 'Четыре галочки до тикета. Это и есть дисциплина.'
      : 'Four checks before the ticket. This is the discipline.';
  String get preThesis => _ru ? 'Есть тезис / уровень' : 'I have a thesis / level';
  String get preStop => _ru ? 'Стоп уже на графике' : 'Stop is already planned';
  String get preSize => _ru ? 'Риск ≤ 2% эквити' : 'Risk ≤ 2% equity';
  String get preCalm => _ru ? 'Не реванш после минуса' : 'Not revenge after a loss';
  String get preTradeGo => _ru ? 'К ТИКЕТУ' : 'TO TICKET';

  String get liveFeed => _ru ? 'Пульс лиги' : 'League pulse';
  String get seasonHistory => _ru ? 'История сезонов' : 'Season history';
  String get seasonRewards => _ru ? 'Награды сезона' : 'Season rewards';

  String get shareRitualTitle => _ru ? 'Ритуал шаринга' : 'Share ritual';
  String get shareRitualBody => _ru
      ? 'Чистый процесс. Кинь карточку в сторис — Daily Desk засчитает Share.'
      : 'Clean process. Drop the card to stories — Daily Desk counts Share.';

  String get drillIntroTitle => _ru ? 'Tape Drill' : 'Tape Drill';
  String get drillIntroBody => _ru
      ? 'Крути ленту. На маркере — план со стопом. Очки за процесс, не за угадайку.'
      : 'Scrub the tape. At the marker — plan with a stop. Points for process, not guessing.';
  String get drillIntroGo => _ru ? 'НАЧАТЬ' : 'START';

  String get pbIntroTitle => _ru ? 'Playbooks' : 'Playbooks';
  String get pbIntroBody => _ru
      ? 'Сохранённые SL/TP. Одним тапом уровни на активный символ.'
      : 'Saved SL/TP. One tap paints levels on the active symbol.';

  String get authTitle => _ru ? 'Войти в лигу' : 'Enter the league';
  String get authSubOnline => _ru
      ? 'Аккаунт синхронизирует сезон и рейтинг. Деск работает и офлайн.'
      : 'Account syncs season and ranking. Desk still works offline.';
  String get authSubDemo => _ru
      ? 'Supabase не настроен — DEMO лига на устройстве. Добавь SUPABASE_URL / ANON_KEY.'
      : 'Supabase not configured — DEMO league on device. Pass SUPABASE_URL / ANON_KEY.';
  String get email => 'Email';
  String get password => _ru ? 'Пароль' : 'Password';
  String get signIn => _ru ? 'ВОЙТИ' : 'SIGN IN';
  String get signUp => _ru ? 'РЕГИСТРАЦИЯ' : 'SIGN UP';
  String get haveAccount => _ru ? 'Уже есть аккаунт' : 'Already have an account';
  String get needAccount => _ru ? 'Создать аккаунт' : 'Create account';
  String get continueGuest => _ru ? 'ПРОДОЛЖИТЬ КАК ГОСТЬ' : 'CONTINUE AS GUEST';
  String get authFootnote => _ru
      ? 'Симуляция · без реальных денег · сезон 28 дней'
      : 'Simulation · no real money · 28-day season';

  String get leagueLive => 'LIVE';
  String get leagueDemo => 'DEMO';
  String get division => _ru ? 'Дивизион' : 'Division';

  String get ceremonyTitle => _ru ? 'Сезон открыт' : 'Season open';
  String get ceremonyBody => _ru
      ? 'Рейтинг сезона обнулён. Эквити и история сделок остаются.'
      : 'Season rank resets. Equity and trade history stay.';
  String get ceremonyGo => _ru ? 'В ЛИГУ' : 'TO LEAGUE';
  String get finalsPulse => _ru ? 'Финал сезона' : 'Season finals';

  String get firstRunTitle => _ru ? 'Первый заход' : 'First run';
  String get firstRunBody => _ru
      ? 'Сделай одну сделку со стопом. Pre-trade check обязателен.'
      : 'Take one trade with a stop. Pre-trade check is required.';
  String get firstRunCta => _ru ? 'ПОНЯЛ' : 'GOT IT';
  String get firstRunStep1Title => _ru ? 'Стоп обязателен' : 'Stop is mandatory';
  String get firstRunStep1Body => _ru
      ? 'Без стопа нет сделки. Лига считает дисциплину, не удачу.'
      : 'No stop, no trade. League scores discipline, not luck.';
  String get firstRunStep2Title => _ru ? 'Pre-trade check' : 'Pre-trade check';
  String get firstRunStep2Body => _ru
      ? 'Четыре галочки перед тикетом — тезис, стоп, размер, спокойствие.'
      : 'Four checks before the ticket — thesis, stop, size, calm.';
  String get firstRunStep3Title => _ru ? 'Открой первую' : 'Open the first';
  String get firstRunStep3Body => _ru
      ? 'Long или Short на деске. После закрытия увидишь рекап и Daily Desk.'
      : 'Long or Short on the desk. After close you’ll see recap and Daily Desk.';
  String get deskOffline => 'OFFLINE';
  String get deskLiveTape => 'LIVE TAPE';
  String get leagueRetry => _ru ? 'ОБНОВИТЬ' : 'REFRESH';
  String get leagueStale => _ru ? 'Рейтинг устарел · нажми обновить' : 'Board stale · tap refresh';
  String get nickRequired => _ru ? 'Задай ник для публикации в лигу' : 'Set a nickname to publish to the league';
  String get upgradeAccount => _ru ? 'Привязать email' : 'Link email';
  String get preTradeSkip => _ru ? 'ПРОПУСТИТЬ' : 'SKIP';
  String get preTradeSoft => _ru ? 'Быстрый вход без чека?' : 'Skip check this time?';
  String get credits => 'Credits';
  String get upgradeShop => _ru ? 'Апгрейды деска' : 'Desk upgrades';
  String get notEnoughCredits => _ru ? 'Не хватает credits' : 'Not enough credits';
  String get owned => _ru ? 'Есть' : 'Owned';
  String get exportTelemetry => _ru ? 'Экспорт телеметрии' : 'Export telemetry';
  String get leagueStartApi => _ru
      ? 'LIVE пустой · запусти tool/league_api или открой второй клиент'
      : 'LIVE empty · start tool/league_api or open a second client';
  String get leagueDemoHint => _ru
      ? 'DEMO · боты на устройстве. Для LIVE: dart run bin/server.dart'
      : 'DEMO · on-device bots. For LIVE: dart run bin/server.dart';
  String get wsTape => 'WS';
  String get playbookSlotsFull => _ru ? 'Лимит playbooks — купи слот в апгрейдах' : 'Playbook limit — buy a slot in upgrades';
  String get seasonTrack => _ru ? 'ТРЕК СЕЗОНА' : 'SEASON TRACK';
  String get weeklyChallenges => _ru ? 'Недельные челленджи' : 'Weekly challenges';
  String get claim => _ru ? 'ЗАБРАТЬ' : 'CLAIM';
  String get trackClaimToday => _ru ? 'Награда дня' : "Today's reward";
  String get trackClaimed => _ru ? 'Узел дня забран' : 'Day node claimed';
  String get trackNeedActive => _ru ? 'Зайди на деск сегодня, потом забери' : 'Be active on desk today, then claim';
  String get trackCatchUpFail => _ru
      ? 'Догон недоступен — нужны credits или токен'
      : 'Catch-up locked — need credits or token';
  String get shields => _ru ? 'Щиты' : 'Shields';
}
