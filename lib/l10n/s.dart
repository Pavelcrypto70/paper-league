import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLang {
  en('en', 'English'),
  es('es', 'Español'),
  pt('pt', 'Português (Brasil)'),
  ru('ru', 'Русский');

  const AppLang(this.code, this.nativeLabel);

  final String code;
  final String nativeLabel;

  static AppLang fromCode(String? code) =>
      AppLang.values.where((value) => value.code == code).firstOrNull ??
      AppLang.en;
}

class LocaleController extends ChangeNotifier {
  LocaleController();

  static const _langKey = 'lang';
  static const _langChosenKey = 'lang_chosen_v1';

  Locale locale = const Locale('en');
  bool languageChosen = false;
  bool ready = false;

  bool get isRu => locale.languageCode == 'ru';
  AppLang get lang => AppLang.fromCode(locale.languageCode);

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    languageChosen = p.getBool(_langChosenKey) ?? false;
    // A previously saved locale is only meaningful after the user has
    // explicitly completed the language gate.
    locale = Locale(
      languageChosen ? AppLang.fromCode(p.getString(_langKey)).code : 'en',
    );
    ready = true;
    notifyListeners();
  }

  Future<void> setCode(String code) async {
    final lang = AppLang.fromCode(code);
    locale = Locale(lang.code);
    final p = await SharedPreferences.getInstance();
    await p.setString(_langKey, lang.code);
    await p.setBool(_langChosenKey, true);
    languageChosen = true;
    notifyListeners();
  }

  Future<void> chooseLanguage(AppLang lang) => setCode(lang.code);

  Future<void> resetLanguageChoice() async {
    languageChosen = false;
    locale = const Locale('en');
    final p = await SharedPreferences.getInstance();
    await p.setBool(_langChosenKey, false);
    notifyListeners();
  }
}

class S {
  S(this.lang);
  final AppLang lang;

  bool get isRu => lang == AppLang.ru;

  static S of(BuildContext context) {
    final loc = Localizations.localeOf(context);
    return S(AppLang.fromCode(loc.languageCode));
  }

  /// Uses English when a caller has no translation for a new string yet.
  String t(String en, {String? es, String? pt, String? ru}) => switch (lang) {
    AppLang.es => es ?? en,
    AppLang.pt => pt ?? en,
    AppLang.ru => ru ?? en,
    AppLang.en => en,
  };

  String _es(String value) => _translate(value, _esTerms);
  String _pt(String value) => _translate(value, _ptTerms);
  String _translate(String value, Map<String, String> terms) {
    var result = value;
    for (final entry in terms.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
  }

  static const _esTerms = <String, String>{
    'Discipline\ngets scored.': 'La disciplina\ncuenta.',
    'Paper desk. Mandatory stops. League for risk control — not lottery PnL.':
        'Mesa simulada. Stops obligatorios. Una liga de control de riesgo, no de PnL por suerte.',
    'Simulation · no real money': 'Simulación · sin dinero real',
    'Close current position first': 'Cierra primero la posición actual',
    'No market data': 'No hay datos de mercado',
    'Stop must be below entry': 'El stop debe estar por debajo de la entrada',
    'Stop must be above entry': 'El stop debe estar por encima de la entrada',
    'Size too small': 'El tamaño es demasiado pequeño',
    'No open risk. Open from Desk with a mandatory stop.':
        'No hay riesgo abierto. Abre una operación en la mesa con un stop obligatorio.',
    'Risk desk · partials · stop management':
        'Mesa de riesgo · cierres parciales · gestión de stop',
    '60% discipline · 25% DD control · 15% return · 28-day season':
        '60% disciplina · 25% control de DD · 15% rentabilidad · temporada de 28 días',
    'Identity · equity curve · session stats':
        'Identidad · curva de capital · estadísticas de sesión',
    'No closed trades yet.': 'Aún no hay operaciones cerradas.',
    'Back to \$10,000. History cleared.':
        'Vuelve a \$10,000. Se borrará el historial.',
    'Set stop before entry · risk ≤2.5% · don’t widen SL':
        'Define el stop antes de entrar · riesgo ≤2.5% · no amplíes el SL',
    'Waiting for market…': 'Esperando al mercado…',
    'Badges for discipline and process — not lottery wins':
        'Insignias por disciplina y proceso, no por ganancias de suerte',
    '7-day patterns · not lottery PnL':
        'Patrones de 7 días · no PnL por suerte',
    'Four checks before the ticket. This is the discipline.':
        'Cuatro comprobaciones antes del ticket. Eso es disciplina.',
    'Account syncs season and ranking. Desk still works offline.':
        'La cuenta sincroniza temporada y clasificación. La mesa también funciona sin conexión.',
    'Simulation · no real money · 28-day season':
        'Simulación · sin dinero real · temporada de 28 días',
    'Discipline': 'Disciplina',
    'discipline': 'disciplina',
    'Desk': 'Mesa',
    'desk': 'mesa',
    'League': 'Liga',
    'league': 'liga',
    'Paper': 'Simulado',
    'paper': 'simulado',
    'Simulation': 'Simulaci\u00f3n',
    'simulation': 'simulaci?n',
    'no real money': 'sin dinero real',
    'Enter': 'Entrar',
    'ENTER': 'ENTRAR',
    'Close': 'Cerrar',
    'CLOSE': 'CERRAR',
    'Clear': 'Limpiar',
    'CLEAR': 'LIMPIAR',
    'Markets': 'Mercados',
    'Market': 'Mercado',
    'market': 'mercado',
    'Positions': 'Posiciones',
    'Position': 'Posici\u00f3n',
    'History': 'Historial',
    'Profile': 'Perfil',
    'Language': 'Idioma',
    'language': 'idioma',
    'Cancel': 'Cancelar',
    'Reset': 'Restablecer',
    'Back': 'Volver',
    'BACK': 'VOLVER',
    'Next': 'Siguiente',
    'NEXT': 'SIGUIENTE',
    'Done': 'Listo',
    'Guide': 'Gu\u00eda',
    'Training': 'Entrenamiento',
    'Achievements': 'Logros',
    'Achievement': 'Logro',
    'Share': 'Compartir',
    'Report': 'Informe',
    'report': 'informe',
    'Season': 'Temporada',
    'season': 'temporada',
    'Day': 'D\u00eda',
    'day': 'd\u00eda',
    'Rank': 'Puesto',
    'RANK': 'PUESTO',
    'Rules': 'Reglas',
    'rules': 'reglas',
    'Open': 'Abrir',
    'OPEN': 'ABRIR',
    'Save': 'Guardar',
    'SAVE': 'GUARDAR',
    'Start': 'Empezar',
    'START': 'EMPEZAR',
    'Continue': 'Continuar',
    'Guest': 'Invitado',
    'Account': 'Cuenta',
    'Password': 'Contrase\u00f1a',
    'Nickname': 'Apodo',
    'risk': 'riesgo',
    'Risk': 'Riesgo',
    'Trade': 'Operaci\u00f3n',
    'trade': 'operaci\u00f3n',
    'Trades': 'Operaciones',
    'trades': 'operaciones',
    'Refresh': 'Actualizar',
    'REFRESH': 'ACTUALIZAR',
    'Claim': 'Reclamar',
    'CLAIM': 'RECLAMAR',
    'Owned': 'Obtenido',
    'Waiting': 'Esperando',
    'waiting': 'esperando',
    'First': 'Primera',
    'first': 'primera',
    'Mandatory': 'Obligatorio',
    'mandatory': 'obligatorio',
    'You': 'T\u00fa',
    'you': 't\u00fa',
    'Your': 'Tu',
    'your': 'tu',
    'with': 'con',
    'and': 'y',
    'or': 'o',
    'for': 'para',
    'from': 'desde',
    'to': 'a',
  };
  static const _ptTerms = <String, String>{
    'Discipline\ngets scored.': 'Disciplina\nfaz diferença.',
    'Paper desk. Mandatory stops. League for risk control — not lottery PnL.':
        'Mesa simulada. Stops obrigatórios. Uma liga de controle de risco, não de PnL por sorte.',
    'Simulation · no real money': 'Simulação · sem dinheiro real',
    'Close current position first': 'Feche primeiro a posição atual',
    'No market data': 'Não há dados de mercado',
    'Stop must be below entry': 'O stop deve ficar abaixo da entrada',
    'Stop must be above entry': 'O stop deve ficar acima da entrada',
    'Size too small': 'O tamanho é muito pequeno',
    'No open risk. Open from Desk with a mandatory stop.':
        'Não há risco aberto. Abra uma operação na mesa com stop obrigatório.',
    'Risk desk · partials · stop management':
        'Mesa de risco · parciais · gestão de stop',
    '60% discipline · 25% DD control · 15% return · 28-day season':
        '60% disciplina · 25% controle de DD · 15% retorno · temporada de 28 dias',
    'Identity · equity curve · session stats':
        'Identidade · curva de patrimônio · estatísticas da sessão',
    'No closed trades yet.': 'Ainda não há operações fechadas.',
    'Back to \$10,000. History cleared.':
        'De volta a \$10.000. O histórico será apagado.',
    'Set stop before entry · risk ≤2.5% · don’t widen SL':
        'Defina o stop antes da entrada · risco ≤2,5% · não amplie o SL',
    'Waiting for market…': 'Aguardando o mercado…',
    'Badges for discipline and process — not lottery wins':
        'Conquistas por disciplina e processo, não por ganhos de sorte',
    '7-day patterns · not lottery PnL': 'Padrões de 7 dias · não PnL por sorte',
    'Four checks before the ticket. This is the discipline.':
        'Quatro verificações antes do ticket. Isso é disciplina.',
    'Account syncs season and ranking. Desk still works offline.':
        'A conta sincroniza temporada e ranking. A mesa também funciona offline.',
    'Simulation · no real money · 28-day season':
        'Simulação · sem dinheiro real · temporada de 28 dias',
    'Discipline': 'Disciplina',
    'discipline': 'disciplina',
    'Desk': 'Mesa',
    'desk': 'mesa',
    'League': 'Liga',
    'league': 'liga',
    'Paper': 'Simulado',
    'paper': 'simulado',
    'Simulation': 'Simula\u00e7\u00e3o',
    'simulation': 'simula??o',
    'no real money': 'sem dinheiro real',
    'Enter': 'Entrar',
    'ENTER': 'ENTRAR',
    'Close': 'Fechar',
    'CLOSE': 'FECHAR',
    'Clear': 'Limpar',
    'CLEAR': 'LIMPAR',
    'Markets': 'Mercados',
    'Market': 'Mercado',
    'market': 'mercado',
    'Positions': 'Posi\u00e7\u00f5es',
    'Position': 'Posi\u00e7\u00e3o',
    'History': 'Hist\u00farico',
    'Profile': 'Perfil',
    'Language': 'Idioma',
    'language': 'idioma',
    'Cancel': 'Cancelar',
    'Reset': 'Redefinir',
    'Back': 'Voltar',
    'BACK': 'VOLTAR',
    'Next': 'Pr\u00f3ximo',
    'NEXT': 'PR\u00d3XIMO',
    'Done': 'Pronto',
    'Guide': 'Guia',
    'Training': 'Treinamento',
    'Achievements': 'Conquistas',
    'Achievement': 'Conquista',
    'Share': 'Compartilhar',
    'Report': 'Relat\u00fario',
    'report': 'relat\u00fario',
    'Season': 'Temporada',
    'season': 'temporada',
    'Day': 'Dia',
    'day': 'dia',
    'Rank': 'Posi\u00e7\u00e3o',
    'RANK': 'POSI??O',
    'Rules': 'Regras',
    'rules': 'regras',
    'Open': 'Abrir',
    'OPEN': 'ABRIR',
    'Save': 'Salvar',
    'SAVE': 'SALVAR',
    'Start': 'Come\u00e7ar',
    'START': 'COME\u00c7AR',
    'Continue': 'Continuar',
    'Guest': 'Convidado',
    'Account': 'Conta',
    'Password': 'Senha',
    'Nickname': 'Apelido',
    'risk': 'risco',
    'Risk': 'Risco',
    'Trade': 'Opera\u00e7\u00e3o',
    'trade': 'opera\u00e7\u00e3o',
    'Trades': 'Opera\u00e7\u00f5es',
    'trades': 'opera\u00e7\u00f5es',
    'Refresh': 'Atualizar',
    'REFRESH': 'ATUALIZAR',
    'Claim': 'Resgatar',
    'CLAIM': 'RESGATAR',
    'Owned': 'Adquirido',
    'Waiting': 'Aguardando',
    'waiting': 'aguardando',
    'First': 'Primeira',
    'first': 'primeira',
    'Mandatory': 'Obrigat\u00fario',
    'mandatory': 'obrigat\u00fario',
    'You': 'Voc\u00ea',
    'you': 'voc\u00ea',
    'Your': 'Seu',
    'your': 'seu',
    'with': 'com',
    'and': 'e',
    'or': 'ou',
    'for': 'para',
    'from': 'de',
    'to': 'para',
  };

  String get appName => t(
    'Paper League',
    es: _es('Paper League'),
    pt: _pt('Paper League'),
    ru: 'Paper League',
  );
  String get enterDesk => t(
    'ENTER DESK',
    es: _es('ENTER DESK'),
    pt: _pt('ENTER DESK'),
    ru: 'ВОЙТИ В ДЕСК',
  );
  String get splashTitle => t(
    'Discipline\ngets scored.',
    es: _es('Discipline\ngets scored.'),
    pt: _pt('Discipline\ngets scored.'),
    ru: 'Дисциплина\nсчитается.',
  );
  String get splashSub => t(
    'Paper desk. Mandatory stops. League for risk control — not lottery PnL.',
    es: _es(
      'Paper desk. Mandatory stops. League for risk control — not lottery PnL.',
    ),
    pt: _pt(
      'Paper desk. Mandatory stops. League for risk control — not lottery PnL.',
    ),
    ru: 'Бумажный деск с обязательными стопами. Лига за контроль риска — не за удачу.',
  );
  String get eduOnly => t(
    'Simulation · no real money',
    es: _es('Simulation · no real money'),
    pt: _pt('Simulation · no real money'),
    ru: 'Симуляция · без реальных денег',
  );
  String get splashMark => 'PAPER LEAGUE';
  String get splashTag => t(
    'SEASON 28D',
    es: _es('SEASON 28D'),
    pt: _pt('SEASON 28D'),
    ru: 'SEASON 28D',
  );

  String get desk => t('Desk', es: _es('Desk'), pt: _pt('Desk'), ru: 'Деск');
  String get book => t('Book', es: _es('Book'), pt: _pt('Book'), ru: 'Книга');
  String get league =>
      t('League', es: _es('League'), pt: _pt('League'), ru: 'Лига');
  String get you => t('You', es: _es('You'), pt: _pt('You'), ru: 'Вы');

  String get last => t('LAST', es: _es('LAST'), pt: _pt('LAST'), ru: 'ЦЕНА');
  String get equity =>
      t('EQUITY', es: _es('EQUITY'), pt: _pt('EQUITY'), ru: 'ЭКВИТИ');
  String get session =>
      t('SESSION', es: _es('SESSION'), pt: _pt('SESSION'), ru: 'СЕССИЯ');
  String get maxDd =>
      t('MAX DD', es: _es('MAX DD'), pt: _pt('MAX DD'), ru: 'МАКС. ПР');
  String get disc => t('DISC', es: _es('DISC'), pt: _pt('DISC'), ru: 'ДИСЦ');
  String get long => 'LONG';
  String get short => 'SHORT';
  String get close =>
      t('CLOSE', es: _es('CLOSE'), pt: _pt('CLOSE'), ru: 'ЗАКРЫТЬ');
  String get clear =>
      t('CLEAR', es: _es('CLEAR'), pt: _pt('CLEAR'), ru: 'ОЧИСТ');
  String get live => 'LIVE';
  String get nicknameField =>
      t('Nickname', es: _es('Nickname'), pt: _pt('Nickname'), ru: 'Никнейм');
  String get qtyLabel => t('Qty', es: _es('Qty'), pt: _pt('Qty'), ru: 'Объём');
  String get notionalLabel =>
      t('Notional', es: _es('Notional'), pt: _pt('Notional'), ru: 'Ноционал');
  String get slLabel => 'SL';
  String get tpLabel => 'TP';
  String get avgR =>
      t('Avg R', es: _es('Avg R'), pt: _pt('Avg R'), ru: 'Ср. R');
  String get streakLabel =>
      t('streak', es: _es('streak'), pt: _pt('streak'), ru: 'серия');
  String get scrub =>
      t('SCRUB', es: _es('SCRUB'), pt: _pt('SCRUB'), ru: 'ЛЕНТА');
  String get chartReset =>
      t('RESET', es: _es('RESET'), pt: _pt('RESET'), ru: 'СБРОС');
  String get demoTape => t(
    'Demo tape',
    es: _es('Demo tape'),
    pt: _pt('Demo tape'),
    ru: 'Демо-лента',
  );
  String orderError(String code) => switch (code) {
    'close_first' => t(
      'Close current position first',
      es: _es('Close current position first'),
      pt: _pt('Close current position first'),
      ru: 'Сначала закрой текущую позицию',
    ),
    'no_data' => t(
      'No market data',
      es: _es('No market data'),
      pt: _pt('No market data'),
      ru: 'Нет рыночных данных',
    ),
    'stop_long' => t(
      'Stop must be below entry',
      es: _es('Stop must be below entry'),
      pt: _pt('Stop must be below entry'),
      ru: 'Стоп должен быть ниже входа',
    ),
    'stop_short' => t(
      'Stop must be above entry',
      es: _es('Stop must be above entry'),
      pt: _pt('Stop must be above entry'),
      ru: 'Стоп должен быть выше входа',
    ),
    'size_small' => t(
      'Size too small',
      es: _es('Size too small'),
      pt: _pt('Size too small'),
      ru: 'Слишком маленький размер',
    ),
    _ => code,
  };
  String get flatHint => t(
    'Flat · pan chart · drag SL/TP and levels',
    es: _es('Flat · pan chart · drag SL/TP and levels'),
    pt: _pt('Flat · pan chart · drag SL/TP and levels'),
    ru: 'Флэт · тяни график · перетаскивай SL/TP и уровни',
  );
  String get topVol => t(
    'Top volatility',
    es: _es('Top volatility'),
    pt: _pt('Top volatility'),
    ru: 'Топ волатильности',
  );
  String get topVolSub => t(
    'Sorted by 24h range % · hottest markets first',
    es: _es('Sorted by 24h range % · hottest markets first'),
    pt: _pt('Sorted by 24h range % · hottest markets first'),
    ru: 'Сортировка по суточному range % · самые горячие сверху',
  );
  String get markets =>
      t('Markets', es: _es('Markets'), pt: _pt('Markets'), ru: 'Рынки');
  String get toolPointer => t(
    'Pointer / pan',
    es: _es('Pointer / pan'),
    pt: _pt('Pointer / pan'),
    ru: 'Курсор / пан',
  );
  String get toolLevel => t(
    'Horizontal level',
    es: _es('Horizontal level'),
    pt: _pt('Horizontal level'),
    ru: 'Горизонталь',
  );
  String get toolLine =>
      t('Free line', es: _es('Free line'), pt: _pt('Free line'), ru: 'Линия');
  String get toolErase =>
      t('Erase', es: _es('Erase'), pt: _pt('Erase'), ru: 'Ластик');

  String get ticket =>
      t('Ticket', es: _es('Ticket'), pt: _pt('Ticket'), ru: 'Тикет');
  String get mark => t('Mark', es: _es('Mark'), pt: _pt('Mark'), ru: 'Марк');
  String get stopDistance => t(
    'STOP DISTANCE',
    es: _es('STOP DISTANCE'),
    pt: _pt('STOP DISTANCE'),
    ru: 'ДИСТАНЦИЯ СТОПА',
  );
  String get riskEquity => t(
    'RISK / EQUITY',
    es: _es('RISK / EQUITY'),
    pt: _pt('RISK / EQUITY'),
    ru: 'РИСК / ЭКВИТИ',
  );
  String get takeProfit => t(
    'TAKE PROFIT',
    es: _es('TAKE PROFIT'),
    pt: _pt('TAKE PROFIT'),
    ru: 'ТЕЙК-ПРОФИТ',
  );
  String get placeLong => t(
    'PLACE LONG',
    es: _es('PLACE LONG'),
    pt: _pt('PLACE LONG'),
    ru: 'ОТКРЫТЬ LONG',
  );
  String get placeShort => t(
    'PLACE SHORT',
    es: _es('PLACE SHORT'),
    pt: _pt('PLACE SHORT'),
    ru: 'ОТКРЫТЬ SHORT',
  );
  String ifStopped(String money) => t(
    'if stopped −$money',
    es: _es('if stopped −$money'),
    pt: _pt('if stopped −$money'),
    ru: 'если стоп −$money',
  );

  String get positions =>
      t('Positions', es: _es('Positions'), pt: _pt('Positions'), ru: 'Позиции');
  String get positionsSub => t(
    'Risk desk · partials · stop management',
    es: _es('Risk desk · partials · stop management'),
    pt: _pt('Risk desk · partials · stop management'),
    ru: 'Риск-деск · частичные закрытия · стопы',
  );
  String get history =>
      t('History', es: _es('History'), pt: _pt('History'), ru: 'История');
  String get flat => t('Flat', es: _es('Flat'), pt: _pt('Flat'), ru: 'Флэт');
  String get noOpen => t(
    'No open risk. Open from Desk with a mandatory stop.',
    es: _es('No open risk. Open from Desk with a mandatory stop.'),
    pt: _pt('No open risk. Open from Desk with a mandatory stop.'),
    ru: 'Нет открытого риска. Открой сделку со стопом на Деске.',
  );
  String get close50 => t(
    'Close 50%',
    es: _es('Close 50%'),
    pt: _pt('Close 50%'),
    ru: 'Закрыть 50%',
  );
  String get closeAll => t(
    'Close all',
    es: _es('Close all'),
    pt: _pt('Close all'),
    ru: 'Закрыть всё',
  );
  String get tighten =>
      t('TIGHTEN', es: _es('TIGHTEN'), pt: _pt('TIGHTEN'), ru: 'ПОДТЯНУТЬ');

  String get leagueTitle => t(
    'Season League',
    es: _es('Season League'),
    pt: _pt('Season League'),
    ru: 'Сезонная лига',
  );
  String get leagueRules => t(
    '60% discipline · 25% DD control · 15% return · 28-day season',
    es: _es('60% discipline · 25% DD control · 15% return · 28-day season'),
    pt: _pt('60% discipline · 25% DD control · 15% return · 28-day season'),
    ru: '60% дисциплина · 25% контроль просадки · 15% доходность · сезон 28 дней',
  );
  String get rank => t('RANK', es: _es('RANK'), pt: _pt('RANK'), ru: 'МЕСТО');

  String get profile => t(
    'Trader card',
    es: _es('Trader card'),
    pt: _pt('Trader card'),
    ru: 'Карточка трейдера',
  );
  String get profileSub => t(
    'Identity · equity curve · session stats',
    es: _es('Identity · equity curve · session stats'),
    pt: _pt('Identity · equity curve · session stats'),
    ru: 'Профиль · кривая эквити · статистика',
  );
  String get joinCommunity => t(
    'Join Desk Club',
    es: _es('Join Desk Club'),
    pt: _pt('Join Desk Club'),
    ru: 'Сообщество Desk Club',
  );
  String get joinCommunityBody => t(
    'EN hub: weekly desk challenge, structure talks, academy',
    es: _es('EN hub: weekly desk challenge, structure talks, academy'),
    pt: _pt('EN hub: weekly desk challenge, structure talks, academy'),
    ru: 'EN-хаб: weekly desk challenge, структура, академия',
  );
  String get openCommunity => t(
    'Open Desk Club',
    es: _es('Open Desk Club'),
    pt: _pt('Open Desk Club'),
    ru: 'Открыть Desk Club',
  );
  String get communityOpenError => t(
    'Could not open Telegram',
    es: _es('Could not open Telegram'),
    pt: _pt('Could not open Telegram'),
    ru: 'Не удалось открыть Telegram',
  );
  String get tapPhoto => t(
    'Tap avatar for photo',
    es: _es('Tap avatar for photo'),
    pt: _pt('Tap avatar for photo'),
    ru: 'Нажми на аватар для фото',
  );
  String get equityCurve => t(
    'EQUITY CURVE',
    es: _es('EQUITY CURVE'),
    pt: _pt('EQUITY CURVE'),
    ru: 'КРИВАЯ ЭКВИТИ',
  );
  String get trades =>
      t('TRADES', es: _es('TRADES'), pt: _pt('TRADES'), ru: 'СДЕЛКИ');
  String get winRate =>
      t('WIN RATE', es: _es('WIN RATE'), pt: _pt('WIN RATE'), ru: 'ПЛЮС %');
  String get lossRate =>
      t('LOSS RATE', es: _es('LOSS RATE'), pt: _pt('LOSS RATE'), ru: 'МИНУС %');
  String get fromStart => t(
    'FROM START',
    es: _es('FROM START'),
    pt: _pt('FROM START'),
    ru: 'ОТ СТАРТА',
  );
  String get ofClosed => t(
    'of closed',
    es: _es('of closed'),
    pt: _pt('of closed'),
    ru: 'из закрытых',
  );
  String get vsStart => t(
    'vs \$10,000',
    es: _es('vs \$10,000'),
    pt: _pt('vs \$10,000'),
    ru: 'к \$10,000',
  );
  String get journal =>
      t('Journal', es: _es('Journal'), pt: _pt('Journal'), ru: 'Журнал');
  String get noTrades => t(
    'No closed trades yet.',
    es: _es('No closed trades yet.'),
    pt: _pt('No closed trades yet.'),
    ru: 'Пока нет закрытых сделок.',
  );
  String get resetAccount => t(
    'Reset paper account',
    es: _es('Reset paper account'),
    pt: _pt('Reset paper account'),
    ru: 'Сбросить бумажный счёт',
  );
  String get resetTitle => t(
    'Reset paper account\u00fa',
    es: _es('Reset paper account\u00fa'),
    pt: _pt('Reset paper account\u00fa'),
    ru: 'Сбросить счёт?',
  );
  String get resetBody => t(
    'Back to \$10,000. History cleared.',
    es: _es('Back to \$10,000. History cleared.'),
    pt: _pt('Back to \$10,000. History cleared.'),
    ru: 'Снова \$10,000. История очистится.',
  );
  String get cancel =>
      t('Cancel', es: _es('Cancel'), pt: _pt('Cancel'), ru: 'Отмена');
  String get reset =>
      t('Reset', es: _es('Reset'), pt: _pt('Reset'), ru: 'Сбросить');
  String get language =>
      t('Language', es: _es('Language'), pt: _pt('Language'), ru: 'Язык');
  String get english => 'English';
  String get russian => 'Русский';

  String get recap => t(
    'TRADE RECAP',
    es: _es('TRADE RECAP'),
    pt: _pt('TRADE RECAP'),
    ru: 'ИТОГ СДЕЛКИ',
  );
  String get backToDesk => t(
    'BACK TO DESK',
    es: _es('BACK TO DESK'),
    pt: _pt('BACK TO DESK'),
    ru: 'НА ДЕСК',
  );
  String get discipline => t(
    'Discipline',
    es: _es('Discipline'),
    pt: _pt('Discipline'),
    ru: 'Дисциплина',
  );
  String get flagStop => t(
    'Stop set before entry',
    es: _es('Stop set before entry'),
    pt: _pt('Stop set before entry'),
    ru: 'Стоп до входа',
  );
  String get flagSize => t(
    'Size within risk budget',
    es: _es('Size within risk budget'),
    pt: _pt('Size within risk budget'),
    ru: 'Размер в лимите риска',
  );
  String get flagWiden => t(
    'Stop not widened',
    es: _es('Stop not widened'),
    pt: _pt('Stop not widened'),
    ru: 'Стоп не отодвигали',
  );
  String get flagRevenge => t(
    'No revenge burst',
    es: _es('No revenge burst'),
    pt: _pt('No revenge burst'),
    ru: 'Без реванш-сделок',
  );

  String get coachTitle => t(
    'First trade',
    es: _es('First trade'),
    pt: _pt('First trade'),
    ru: 'Первая сделка',
  );
  String get coachBody => t(
    'Set stop before entry · risk ≤2.5% · don’t widen SL',
    es: _es('Set stop before entry · risk ≤2.5% · don’t widen SL'),
    pt: _pt('Set stop before entry · risk ≤2.5% · don’t widen SL'),
    ru: 'Поставь стоп до входа · риск ≤2.5% · не отодвигай SL',
  );
  String get dismiss =>
      t('Got it', es: _es('Got it'), pt: _pt('Got it'), ru: 'Понятно');
  String get manage =>
      t('MANAGE', es: _es('MANAGE'), pt: _pt('MANAGE'), ru: 'УПРАВЛЕНИЕ');
  String get waitingMarket => t(
    'Waiting for market…',
    es: _es('Waiting for market…'),
    pt: _pt('Waiting for market…'),
    ru: 'Ждём рынок…',
  );
  String get tapeReplay => t(
    'TRADE TAPE',
    es: _es('TRADE TAPE'),
    pt: _pt('TRADE TAPE'),
    ru: 'ЛЕНТА СДЕЛКИ',
  );
  String get mfe => 'MFE';
  String get mae => 'MAE';
  String exitLabel(String kind) {
    if (isRu) {
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

  String get guideTitle => t(
    'DESK GUIDE',
    es: _es('DESK GUIDE'),
    pt: _pt('DESK GUIDE'),
    ru: 'ГИД ДЕСКА',
  );
  String get guideCta => t(
    'Guide · glossary · buttons',
    es: _es('Guide · glossary · buttons'),
    pt: _pt('Guide · glossary · buttons'),
    ru: 'Гид · глоссарий · кнопки',
  );
  String get guideNext =>
      t('NEXT', es: _es('NEXT'), pt: _pt('NEXT'), ru: 'ДАЛЬШЕ');
  String get guideBack =>
      t('BACK', es: _es('BACK'), pt: _pt('BACK'), ru: 'НАЗАД');
  String get guideDone =>
      t('GOT IT', es: _es('GOT IT'), pt: _pt('GOT IT'), ru: 'НА ДЕСК');

  String get achievements => t(
    'Achievements',
    es: _es('Achievements'),
    pt: _pt('Achievements'),
    ru: 'Ачивки',
  );
  String get achievementsSub => t(
    'Badges for discipline and process — not lottery wins',
    es: _es('Badges for discipline and process — not lottery wins'),
    pt: _pt('Badges for discipline and process — not lottery wins'),
    ru: 'Награды за дисциплину и процесс, не за лудоманство',
  );
  String get achievementUnlocked => t(
    'ACHIEVEMENT',
    es: _es('ACHIEVEMENT'),
    pt: _pt('ACHIEVEMENT'),
    ru: 'АЧИВКА',
  );

  String get shareRecap => t(
    'SHARE CARD',
    es: _es('SHARE CARD'),
    pt: _pt('SHARE CARD'),
    ru: 'ПОДЕЛИТЬСЯ',
  );
  String get shareTagline => t(
    'discipline gets scored',
    es: _es('discipline gets scored'),
    pt: _pt('discipline gets scored'),
    ru: 'дисциплина считается',
  );
  String get shareCopied => t(
    'Trade text copied',
    es: _es('Trade text copied'),
    pt: _pt('Trade text copied'),
    ru: 'Текст сделки скопирован',
  );
  String get shareWebHint => t(
    'Web shares text — on phone you get the image card',
    es: _es('Web shares text — on phone you get the image card'),
    pt: _pt('Web shares text — on phone you get the image card'),
    ru: 'В вебе шарится текст — на телефоне уйдёт картинка',
  );

  String get weeklyReport => t(
    'WEEKLY REPORT',
    es: _es('WEEKLY REPORT'),
    pt: _pt('WEEKLY REPORT'),
    ru: 'НЕДЕЛЬНЫЙ ОТЧЁТ',
  );
  String get weeklyReportSub => t(
    '7-day patterns · not lottery PnL',
    es: _es('7-day patterns · not lottery PnL'),
    pt: _pt('7-day patterns · not lottery PnL'),
    ru: 'Паттерны за 7 дней · не лотерея PnL',
  );
  String get weeklyReportCta => t(
    'Weekly pattern report',
    es: _es('Weekly pattern report'),
    pt: _pt('Weekly pattern report'),
    ru: 'Недельный отчёт паттернов',
  );
  String get weeklyPatterns => t(
    'What stands out',
    es: _es('What stands out'),
    pt: _pt('What stands out'),
    ru: 'Что бросается в глаза',
  );
  String get widenRate =>
      t('WIDEN %', es: _es('WIDEN %'), pt: _pt('WIDEN %'), ru: 'WIDEN %');
  String get leftOnTable =>
      t('LEFT R', es: _es('LEFT R'), pt: _pt('LEFT R'), ru: 'LEFT R');
  String get revengeShort =>
      t('REVENGE', es: _es('REVENGE'), pt: _pt('REVENGE'), ru: 'REVENGE');

  String get season =>
      t('SEASON', es: _es('SEASON'), pt: _pt('SEASON'), ru: 'СЕЗОН');
  String get day => t('DAY', es: _es('DAY'), pt: _pt('DAY'), ru: 'ДЕНЬ');
  String get seasonHint => t(
    '28 days · season rank resets · account & equity stay',
    es: _es('28 days · season rank resets · account & equity stay'),
    pt: _pt('28 days · season rank resets · account & equity stay'),
    ru: '28 дней · рейтинг сезона сбрасывается · счёт и эквити остаются',
  );
  String get podium =>
      t('Podium', es: _es('Podium'), pt: _pt('Podium'), ru: 'Пьедестал');
  String get standings =>
      t('Standings', es: _es('Standings'), pt: _pt('Standings'), ru: 'Таблица');
  String get leagueRulesShort =>
      t('60/25/15', es: _es('60/25/15'), pt: _pt('60/25/15'), ru: '60/25/15');
  String get training =>
      t('Training', es: _es('Training'), pt: _pt('Training'), ru: 'Тренировка');
  String get tapeDrill => t(
    'Tape Drill',
    es: _es('Tape Drill'),
    pt: _pt('Tape Drill'),
    ru: 'Tape Drill',
  );
  String get tapeDrillSub => t(
    'History · plan · process pts',
    es: _es('History · plan · process pts'),
    pt: _pt('History · plan · process pts'),
    ru: 'История · план · очки процесса',
  );
  String get tapeDrillHelp => t(
    'Scrub to the marker. Long / Short / Skip with a stop. Points for plan, not guessing.',
    es: _es(
      'Scrub to the marker. Long / Short / Skip with a stop. Points for plan, not guessing.',
    ),
    pt: _pt(
      'Scrub to the marker. Long / Short / Skip with a stop. Points for plan, not guessing.',
    ),
    ru: 'Крути ленту до маркера. Long / Short / Skip со стопом. Очки за план, не за угадайку.',
  );
  String get tapeDrillEmpty => t(
    'Not enough candles for drill',
    es: _es('Not enough candles for drill'),
    pt: _pt('Not enough candles for drill'),
    ru: 'Мало свечей для дрилла',
  );
  String get processPts => t('PTS', es: _es('PTS'), pt: _pt('PTS'), ru: 'PTS');
  String get stopAtr => 'STOP ATR';
  String get tpR => 'TP R';
  String get skip => t('SKIP', es: _es('SKIP'), pt: _pt('SKIP'), ru: 'СКИП');
  String get revealTape => t(
    'REVEAL TAPE',
    es: _es('REVEAL TAPE'),
    pt: _pt('REVEAL TAPE'),
    ru: 'ПОКАЗАТЬ ЛЕНТУ',
  );
  String get nextDrill => t(
    'NEXT ROUND',
    es: _es('NEXT ROUND'),
    pt: _pt('NEXT ROUND'),
    ru: 'ЕЩЁ РАУНД',
  );
  String get back => t('BACK', es: _es('BACK'), pt: _pt('BACK'), ru: 'НАЗАД');
  String get playbooks => t(
    'Playbooks',
    es: _es('Playbooks'),
    pt: _pt('Playbooks'),
    ru: 'Playbooks',
  );
  String get playbooksSub => t(
    'Setups to chart',
    es: _es('Setups to chart'),
    pt: _pt('Setups to chart'),
    ru: 'Сетапы на график',
  );
  String get playbooksHelp => t(
    'Saved SL/TP structures. Apply draws levels on the active symbol.',
    es: _es('Saved SL/TP structures. Apply draws levels on the active symbol.'),
    pt: _pt('Saved SL/TP structures. Apply draws levels on the active symbol.'),
    ru: 'Сохранённые SL/TP структуры. Apply рисует уровни на активном инструменте.',
  );
  String get addPlaybook => t(
    'Add setup',
    es: _es('Add setup'),
    pt: _pt('Add setup'),
    ru: 'Добавить сетап',
  );
  String get applyChart =>
      t('TO CHART', es: _es('TO CHART'), pt: _pt('TO CHART'), ru: 'НА ГРАФИК');
  String get playbookApplied => t(
    'Playbook on chart',
    es: _es('Playbook on chart'),
    pt: _pt('Playbook on chart'),
    ru: 'Playbook на графике',
  );

  String get dailyDesk => t(
    'DAILY DESK',
    es: _es('DAILY DESK'),
    pt: _pt('DAILY DESK'),
    ru: 'DAILY DESK',
  );
  String get dailyPlan =>
      t('Plan', es: _es('Plan'), pt: _pt('Plan'), ru: 'План');
  String get dailyStop =>
      t('Stop', es: _es('Stop'), pt: _pt('Stop'), ru: 'Стоп');
  String get dailyDrill => 'Drill';
  String get dailyShare =>
      t('Share', es: _es('Share'), pt: _pt('Share'), ru: 'Шер');

  String get preTrade => t(
    'Pre-trade check',
    es: _es('Pre-trade check'),
    pt: _pt('Pre-trade check'),
    ru: 'Pre-trade check',
  );
  String get preTradeSub => t(
    'Four checks before the ticket. This is the discipline.',
    es: _es('Four checks before the ticket. This is the discipline.'),
    pt: _pt('Four checks before the ticket. This is the discipline.'),
    ru: 'Четыре галочки до тикета. Это и есть дисциплина.',
  );
  String get preThesis => t(
    'I have a thesis / level',
    es: _es('I have a thesis / level'),
    pt: _pt('I have a thesis / level'),
    ru: 'Есть тезис / уровень',
  );
  String get preStop => t(
    'Stop is already planned',
    es: _es('Stop is already planned'),
    pt: _pt('Stop is already planned'),
    ru: 'Стоп уже на графике',
  );
  String get preSize => t(
    'Risk ≤ 2% equity',
    es: _es('Risk ≤ 2% equity'),
    pt: _pt('Risk ≤ 2% equity'),
    ru: 'Риск ≤ 2% эквити',
  );
  String get preCalm => t(
    'Not revenge after a loss',
    es: _es('Not revenge after a loss'),
    pt: _pt('Not revenge after a loss'),
    ru: 'Не реванш после минуса',
  );
  String get preTradeGo => t(
    'TO TICKET',
    es: _es('TO TICKET'),
    pt: _pt('TO TICKET'),
    ru: 'К ТИКЕТУ',
  );

  String get liveFeed => t(
    'League pulse',
    es: _es('League pulse'),
    pt: _pt('League pulse'),
    ru: 'Пульс лиги',
  );
  String get seasonHistory => t(
    'Season history',
    es: _es('Season history'),
    pt: _pt('Season history'),
    ru: 'История сезонов',
  );
  String get seasonRewards => t(
    'Season rewards',
    es: _es('Season rewards'),
    pt: _pt('Season rewards'),
    ru: 'Награды сезона',
  );

  String get shareRitualTitle => t(
    'Share ritual',
    es: _es('Share ritual'),
    pt: _pt('Share ritual'),
    ru: 'Ритуал шаринга',
  );
  String get shareRitualBody => t(
    'Clean process. Drop the card to stories — Daily Desk counts Share.',
    es: _es(
      'Clean process. Drop the card to stories — Daily Desk counts Share.',
    ),
    pt: _pt(
      'Clean process. Drop the card to stories — Daily Desk counts Share.',
    ),
    ru: 'Чистый процесс. Кинь карточку в сторис — Daily Desk засчитает Share.',
  );

  String get drillIntroTitle => t(
    'Tape Drill',
    es: _es('Tape Drill'),
    pt: _pt('Tape Drill'),
    ru: 'Tape Drill',
  );
  String get drillIntroBody => t(
    'Scrub the tape. At the marker — plan with a stop. Points for process, not guessing.',
    es: _es(
      'Scrub the tape. At the marker — plan with a stop. Points for process, not guessing.',
    ),
    pt: _pt(
      'Scrub the tape. At the marker — plan with a stop. Points for process, not guessing.',
    ),
    ru: 'Крути ленту. На маркере — план со стопом. Очки за процесс, не за угадайку.',
  );
  String get drillIntroGo =>
      t('START', es: _es('START'), pt: _pt('START'), ru: 'НАЧАТЬ');

  String get pbIntroTitle => t(
    'Playbooks',
    es: _es('Playbooks'),
    pt: _pt('Playbooks'),
    ru: 'Playbooks',
  );
  String get pbIntroBody => t(
    'Saved SL/TP. One tap paints levels on the active symbol.',
    es: _es('Saved SL/TP. One tap paints levels on the active symbol.'),
    pt: _pt('Saved SL/TP. One tap paints levels on the active symbol.'),
    ru: 'Сохранённые SL/TP. Одним тапом уровни на активный символ.',
  );

  String get authTitle => t(
    'Enter the league',
    es: _es('Enter the league'),
    pt: _pt('Enter the league'),
    ru: 'Войти в лигу',
  );
  String get authSubOnline => t(
    'Account syncs season and ranking. Desk still works offline.',
    es: _es('Account syncs season and ranking. Desk still works offline.'),
    pt: _pt('Account syncs season and ranking. Desk still works offline.'),
    ru: 'Аккаунт синхронизирует сезон и рейтинг. Деск работает и офлайн.',
  );
  String get authSubDemo => t(
    'Supabase not configured — DEMO league on device. Pass SUPABASE_URL / ANON_KEY.',
    es: _es(
      'Supabase not configured — DEMO league on device. Pass SUPABASE_URL / ANON_KEY.',
    ),
    pt: _pt(
      'Supabase not configured — DEMO league on device. Pass SUPABASE_URL / ANON_KEY.',
    ),
    ru: 'Supabase не настроен — DEMO лига на устройстве. Добавь SUPABASE_URL / ANON_KEY.',
  );
  String get email => 'Email';
  String get password =>
      t('Password', es: _es('Password'), pt: _pt('Password'), ru: 'Пароль');
  String get signIn =>
      t('SIGN IN', es: _es('SIGN IN'), pt: _pt('SIGN IN'), ru: 'ВОЙТИ');
  String get signUp =>
      t('SIGN UP', es: _es('SIGN UP'), pt: _pt('SIGN UP'), ru: 'РЕГИСТРАЦИЯ');
  String get haveAccount => t(
    'Already have an account',
    es: _es('Already have an account'),
    pt: _pt('Already have an account'),
    ru: 'Уже есть аккаунт',
  );
  String get needAccount => t(
    'Create account',
    es: _es('Create account'),
    pt: _pt('Create account'),
    ru: 'Создать аккаунт',
  );
  String get continueGuest => t(
    'CONTINUE AS GUEST',
    es: _es('CONTINUE AS GUEST'),
    pt: _pt('CONTINUE AS GUEST'),
    ru: 'ПРОДОЛЖИТЬ КАК ГОСТЬ',
  );
  String get authFootnote => t(
    'Simulation · no real money · 28-day season',
    es: _es('Simulation · no real money · 28-day season'),
    pt: _pt('Simulation · no real money · 28-day season'),
    ru: 'Симуляция · без реальных денег · сезон 28 дней',
  );

  String get leagueLive => 'LIVE';
  String get leagueDemo => 'DEMO';
  String get division =>
      t('Division', es: _es('Division'), pt: _pt('Division'), ru: 'Дивизион');

  String get ceremonyTitle => t(
    'Season open',
    es: _es('Season open'),
    pt: _pt('Season open'),
    ru: 'Сезон открыт',
  );
  String get ceremonyBody => t(
    'Season rank resets. Equity and trade history stay.',
    es: _es('Season rank resets. Equity and trade history stay.'),
    pt: _pt('Season rank resets. Equity and trade history stay.'),
    ru: 'Рейтинг сезона обнулён. Эквити и история сделок остаются.',
  );
  String get ceremonyGo =>
      t('TO LEAGUE', es: _es('TO LEAGUE'), pt: _pt('TO LEAGUE'), ru: 'В ЛИГУ');
  String get finalsPulse => t(
    'Season finals',
    es: _es('Season finals'),
    pt: _pt('Season finals'),
    ru: 'Финал сезона',
  );

  String get firstRunTitle => t(
    'First run',
    es: _es('First run'),
    pt: _pt('First run'),
    ru: 'Первый заход',
  );
  String get firstRunBody => t(
    'Take one trade with a stop. Pre-trade check is required.',
    es: _es('Take one trade with a stop. Pre-trade check is required.'),
    pt: _pt('Take one trade with a stop. Pre-trade check is required.'),
    ru: 'Сделай одну сделку со стопом. Pre-trade check обязателен.',
  );
  String get firstRunCta =>
      t('GOT IT', es: _es('GOT IT'), pt: _pt('GOT IT'), ru: 'ПОНЯЛ');
  String get firstRunStep1Title => t(
    'Stop is mandatory',
    es: _es('Stop is mandatory'),
    pt: _pt('Stop is mandatory'),
    ru: 'Стоп обязателен',
  );
  String get firstRunStep1Body => t(
    'No stop, no trade. League scores discipline, not luck.',
    es: _es('No stop, no trade. League scores discipline, not luck.'),
    pt: _pt('No stop, no trade. League scores discipline, not luck.'),
    ru: 'Без стопа нет сделки. Лига считает дисциплину, не удачу.',
  );
  String get firstRunStep2Title => t(
    'Pre-trade check',
    es: _es('Pre-trade check'),
    pt: _pt('Pre-trade check'),
    ru: 'Pre-trade check',
  );
  String get firstRunStep2Body => t(
    'Four checks before the ticket — thesis, stop, size, calm.',
    es: _es('Four checks before the ticket — thesis, stop, size, calm.'),
    pt: _pt('Four checks before the ticket — thesis, stop, size, calm.'),
    ru: 'Четыре галочки перед тикетом — тезис, стоп, размер, спокойствие.',
  );
  String get firstRunStep3Title => t(
    'Open the first',
    es: _es('Open the first'),
    pt: _pt('Open the first'),
    ru: 'Открой первую',
  );
  String get firstRunStep3Body => t(
    'Long or Short on the desk. After close you’ll see recap and Daily Desk.',
    es: _es(
      'Long or Short on the desk. After close you’ll see recap and Daily Desk.',
    ),
    pt: _pt(
      'Long or Short on the desk. After close you’ll see recap and Daily Desk.',
    ),
    ru: 'Long или Short на деске. После закрытия увидишь рекап и Daily Desk.',
  );
  String get deskOffline => 'OFFLINE';
  String get deskLiveTape => 'LIVE TAPE';
  String get leagueRetry =>
      t('REFRESH', es: _es('REFRESH'), pt: _pt('REFRESH'), ru: 'ОБНОВИТЬ');
  String get leagueStale => t(
    'Board stale · tap refresh',
    es: _es('Board stale · tap refresh'),
    pt: _pt('Board stale · tap refresh'),
    ru: 'Рейтинг устарел · нажми обновить',
  );
  String get nickRequired => t(
    'Set a nickname to publish to the league',
    es: _es('Set a nickname to publish to the league'),
    pt: _pt('Set a nickname to publish to the league'),
    ru: 'Задай ник для публикации в лигу',
  );
  String get upgradeAccount => t(
    'Link email',
    es: _es('Link email'),
    pt: _pt('Link email'),
    ru: 'Привязать email',
  );
  String get preTradeSkip =>
      t('SKIP', es: _es('SKIP'), pt: _pt('SKIP'), ru: 'ПРОПУСТИТЬ');
  String get preTradeSoft => t(
    'Skip check this time?',
    es: _es('Skip check this time?'),
    pt: _pt('Skip check this time?'),
    ru: 'Быстрый вход без чека?',
  );
  String get credits => 'Credits';
  String get upgradeShop => t(
    'Desk upgrades',
    es: _es('Desk upgrades'),
    pt: _pt('Desk upgrades'),
    ru: 'Апгрейды деска',
  );
  String get notEnoughCredits => t(
    'Not enough credits',
    es: _es('Not enough credits'),
    pt: _pt('Not enough credits'),
    ru: 'Не хватает credits',
  );
  String get owned =>
      t('Owned', es: _es('Owned'), pt: _pt('Owned'), ru: 'Есть');
  String get exportTelemetry => t(
    'Export telemetry',
    es: _es('Export telemetry'),
    pt: _pt('Export telemetry'),
    ru: 'Экспорт телеметрии',
  );
  String get leagueStartApi => t(
    'LIVE empty · start tool/league_api or open a second client',
    es: _es('LIVE empty · start tool/league_api or open a second client'),
    pt: _pt('LIVE empty · start tool/league_api or open a second client'),
    ru: 'LIVE пустой · запусти tool/league_api или открой второй клиент',
  );
  String get leagueDemoHint => t(
    'DEMO · on-device bots. For LIVE: dart run bin/server.dart',
    es: _es('DEMO · on-device bots. For LIVE: dart run bin/server.dart'),
    pt: _pt('DEMO · on-device bots. For LIVE: dart run bin/server.dart'),
    ru: 'DEMO · боты на устройстве. Для LIVE: dart run bin/server.dart',
  );
  String get wsTape => 'WS';
  String get playbookSlotsFull => t(
    'Playbook limit — buy a slot in upgrades',
    es: _es('Playbook limit — buy a slot in upgrades'),
    pt: _pt('Playbook limit — buy a slot in upgrades'),
    ru: 'Лимит playbooks — купи слот в апгрейдах',
  );
  String get seasonTrack => t(
    'SEASON TRACK',
    es: _es('SEASON TRACK'),
    pt: _pt('SEASON TRACK'),
    ru: 'ТРЕК СЕЗОНА',
  );
  String get weeklyChallenges => t(
    'Weekly challenges',
    es: _es('Weekly challenges'),
    pt: _pt('Weekly challenges'),
    ru: 'Недельные челленджи',
  );
  String get claim =>
      t('CLAIM', es: _es('CLAIM'), pt: _pt('CLAIM'), ru: 'ЗАБРАТЬ');
  String get trackClaimToday => isRu ? 'Награда дня' : "Today's reward";
  String get trackClaimed => t(
    'Day node claimed',
    es: _es('Day node claimed'),
    pt: _pt('Day node claimed'),
    ru: 'Узел дня забран',
  );
  String get trackNeedActive => t(
    'Be active on desk today, then claim',
    es: _es('Be active on desk today, then claim'),
    pt: _pt('Be active on desk today, then claim'),
    ru: 'Зайди на деск сегодня, потом забери',
  );
  String get trackCatchUpFail => t(
    'Catch-up locked — need credits or token',
    es: _es('Catch-up locked — need credits or token'),
    pt: _pt('Catch-up locked — need credits or token'),
    ru: 'Догон недоступен — нужны credits или токен',
  );
  String get shields =>
      t('Shields', es: _es('Shields'), pt: _pt('Shields'), ru: 'Щиты');
}
