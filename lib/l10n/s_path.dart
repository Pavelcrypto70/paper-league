import 'package:paper_league/l10n/s.dart';

/// Copy for the first-contact funnel: promise, legal, beginner path, ceremonies.
extension PathStrings on S {
  // Promise
  String get promiseChip => t(
        'SIMULATION · \$10,000 practice',
        es: 'SIMULACIÓN · \$10.000 de práctica',
        pt: 'SIMULAÇÃO · \$10.000 de prática',
        ru: 'SIMULATION · \$10 000 учебных',
      );
  String get promiseSub => t(
        'First trade, stop and recap — with no risk of losing money.',
        es: 'Primera operación, stop y análisis — sin riesgo de perder dinero.',
        pt: 'Primeira operação, stop e análise — sem risco de perder dinheiro.',
        ru: 'Первая сделка, стоп и разбор — без риска потерять деньги.',
      );
  String get promiseB1 => t(
        '4 short missions · ~15 min',
        es: '4 misiones cortas · ~15 min',
        pt: '4 missões curtas · ~15 min',
        ru: '4 короткие миссии · ~15 минут',
      );
  String get promiseB2 => t(
        'Scored on discipline, not luck',
        es: 'Puntuación por disciplina, no por suerte',
        pt: 'Pontuação por disciplina, não por sorte',
        ru: 'Оценка за дисциплину, не за удачу',
      );
  String get promiseB3 => t(
        'Daily Desk: 3–7 minutes a day',
        es: 'Daily Desk: 3–7 minutos al día',
        pt: 'Daily Desk: 3–7 minutos por dia',
        ru: 'Daily Desk на 3–7 минут в день',
      );
  String get promiseCta => t(
        'Start practice',
        es: 'Empezar a practicar',
        pt: 'Começar a praticar',
        ru: 'Начать практику',
      );
  String get promiseFine => t(
        'Simulation · not financial advice',
        es: 'Simulación · no es asesoramiento financiero',
        pt: 'Simulação · não é aconselhamento financeiro',
        ru: 'Симуляция · не финансовый совет',
      );

  // Legal
  String get legalStartTitle => t(
        'Before you start',
        es: 'Antes de empezar',
        pt: 'Antes de começar',
        ru: 'Перед стартом',
      );
  String get legalStartSub => t(
        'Three rules Paper League stands on',
        es: 'Tres reglas en las que se basa Paper League',
        pt: 'Três regras em que o Paper League se apoia',
        ru: 'Три правила, на которых держится Paper League',
      );
  String get legalRule1 => t(
        'This is a simulation: no real money is used or withdrawn',
        es: 'Es una simulación: no se usa ni se retira dinero real',
        pt: 'É uma simulação: nenhum dinheiro real é usado ou sacado',
        ru: 'Это симуляция: реальные деньги не используются и не выводятся',
      );
  String get legalRule2 => t(
        'The app teaches and gives no investment advice',
        es: 'La app enseña y no da consejos de inversión',
        pt: 'O app ensina e não dá conselhos de investimento',
        ru: 'Приложение обучает и не даёт инвестиционных советов',
      );
  String get legalRule3 => t(
        'I am 18+ and accept the Terms and Privacy Policy',
        es: 'Tengo 18+ y acepto los Términos y la Política de privacidad',
        pt: 'Tenho 18+ e aceito os Termos e a Política de privacidade',
        ru: 'Мне 18+, я принимаю Условия и Политику конфиденциальности',
      );
  String get legalTapHint => t(
        'Tap each rule to confirm',
        es: 'Toca cada regla para confirmar',
        pt: 'Toque em cada regra para confirmar',
        ru: 'Отметь каждое правило',
      );
  String get legalAcceptCta => t(
        'Accept and start',
        es: 'Acepto y empiezo',
        pt: 'Aceito e começo',
        ru: 'Принимаю и начинаю',
      );
  String get legalTerms => t('Terms', es: 'Términos', pt: 'Termos', ru: 'Условия');
  String get legalPrivacy => t(
        'Privacy Policy',
        es: 'Política de privacidad',
        pt: 'Política de privacidade',
        ru: 'Политика конфиденциальности',
      );

  // Beginner home
  String get homeGuestCap => t(
        'Guest · progress on this phone',
        es: 'Invitado · progreso en este teléfono',
        pt: 'Convidado · progresso neste telefone',
        ru: 'Гость · прогресс на телефоне',
      );
  String get homeTitle => t(
        'Your beginner path',
        es: 'Tu ruta de principiante',
        pt: 'Sua trilha de iniciante',
        ru: 'Твой путь новичка',
      );
  String missionChip(int n, int min) => t(
        'MISSION $n · $min MIN',
        es: 'MISIÓN $n · $min MIN',
        pt: 'MISSÃO $n · $min MIN',
        ru: 'МИССИЯ $n · $min МИН',
      );
  String get homeStart => t(
        'Start mission',
        es: 'Empezar misión',
        pt: 'Começar missão',
        ru: 'Начать миссию',
      );
  String get homeContinue => t(
        'Continue mission',
        es: 'Continuar misión',
        pt: 'Continuar missão',
        ru: 'Продолжить миссию',
      );
  String get homeDailyLocked => t(
        'Opens after 4 missions',
        es: 'Se abre tras 4 misiones',
        pt: 'Abre após 4 missões',
        ru: 'Откроется после 4 миссий',
      );
  String get homeLoading => t(
        'Loading the market…',
        es: 'Cargando el mercado…',
        pt: 'Carregando o mercado…',
        ru: 'Загружаем рынок…',
      );

  String pathTitle(int i) => switch (i) {
        1 => t('What a candle is', es: 'Qué es una vela', pt: 'O que é um candle', ru: 'Что такое свеча'),
        2 => t(
            'First paper trade',
            es: 'Primera operación en papel',
            pt: 'Primeira operação em papel',
            ru: 'Первая сделка на бумаге',
          ),
        3 => t('Stop and risk %', es: 'Stop y riesgo %', pt: 'Stop e risco %', ru: 'Стоп и риск-%'),
        _ => t('Trade recap', es: 'Análisis de la operación', pt: 'Análise da operação', ru: 'Разбор сделки'),
      };

  String pathSub(int i) => switch (i) {
        1 => t(
            'Open, high, low, close — on one live BTC example',
            es: 'Open, high, low, close — en un ejemplo real de BTC',
            pt: 'Open, high, low, close — em um exemplo real de BTC',
            ru: 'Open, high, low, close — на одном живом примере с графика BTC',
          ),
        2 => t(
            'Open a Long with a fixed practice size. No real money.',
            es: 'Abre un Long con tamaño fijo de práctica. Sin dinero real.',
            pt: 'Abra um Long com tamanho fixo de prática. Sem dinheiro real.',
            ru: 'Открой Long фиксированным учебным размером. Без реальных денег.',
          ),
        3 => t(
            'Protect the position and see the loss in \$ before it happens.',
            es: 'Protege la posición y ve la pérdida en \$ antes de que ocurra.',
            pt: 'Proteja a posição e veja a perda em \$ antes de acontecer.',
            ru: 'Защити позицию и заранее увидь возможный убыток в \$.',
          ),
        _ => t(
            'Close the trade and take one lesson into tomorrow.',
            es: 'Cierra la operación y llévate una lección para mañana.',
            pt: 'Feche a operação e leve uma lição para amanhã.',
            ru: 'Закрой сделку и забери один вывод в завтра.',
          ),
      };

  int pathMinutes(int i) => switch (i) {
        1 => 3,
        2 => 2,
        3 => 3,
        _ => 2,
      };

  // Mission chrome
  String missionOf(int n) => t(
        'Mission $n of 4',
        es: 'Misión $n de 4',
        pt: 'Missão $n de 4',
        ru: 'Миссия $n из 4',
      );

  // Mission 1
  String get m1Coach => t(
        'Green candle: the close is above the open. Wicks show the high and the low of the period.',
        es: 'Vela verde: el cierre está por encima de la apertura. Las mechas muestran el máximo y el mínimo del periodo.',
        pt: 'Candle verde: o fechamento está acima da abertura. Os pavios mostram a máxima e a mínima do período.',
        ru: 'Зелёная свеча: цена закрытия выше цены открытия. Тени показывают максимум и минимум за период.',
      );
  String get m1Q1 => t(
        'Where is the close of this candle?',
        es: '¿Dónde está el cierre de esta vela?',
        pt: 'Onde está o fechamento deste candle?',
        ru: 'Где цена закрытия у этой свечи?',
      );
  String get m1Q1A => t('Top of the body', es: 'Arriba del cuerpo', pt: 'Topo do corpo', ru: 'Верх тела');
  String get m1Q1B => t('Bottom of the body', es: 'Abajo del cuerpo', pt: 'Base do corpo', ru: 'Низ тела');
  String get m1Q2 => t(
        'What does the tip of the upper wick show?',
        es: '¿Qué muestra la punta de la mecha superior?',
        pt: 'O que mostra a ponta do pavio superior?',
        ru: 'Что показывает верх верхней тени?',
      );
  String get m1Q2A => t('Where price opened', es: 'Dónde abrió el precio', pt: 'Onde o preço abriu', ru: 'Цену открытия');
  String get m1Q2B => t(
        'The highest price of the period',
        es: 'El precio máximo del periodo',
        pt: 'O preço máximo do período',
        ru: 'Максимум цены за период',
      );
  String get m1Wrong => t(
        'Not quite — look at the labels next to the candle.',
        es: 'Casi — mira las etiquetas junto a la vela.',
        pt: 'Quase — olhe os rótulos ao lado do candle.',
        ru: 'Почти — посмотри на подписи рядом со свечой.',
      );
  String get m1Pick => t('Pick an answer', es: 'Elige una respuesta', pt: 'Escolha uma resposta', ru: 'Выбери ответ');
  String get m1Check => t('Check', es: 'Comprobar', pt: 'Verificar', ru: 'Проверить');
  String get m1Next => t(
        'Correct · next 2/2',
        es: 'Correcto · siguiente 2/2',
        pt: 'Certo · próxima 2/2',
        ru: 'Верно · дальше 2/2',
      );
  String get m1Finish => t(
        'Correct · to mission 2',
        es: 'Correcto · a la misión 2',
        pt: 'Certo · para a missão 2',
        ru: 'Верно · к миссии 2',
      );
  String get lblHigh => t('high', es: 'máximo', pt: 'máxima', ru: 'максимум');
  String get lblClose => t('close', es: 'cierre', pt: 'fechamento', ru: 'закрытие');
  String get lblOpen => t('open', es: 'apertura', pt: 'abertura', ru: 'открытие');
  String get lblLow => t('low', es: 'mínimo', pt: 'mínima', ru: 'минимум');

  // Mission 2
  String get m2Coach => t(
        'Long means you earn if price goes up. Try opening a Long on the practice account — it is safe.',
        es: 'Long significa que ganas si el precio sube. Prueba abrir un Long en la cuenta de práctica — es seguro.',
        pt: 'Long significa que você ganha se o preço subir. Tente abrir um Long na conta de prática — é seguro.',
        ru: 'Long — заработок, если цена растёт. Попробуй открыть Long на учебном счёте — это безопасно.',
      );
  String get m2Size => t('Size', es: 'Tamaño', pt: 'Tamanho', ru: 'Размер');
  String get m2Fixed => t('fixed', es: 'fijo', pt: 'fixo', ru: 'фикс.');
  String get m2Balance => t(
        'Practice balance',
        es: 'Saldo de práctica',
        pt: 'Saldo de prática',
        ru: 'Учебный баланс',
      );
  String get m2ShortLocked => t(
        'Short unlocks after the path',
        es: 'Short se abre tras la ruta',
        pt: 'Short abre após a trilha',
        ru: 'Short откроется после пути',
      );
  String get m2OpenedTitle => t('Trade opened.', es: 'Operación abierta.', pt: 'Operação aberta.', ru: 'Сделка открыта.');
  String get m2OpenedBody => t(
        'This is a paper position — no real money involved.',
        es: 'Es una posición en papel — no hay dinero real.',
        pt: 'É uma posição em papel — sem dinheiro real.',
        ru: 'Это бумажная позиция — реальные деньги не участвуют.',
      );
  String get m2Position => t('Position', es: 'Posición', pt: 'Posição', ru: 'Позиция');
  String get m2Entry => t('Entry', es: 'Entrada', pt: 'Entrada', ru: 'Вход');
  String get m2PnlNow => t('Result now', es: 'Resultado ahora', pt: 'Resultado agora', ru: 'Результат сейчас');
  String get practice => t('practice', es: 'de práctica', pt: 'de prática', ru: 'учебных');
  String get m2CoachAfter => t(
        'The position is open but not protected. Next step — the stop.',
        es: 'La posición está abierta pero sin protección. Siguiente paso — el stop.',
        pt: 'A posição está aberta mas sem proteção. Próximo passo — o stop.',
        ru: 'Позиция открыта, но не защищена. Следующий шаг — стоп.',
      );
  String get m2Next => t(
        'Next: place the stop',
        es: 'Siguiente: colocar el stop',
        pt: 'Próximo: colocar o stop',
        ru: 'Дальше: поставить стоп',
      );

  // Mission 3
  String get m3WarnTitle => t('No stop set.', es: 'Sin stop.', pt: 'Sem stop.', ru: 'Стоп не выставлен.');
  String get m3WarnBody => t(
        'If price moves against you, the loss is not limited by anything.',
        es: 'Si el precio va en tu contra, la pérdida no tiene límite.',
        pt: 'Se o preço for contra você, a perda não tem limite.',
        ru: 'Если цена пойдёт против тебя, убыток ничем не ограничен.',
      );
  String get m3Risk => t('Trade risk', es: 'Riesgo de la operación', pt: 'Risco da operação', ru: 'Риск сделки');
  String get m3Unlimited => t('unlimited', es: 'ilimitado', pt: 'ilimitado', ru: 'не ограничен');
  String get m3Stop => t('Stop', es: 'Stop', pt: 'Stop', ru: 'Стоп');
  String get m3Place => t('Place stop', es: 'Colocar stop', pt: 'Colocar stop', ru: 'Поставить стоп');
  String get m3Finish => t('Finish mission', es: 'Terminar misión', pt: 'Concluir missão', ru: 'Завершить миссию');
  String get m3Blocked => t(
        'Place a stop first — this mission cannot be skipped.',
        es: 'Primero coloca un stop — esta misión no se puede saltar.',
        pt: 'Primeiro coloque um stop — esta missão não pode ser pulada.',
        ru: 'Сначала поставь стоп — эту миссию нельзя пропустить.',
      );
  String get m3RiskPer => t('Risk per trade', es: 'Riesgo por operación', pt: 'Risco por operação', ru: 'Риск на сделку');
  String get m3Coach => t(
        'The stop sits below your entry. You know in advance how much you can lose.',
        es: 'El stop está debajo de tu entrada. Sabes de antemano cuánto puedes perder.',
        pt: 'O stop fica abaixo da sua entrada. Você sabe de antemão quanto pode perder.',
        ru: 'Стоп ниже входа. Ты заранее знаешь, сколько можешь потерять.',
      );
  String get m3Confirm => t('Confirm stop', es: 'Confirmar stop', pt: 'Confirmar stop', ru: 'Подтвердить стоп');

  // Mission 4
  String get m4LiveTitle => t(
        'Position protected',
        es: 'Posición protegida',
        pt: 'Posição protegida',
        ru: 'Позиция защищена',
      );
  String get m4LiveBody => t(
        'Close the trade when you are ready — the recap writes itself.',
        es: 'Cierra la operación cuando quieras — el análisis se escribe solo.',
        pt: 'Feche a operação quando quiser — a análise se escreve sozinha.',
        ru: 'Закрой сделку, когда будешь готов — разбор запишется сам.',
      );
  String get m4Close => t('Close trade', es: 'Cerrar operación', pt: 'Fechar operação', ru: 'Закрыть сделку');
  String get m4Title => t(
        'Trade recap #1',
        es: 'Análisis de la operación n.º 1',
        pt: 'Análise da operação nº 1',
        ru: 'Разбор сделки №1',
      );
  String m4ClosedCap(String pair) => t(
        'Closed · Long $pair',
        es: 'Cerrada · Long $pair',
        pt: 'Fechada · Long $pair',
        ru: 'Закрыта · Long $pair',
      );
  String get m4Discipline => t('Discipline', es: 'Disciplina', pt: 'Disciplina', ru: 'Дисциплина');
  String get m4Check1 => t(
        'Stop set before exit',
        es: 'Stop colocado antes de salir',
        pt: 'Stop colocado antes da saída',
        ru: 'Стоп выставлен до выхода',
      );
  String m4RiskOk(String pct) => t(
        'Risk $pct% — within limits',
        es: 'Riesgo $pct% — dentro del límite',
        pt: 'Risco $pct% — dentro do limite',
        ru: 'Риск $pct% — в норме',
      );
  String m4RiskHigh(String pct) => t(
        'Risk $pct% — above 1%, go smaller next time',
        es: 'Riesgo $pct% — más de 1%, la próxima vez menos',
        pt: 'Risco $pct% — acima de 1%, da próxima vez menos',
        ru: 'Риск $pct% — выше 1%, в следующий раз меньше',
      );
  String get m4Check3 => t(
        'Closed by plan, no panic',
        es: 'Cerrada según el plan, sin pánico',
        pt: 'Fechada pelo plano, sem pânico',
        ru: 'Закрыта по плану, без паники',
      );
  String get m4Takeaway => t(
        'Take into tomorrow',
        es: 'Para mañana',
        pt: 'Para amanhã',
        ru: 'Что забрать в завтра',
      );
  String get m4TakeawayBody => t(
        'Set the stop before entry, not after. Then the risk is known in advance.',
        es: 'Coloca el stop antes de entrar, no después. Así el riesgo se conoce de antemano.',
        pt: 'Coloque o stop antes de entrar, não depois. Assim o risco é conhecido antes.',
        ru: 'Ставь стоп до входа, а не после. Тогда риск известен заранее.',
      );
  String get m4TakeawayRisk => t(
        'Keep risk at 1% or less per trade. Small losses keep you in the game.',
        es: 'Mantén el riesgo en 1% o menos por operación. Las pérdidas pequeñas te mantienen en el juego.',
        pt: 'Mantenha o risco em 1% ou menos por operação. Perdas pequenas mantêm você no jogo.',
        ru: 'Держи риск 1% или меньше на сделку. Маленькие убытки оставляют тебя в игре.',
      );
  String get m4Saved => t(
        'Entry saved to the journal',
        es: 'Registro guardado en el diario',
        pt: 'Registro salvo no diário',
        ru: 'Запись сохранена в журнал',
      );
  String get m4Accept => t('Got it', es: 'Entendido', pt: 'Entendi', ru: 'Принял');

  // First win
  String get winStreakDay => t('day streak', es: 'día de racha', pt: 'dia de sequência', ru: 'день серии');
  String get winTitle => t(
        'First paper trade closed',
        es: 'Primera operación en papel cerrada',
        pt: 'Primeira operação em papel fechada',
        ru: 'Первая сделка на бумаге закрыта',
      );
  String get winSub => t(
        'You finished the beginner path: candle, trade, stop, recap',
        es: 'Completaste la ruta: vela, operación, stop, análisis',
        pt: 'Você concluiu a trilha: candle, operação, stop, análise',
        ru: 'Ты прошёл путь новичка: свеча, сделка, стоп, разбор',
      );
  String get winOpenBadge => t('OPEN', es: 'ABIERTO', pt: 'ABERTO', ru: 'ОТКРЫТ');
  String get winJournal => t(
        'Journal: 1 entry',
        es: 'Diario: 1 registro',
        pt: 'Diário: 1 registro',
        ru: 'Журнал: 1 запись',
      );
  String get winNewBadge => t('NEW', es: 'NUEVO', pt: 'NOVO', ru: 'НОВОЕ');
  String get winSave => t(
        'Save progress',
        es: 'Guardar progreso',
        pt: 'Salvar progresso',
        ru: 'Сохранить прогресс',
      );
  String get winRemind => t(
        'Remind me tomorrow',
        es: 'Recordarme mañana',
        pt: 'Lembrar amanhã',
        ru: 'Напомнить завтра',
      );
  String get winToDesk => t(
        'Go to Daily Desk',
        es: 'Ir a Daily Desk',
        pt: 'Ir para o Daily Desk',
        ru: 'Перейти в Daily Desk',
      );

  // Reminder
  String get remTitle => t(
        'When is it convenient to practice?',
        es: '¿Cuándo te viene bien practicar?',
        pt: 'Quando é melhor praticar?',
        ru: 'Когда удобно практиковаться?',
      );
  String get remSub => t(
        'One reminder a day about Daily Desk. Turn it off in Profile.',
        es: 'Un recordatorio al día sobre Daily Desk. Se desactiva en el perfil.',
        pt: 'Um lembrete por dia sobre o Daily Desk. Desative no perfil.',
        ru: 'Одно напоминание в день о Daily Desk. Отключается в профиле.',
      );
  String remCta(String time) => t(
        'Remind at $time',
        es: 'Recordar a las $time',
        pt: 'Lembrar às $time',
        ru: 'Напоминать в $time',
      );
  String remSet(String time) => t(
        'We will remind you at $time',
        es: 'Te lo recordaremos a las $time',
        pt: 'Vamos lembrar você às $time',
        ru: 'Напомним в $time',
      );
  String get notNow => t('Not now', es: 'Ahora no', pt: 'Agora não', ru: 'Не сейчас');

  // Day-3 community gate
  String d3Title(int days) => t(
        '$days days of discipline in a row',
        es: '$days días de disciplina seguidos',
        pt: '$days dias de disciplina seguidos',
        ru: '$days ${_ruDays(days)} дисциплины подряд',
      );
  String get d3StopStat => t(
        'trades with a stop',
        es: 'operaciones con stop',
        pt: 'operações com stop',
        ru: 'сделок со стопом',
      );
  String get d3StreakStat => t(
        'days in a row',
        es: 'días seguidos',
        pt: 'dias seguidos',
        ru: 'дней подряд',
      );
  String get d3ClubLead => 'Desk Club';
  String get d3ClubBody => t(
        ' — a community of practitioners. We share streaks, review weeks and ask questions. No signals.',
        es: ' — una comunidad de practicantes. Compartimos rachas, revisamos semanas y hacemos preguntas. Sin señales.',
        pt: ' — uma comunidade de praticantes. Compartilhamos sequências, revisamos semanas e tiramos dúvidas. Sem sinais.',
        ru: ' — сообщество практиков. Делимся серией, разбираем недели, задаём вопросы. Без сигналов.',
      );
  String get d3Join => t(
        'Join Desk Club',
        es: 'Unirme a Desk Club',
        pt: 'Entrar no Desk Club',
        ru: 'Вступить в Desk Club',
      );

  String _ruDays(int n) {
    final m10 = n % 10;
    final m100 = n % 100;
    if (m10 == 1 && m100 != 11) return 'день';
    if (m10 >= 2 && m10 <= 4 && (m100 < 12 || m100 > 14)) return 'дня';
    return 'дней';
  }
}
