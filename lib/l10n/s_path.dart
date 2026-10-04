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
  String homeNowHint(int step) => switch (step) {
        1 => t(
            'Now: learn one candle — then the first trade.',
            es: 'Ahora: aprende una vela — luego la primera operación.',
            pt: 'Agora: aprenda um candle — depois a primeira operação.',
            ru: 'Сейчас: разбери одну свечу — потом первая сделка.',
          ),
        2 => t(
            'Now: open one Long on paper. Next mission will add the stop.',
            es: 'Ahora: abre un Long en papel. La siguiente misión pone el stop.',
            pt: 'Agora: abra um Long no papel. A próxima missão coloca o stop.',
            ru: 'Сейчас: открой один Long на бумаге. Дальше в следующей миссии — стоп.',
          ),
        3 => t(
            'Now: put a 1% stop on the open trade — without it you can’t finish.',
            es: 'Ahora: pon un stop del 1% en la operación — sin él no terminas.',
            pt: 'Agora: coloque um stop de 1% na operação — sem ele não termina.',
            ru: 'Сейчас: поставь стоп 1% на открытую сделку — без него миссию не закрыть.',
          ),
        4 => t(
            'Now: close the trade and read the short recap.',
            es: 'Ahora: cierra la operación y lee el recap corto.',
            pt: 'Agora: feche a operação e leia o recap curto.',
            ru: 'Сейчас: закрой сделку и прочитай короткий разбор.',
          ),
        _ => t(
            'Path done — next we learn a real market move.',
            es: 'Ruta hecha — ahora aprendemos un movimiento real.',
            pt: 'Trilha feita — agora aprendemos um movimento real.',
            ru: 'Путь закрыт — дальше учим реальное движение рынка.',
          ),
      };
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
        'You traded the bounce for $days days',
        es: 'Operaste el rebote durante $days días',
        pt: 'Você operou o bounce por $days dias',
        ru: 'Ты $days ${_ruDays(days)} торговал отскок',
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
        ' — we trade the same bounce on a live account and review entries. No “buy now” signals.',
        es: ' — operamos el mismo rebote en cuenta real y revisamos entradas. Sin señales de “compra ya”.',
        pt: ' — operamos o mesmo bounce em conta real e revisamos entradas. Sem sinais de “compre agora”.',
        ru: ' — торгуем тот же отскок на живом счёте и разбираем входы. Без сигналов «покупай сейчас».',
      );
  String get d3Join => t(
        'Watch live review',
        es: 'Ver el review en vivo',
        pt: 'Ver o review ao vivo',
        ru: 'Смотреть live-разбор',
      );

  // ── Floor 0: orientation before missions ──
  String get orientOf => t('Before missions', es: 'Antes de las misiones', pt: 'Antes das missões', ru: 'Перед миссиями');
  String orientStepOf(int n) => t(
        'Step $n of 3',
        es: 'Paso $n de 3',
        pt: 'Passo $n de 3',
        ru: 'Шаг $n из 3',
      );
  String get orientChartTitle => t(
        'This is a price chart',
        es: 'Esto es un gráfico de precio',
        pt: 'Isto é um gráfico de preço',
        ru: 'Это график цены',
      );
  String get orientChartBody => t(
        'Left to right — time. Up and down — price. Each bar is a moment of the market.',
        es: 'De izquierda a derecha — tiempo. Arriba y abajo — precio. Cada barra es un momento del mercado.',
        pt: 'Da esquerda para a direita — tempo. Para cima e para baixo — preço. Cada barra é um momento do mercado.',
        ru: 'Слева направо — время. Вверх-вниз — цена. Каждый столбик — момент рынка.',
      );
  String get orientBtcTitle => t(
        'What BTC/USDT means here',
        es: 'Qué significa BTC/USDT aquí',
        pt: 'O que BTC/USDT significa aqui',
        ru: 'Что такое BTC/USDT здесь',
      );
  String get orientBtcBody => t(
        'BTC is bitcoin. USDT is like dollars in the app. The number is how many practice dollars one bitcoin costs right now.',
        es: 'BTC es bitcoin. USDT es como dólares en la app. El número es cuántos dólares de práctica cuesta un bitcoin ahora.',
        pt: 'BTC é bitcoin. USDT é como dólares no app. O número é quantos dólares de prática custa um bitcoin agora.',
        ru: 'BTC — биткоин. USDT — как доллары в приложении. Число — сколько учебных долларов стоит один биткоин сейчас.',
      );
  String get orientCandleTitle => t(
        'This bar is a candle',
        es: 'Esta barra es una vela',
        pt: 'Esta barra é um candle',
        ru: 'Этот столбик — свеча',
      );
  String get orientCandleBody => t(
        'One candle shows how price moved in a short slice of time. Next we open it up: open, high, low, close.',
        es: 'Una vela muestra cómo se movió el precio en un tramo corto. Luego la abrimos: open, high, low, close.',
        pt: 'Um candle mostra como o preço se moveu num pedaço curto de tempo. Depois abrimos: open, high, low, close.',
        ru: 'Одна свеча показывает, как цена двигалась за короткий отрезок времени. Дальше разберём её: open, high, low, close.',
      );
  String get orientNext => t('Got it', es: 'Entendido', pt: 'Entendi', ru: 'Понял');
  String get orientToMissions => t(
        'Break down the candle',
        es: 'Desglosar la vela',
        pt: 'Desmontar o candle',
        ru: 'Разобрать свечу',
      );
  String get orientPriceNow => t('Price now', es: 'Precio ahora', pt: 'Preço agora', ru: 'Цена сейчас');

  // ── Phase 2: moves → paper → live ──
  String get bridgeCap => t(
        'Beginner path · done',
        es: 'Ruta de principiante · hecha',
        pt: 'Trilha de iniciante · feita',
        ru: 'Путь новичка · закрыт',
      );
  String get bridgeTitle => t(
        'Now we learn moves',
        es: 'Ahora aprendemos movimientos',
        pt: 'Agora aprendemos movimentos',
        ru: 'Теперь учимся торговать движениями',
      );
  String get bridgeSub => t(
        'Not every button at once. Today — one basic move you will later see live in Desk Club.',
        es: 'No todos los botones a la vez. Hoy — un movimiento básico que luego verás en vivo en Desk Club.',
        pt: 'Não todos os botões de uma vez. Hoje — um movimento básico que depois verá ao vivo no Desk Club.',
        ru: 'Не все кнопки сразу. Сегодня — одно базовое движение, которое потом увидишь в клубе на живом счёте.',
      );
  String get bridgeChip => t(
        'TODAY · 5 MIN',
        es: 'HOY · 5 MIN',
        pt: 'HOJE · 5 MIN',
        ru: 'СЕГОДНЯ · 5 МИН',
      );
  String get bridgeMoveTitle => t(
        'Move 1 · Bounce up',
        es: 'Movimiento 1 · Rebote arriba',
        pt: 'Movimento 1 · Bounce para cima',
        ru: 'Движение 1 · Отскок вверх',
      );
  String get bridgeMoveBody => t(
        'Watch the replay → make a paper trade → set stop → close',
        es: 'Miras el replay → haces una operación en papel → pones stop → cierras',
        pt: 'Assiste o replay → faz uma operação no papel → coloca stop → fecha',
        ru: 'Смотришь реплей → делаешь сделку на бумаге → ставишь стоп → закрываешь',
      );
  String get bridgeCta => t(
        'Watch the move',
        es: 'Ver el movimiento',
        pt: 'Ver o movimento',
        ru: 'Смотреть движение',
      );
  String get bridgeLockBook => t(
        'Journal · opens after the first trade',
        es: 'Diario · se abre tras la primera operación',
        pt: 'Diário · abre após a primeira operação',
        ru: 'Журнал · откроется после первой сделки',
      );
  String get bridgeLockLeague => t(
        'League · after 7 days of discipline',
        es: 'Liga · tras 7 días de disciplina',
        pt: 'Liga · após 7 dias de disciplina',
        ru: 'Лига · после 7 дней дисциплины',
      );
  String get bridgeLockGloss => t(
        'Glossary · when you already lived the words',
        es: 'Glosario · cuando ya viviste las palabras',
        pt: 'Glossário · quando já viveu as palavras',
        ru: 'Глоссарий · когда слова уже прожил',
      );

  String get moveReplayLabel => t(
        'Move 1 of 3 · replay',
        es: 'Movimiento 1 de 3 · replay',
        pt: 'Movimento 1 de 3 · replay',
        ru: 'Движение 1 из 3 · реплей',
      );
  String get moveTitle => t(
        'Bounce up',
        es: 'Rebote arriba',
        pt: 'Bounce para cima',
        ru: 'Отскок вверх',
      );
  String get moveStep1 => t(
        'Price came down to a horizontal line',
        es: 'El precio bajó hasta una línea horizontal',
        pt: 'O preço veio até uma linha horizontal',
        ru: 'Цена пришла вниз к горизонтальной линии',
      );
  String get moveStep2 => t(
        'It bounced up — here we bought Long',
        es: 'Rebotó arriba — aquí compramos Long',
        pt: 'Deu bounce para cima — aqui compramos Long',
        ru: 'Отскочила вверх — здесь купили Long',
      );
  String get moveStep3 => t(
        'Stop just below the line. Target higher',
        es: 'Stop justo debajo de la línea. Objetivo más arriba',
        pt: 'Stop logo abaixo da linha. Alvo mais alto',
        ru: 'Стоп чуть ниже линии. Цель — выше',
      );
  String get moveStep4 => t(
        'Price reached the target — we closed. Done',
        es: 'Llegó al objetivo — cerramos. Listo',
        pt: 'Chegou no alvo — fechamos. Pronto',
        ru: 'Дошло до цели — закрыли. Готово',
      );
  String get moveReplayCta => t(
        'Make a paper trade',
        es: 'Hacer operación en papel',
        pt: 'Fazer operação no papel',
        ru: 'Сделать сделку на бумаге',
      );
  String get moveCopyLabel => t(
        'Trade · move 1',
        es: 'Operación · movimiento 1',
        pt: 'Operação · movimento 1',
        ru: 'Сделка · движение 1',
      );
  String get moveCopyCoach => t(
        'Tap Buy · Long at the bright cyan line labeled BUY. That is the bounce zone from the replay. Stop goes below it.',
        es: 'Pulsa Buy · Long en la línea cian brillante marcada BUY. Esa es la zona del rebote del replay. El stop va debajo.',
        pt: 'Toque Buy · Long na linha ciano marcada BUY. Essa é a zona do bounce do replay. O stop fica abaixo.',
        ru: 'Жми Buy · Long у яркой голубой линии с подписью КУПИ. Это зона отскока из реплея. Стоп — ниже неё.',
      );
  String get moveBuyLine => t('BUY', es: 'BUY', pt: 'BUY', ru: 'КУПИ');
  String get moveLookLine => t(
        'Look at the cyan BUY line on the chart ↓',
        es: 'Mira la línea cian BUY en el gráfico ↓',
        pt: 'Olhe a linha ciano BUY no gráfico ↓',
        ru: 'Смотри на голубую линию КУПИ на графике ↓',
      );
  String get movePaper => t('PAPER', es: 'PAPEL', pt: 'PAPEL', ru: 'БУМАГА');
  String get moveTargetLabel => t('Target', es: 'Objetivo', pt: 'Alvo', ru: 'Цель');
  String get moveTargetHint => t(
        'as in the replay',
        es: 'como en el replay',
        pt: 'como no replay',
        ru: 'как в реплее',
      );
  String get moveOpened => t(
        'Looks like the replay.',
        es: 'Parece el replay.',
        pt: 'Parece o replay.',
        ru: 'Похоже на реплей.',
      );
  String get moveOpenedBody => t(
        'Stop is on. Wait for the target or close by plan.',
        es: 'El stop está puesto. Espera el objetivo o cierra según el plan.',
        pt: 'O stop está no lugar. Espere o alvo ou feche pelo plano.',
        ru: 'Стоп на месте. Жди цель или закрой по плану.',
      );
  String get moveCloseTarget => t(
        'Close at target',
        es: 'Cerrar en el objetivo',
        pt: 'Fechar no alvo',
        ru: 'Закрыть у цели',
      );
  String get moveCopyDoneTitle => t(
        'First trade done',
        es: 'Primera operación hecha',
        pt: 'Primeira operação feita',
        ru: 'Первая сделка готова',
      );
  String get moveCopyDoneBody => t(
        'You learned the bounce. Next step: Daily Desk — practice the same move again today. Day 3 unlocks the live review.',
        es: 'Aprendiste el rebote. Siguiente: Daily Desk — practica el mismo movimiento hoy. El día 3 abre el review en vivo.',
        pt: 'Você aprendeu o bounce. Próximo: Daily Desk — pratique o mesmo movimento hoje. O dia 3 abre o review ao vivo.',
        ru: 'Ты увидел отскок. Дальше — Daily Desk: сегодня сделай ещё одну сделку по тому же движению. На 3-й день откроется live-разбор.',
      );
  /// Counter chip under first-trade done screen, e.g. «2 / 3 сделки».
  String moveTradesCount(int n) => t(
        '$n / 3 trades',
        es: '$n / 3 operaciones',
        pt: '$n / 3 operações',
        ru: '$n / 3 ${_ruTrades(n == 0 ? 3 : n)}',
      );
  String get tradesStatLabel => t('trades', es: 'operaciones', pt: 'operações', ru: 'сделок');
  String get moveToToday => t(
        'Go to Daily Desk',
        es: 'Ir al Daily Desk',
        pt: 'Ir para o Daily Desk',
        ru: 'К Daily Desk',
      );

  String get todayCap => t('Today', es: 'Hoy', pt: 'Hoje', ru: 'Сегодня');
  String todayDayCap(String weekday, int day) => t(
        '$weekday · day $day',
        es: '$weekday · día $day',
        pt: '$weekday · dia $day',
        ru: '$weekday · день $day',
      );

  // Phase-2 “what now” — one line so the funnel never feels foggy.
  String get phaseRailMissions => t('Missions', es: 'Misiones', pt: 'Missões', ru: 'Миссии');
  String get phaseRailMove => t('Move 1', es: 'Mov. 1', pt: 'Mov. 1', ru: 'Движение 1');
  String get phaseRailDesk => t('Desk', es: 'Desk', pt: 'Desk', ru: 'Desk');
  String get phaseRailLive => t('Live', es: 'Live', pt: 'Live', ru: 'Live');
  String get phaseNextMove => t(
        'Now: watch the bounce replay, then make one paper trade.',
        es: 'Ahora: mira el replay del rebote y haz una operación en papel.',
        pt: 'Agora: veja o replay do bounce e faça uma operação no papel.',
        ru: 'Сейчас: посмотри реплей отскока и сделай одну сделку на бумаге.',
      );
  String get phaseNextDesk => t(
        'Now: Daily Desk — same bounce 1–2 times with a 1% stop. That closes today.',
        es: 'Ahora: Daily Desk — el mismo rebote 1–2 veces con stop 1%. Eso cierra el día.',
        pt: 'Agora: Daily Desk — o mesmo bounce 1–2 vezes com stop 1%. Isso fecha o dia.',
        ru: 'Сейчас: Daily Desk — тот же отскок 1–2 раза со стопом 1%. Так закрывается день.',
      );
  String get phaseNextAdvance => t(
        'Today’s desk is closed. Peek at tomorrow’s tasks — or practice again.',
        es: 'El desk de hoy está cerrado. Mira las tareas de mañana — o practica otra vez.',
        pt: 'O desk de hoje está fechado. Veja as tarefas de amanhã — ou pratique de novo.',
        ru: 'Desk за сегодня закрыт. Можно глянуть задания завтра — или потренироваться ещё.',
      );
  String get phasePracticeAgain => t(
        'Practice again',
        es: 'Practicar otra vez',
        pt: 'Praticar de novo',
        ru: 'Ещё раз потренироваться',
      );
  String get todayDeskTitle => 'Daily Desk';
  String get todayDeskMins => t('4–7 min', es: '4–7 min', pt: '4–7 min', ru: '4–7 мин');
  String get todayTask1 => t(
        'Repeat “Bounce up” 1–2 times',
        es: 'Repite “Rebote arriba” 1–2 veces',
        pt: 'Repita “Bounce para cima” 1–2 vezes',
        ru: 'Повтори движение «Отскок вверх» 1–2 раза',
      );
  String get todayTask2 => t(
        'Each trade with a 1% stop',
        es: 'Cada operación con stop del 1%',
        pt: 'Cada operação com stop de 1%',
        ru: 'Каждая сделка — со стопом 1%',
      );
  String get todayTask3 => t(
        'Short recap at the end',
        es: 'Un recap corto al final',
        pt: 'Um recap curto no fim',
        ru: 'Короткий разбор в конце',
      );
  /// Habit-day task pack (days cycle the same bounce with a sharper focus).
  String todayTask1For(int day) {
    final d = ((day - 1) % 7) + 1;
    return switch (d) {
      2 => t(
          'Same bounce again — 1–2 clean trades',
          es: 'El mismo rebote otra vez — 1–2 operaciones limpias',
          pt: 'O mesmo bounce de novo — 1–2 operações limpas',
          ru: 'Снова тот же отскок — 1–2 чистые сделки',
        ),
      3 => t(
          '1–2 trades · then peek at Desk Club',
          es: '1–2 operaciones · luego mira Desk Club',
          pt: '1–2 operações · depois olhe o Desk Club',
          ru: '1–2 сделки · потом загляни в Desk Club',
        ),
      4 => t(
          'Trade only if the zone looks like the replay',
          es: 'Opera solo si la zona parece el replay',
          pt: 'Opere só se a zona parecer o replay',
          ru: 'Входи в сделку только если зона похожа на реплей',
        ),
      5 => t(
          'Two trades max · skip is allowed',
          es: 'Máximo dos operaciones · saltar está bien',
          pt: 'No máximo duas operações · pular vale',
          ru: 'Максимум две сделки · пропуск можно',
        ),
      6 => t(
          'Warm-up: one careful bounce trade',
          es: 'Calentamiento: una operación cuidadosa del rebote',
          pt: 'Aquecimento: uma operação cuidadosa do bounce',
          ru: 'Разминка: одна аккуратная сделка на отскок',
        ),
      7 => t(
          'Week check: bounce + stop still automatic?',
          es: 'Chequeo semanal: ¿rebote + stop ya automático?',
          pt: 'Checagem da semana: bounce + stop já automático?',
          ru: 'Проверка недели: отскок + стоп уже на автомате?',
        ),
      _ => todayTask1,
    };
  }

  String todayTask2For(int day) {
    final d = ((day - 1) % 7) + 1;
    return switch (d) {
      2 => t(
          'Stop 1% every time — no exceptions',
          es: 'Stop 1% siempre — sin excepciones',
          pt: 'Stop 1% sempre — sem exceções',
          ru: 'Стоп 1% каждый раз — без исключений',
        ),
      3 => t(
          'Keep risk at 1% · note the live tease',
          es: 'Mantén riesgo 1% · mira el teaser en vivo',
          pt: 'Mantenha risco 1% · veja o teaser ao vivo',
          ru: 'Риск 1% · обрати внимание на live-тизер',
        ),
      4 => t(
          'If unsure — skip. Skipping scores discipline',
          es: 'Si dudas — salta. Saltar suma disciplina',
          pt: 'Se duvidar — pule. Pular soma disciplina',
          ru: 'Если не уверен — пропусти. Пропуск = дисциплина',
        ),
      _ => todayTask2,
    };
  }

  String todayTask3For(int day) {
    final d = ((day - 1) % 7) + 1;
    return switch (d) {
      2 => t(
          'Recap: what matched the replay?',
          es: 'Recap: ¿qué coincidió con el replay?',
          pt: 'Recap: o que bateu com o replay?',
          ru: 'Разбор: что совпало с реплеем?',
        ),
      3 => t(
          'Tomorrow’s live review uses this same bounce',
          es: 'El review en vivo de mañana usa este mismo rebote',
          pt: 'O review ao vivo de amanhã usa o mesmo bounce',
          ru: 'Завтрашний live-разбор — про этот же отскок',
        ),
      _ => todayTask3,
    };
  }

  String get todayStart => t(
        'Start today',
        es: 'Empezar hoy',
        pt: 'Começar hoje',
        ru: 'Начать сегодня',
      );
  String get todayNextDay => t(
        'Go to next day’s tasks',
        es: 'Ir a las tareas del día siguiente',
        pt: 'Ir às tarefas do próximo dia',
        ru: 'К заданиям следующего дня',
      );
  String get todayDayDone => t(
        'Desk for this day is done',
        es: 'Desk de este día está hecho',
        pt: 'Desk deste dia está feito',
        ru: 'Desk за этот день закрыт',
      );
  String get todayNextHint => t(
        'See what’s next — same move, sharper focus',
        es: 'Mira lo siguiente — mismo movimiento, foco más nítido',
        pt: 'Veja o que vem — mesmo movimento, foco mais nítido',
        ru: 'Глянь что дальше — то же движение, жёстче фокус',
      );
  String get todayReplay => t(
        'Move 1 replay',
        es: 'Replay del movimiento 1',
        pt: 'Replay do movimento 1',
        ru: 'Реплей движения 1',
      );
  String get todayReplaySub => t(
        '30 sec · rewatch anytime',
        es: '30 seg · se puede ver otra vez',
        pt: '30 seg · pode rever',
        ru: '30 сек · можно пересмотреть',
      );
  String get todayClubLocked => t(
        'Desk Club',
        es: 'Desk Club',
        pt: 'Desk Club',
        ru: 'Desk Club',
      );
  String get todayClubLockedSub => t(
        'After 2 trades and a 3-day streak — Telegram invite',
        es: 'Tras 2 operaciones y racha de 3 — invitación a Telegram',
        pt: 'Após 2 operações e sequência de 3 — convite no Telegram',
        ru: 'После 2 сделок и стрика 3 дня — приглашение в Telegram',
      );
  String get todayClubReadySub => t(
        'Invite ready — open Desk Club',
        es: 'Invitación lista — abre Desk Club',
        pt: 'Convite pronto — abra o Desk Club',
        ru: 'Приглашение готово — открой Desk Club',
      );
  String get todayClubOpenSub => t(
        'Open Telegram club',
        es: 'Abrir club en Telegram',
        pt: 'Abrir clube no Telegram',
        ru: 'Открыть клуб в Telegram',
      );
  String get todayNeedMove => t(
        'First trade the move — then Daily Desk opens fully',
        es: 'Primero opera el movimiento — luego se abre el Daily Desk',
        pt: 'Primeiro opere o movimento — depois o Daily Desk abre',
        ru: 'Сначала сделай сделку по движению — потом откроется Daily Desk',
      );
  String get todayFinish => t(
        'Finish desk',
        es: 'Terminar desk',
        pt: 'Concluir desk',
        ru: 'Завершить desk',
      );
  String get todaySessionCoach => t(
        'Same bounce again. If the zone looks like the replay — enter. If not — skip. Skipping is discipline too.',
        es: 'El mismo rebote. Si la zona parece el replay — entra. Si no — salta. Saltar también es disciplina.',
        pt: 'O mesmo bounce. Se a zona parece o replay — entre. Se não — pule. Pular também é disciplina.',
        ru: 'Это снова отскок вверх. Если зона похожа на реплей — входи. Если нет — пропусти. Пропуск тоже дисциплина.',
      );
  String get todaySkip => t('Skip', es: 'Saltar', pt: 'Pular', ru: 'Пропустить');
  String get bookLockedHint => t(
        'Journal opens after your first move trade',
        es: 'El diario se abre tras tu primera operación',
        pt: 'O diário abre após sua primeira operação',
        ru: 'Журнал откроется после первой сделки по движению',
      );
  String get leagueLockedHint => t(
        'League opens after 7 days of discipline',
        es: 'La liga se abre tras 7 días de disciplina',
        pt: 'A liga abre após 7 dias de disciplina',
        ru: 'Лига откроется после 7 дней дисциплины',
      );

  // ── Phase 3: week done → League + terminal tour ──
  String get p3Cap => t(
        'Week complete',
        es: 'Semana completa',
        pt: 'Semana completa',
        ru: 'Неделя закрыта',
      );
  String p3StepOf(int n) => t(
        'Step $n of 4',
        es: 'Paso $n de 4',
        pt: 'Passo $n de 4',
        ru: 'Шаг $n из 4',
      );
  String get p3Title0 => t(
        'You built the habit',
        es: 'Construiste el hábito',
        pt: 'Você construiu o hábito',
        ru: 'Ты собрал привычку',
      );
  String get p3Body0 => t(
        'Seven Daily Desks. Same bounce, stop every time. Next — League: compete on process, not luck.',
        es: 'Siete Daily Desks. Mismo rebote, stop siempre. Siguiente — Liga: compite por proceso, no por suerte.',
        pt: 'Sete Daily Desks. Mesmo bounce, stop sempre. Próximo — Liga: dispute por processo, não por sorte.',
        ru: 'Семь Daily Desk. Тот же отскок, стоп каждый раз. Дальше — Лига: соревнуемся в процессе, не в удаче.',
      );
  String get p3Title1 => t(
        'What League is',
        es: 'Qué es la Liga',
        pt: 'O que é a Liga',
        ru: 'Что такое Лига',
      );
  String get p3Body1 => t(
        'Weekly board. XP for desks with a stop and trades that look like the replay. All-in luck does not feed rank.',
        es: 'Tabla semanal. XP por desks con stop y operaciones parecidas al replay. La suerte all-in no sube el rango.',
        pt: 'Placar semanal. XP por desks com stop e operações parecidas com o replay. Sorte all-in não sobe o rank.',
        ru: 'Таблица недели. XP за desk со стопом и сделки, похожие на реплей. All-in на удачу рейтинг не кормит.',
      );
  String get p3LeaguePoint1 => t(
        'Score = discipline process',
        es: 'Puntos = proceso disciplinado',
        pt: 'Pontos = processo disciplinado',
        ru: 'Очки = дисциплина процесса',
      );
  String get p3LeaguePoint2 => t(
        'Season clock · 28 days',
        es: 'Reloj de temporada · 28 días',
        pt: 'Relógio da season · 28 dias',
        ru: 'Сезон · 28 дней',
      );
  String get p3LeaguePoint3 => t(
        'You vs peers who also practiced',
        es: 'Tú vs pares que también practicaron',
        pt: 'Você vs pares que também praticaram',
        ru: 'Ты против таких же, кто тоже практиковал',
      );
  String get p3Title2 => t(
        'Four tabs — what each does',
        es: 'Cuatro pestañas — qué hace cada una',
        pt: 'Quatro abas — o que cada uma faz',
        ru: 'Четыре вкладки — зачем каждая',
      );
  String get p3TabDesk => t(
        'Desk — chart + Daily Desk + trades',
        es: 'Desk — gráfico + Daily Desk + operaciones',
        pt: 'Desk — gráfico + Daily Desk + operações',
        ru: 'Деск — график + Daily Desk + сделки',
      );
  String get p3TabBook => t(
        'Book — your closed trades & journal',
        es: 'Book — operaciones cerradas y diario',
        pt: 'Book — operações fechadas e diário',
        ru: 'Книга — закрытые сделки и журнал',
      );
  String get p3TabLeague => t(
        'League — week board & season',
        es: 'Liga — tabla de la semana y temporada',
        pt: 'Liga — placar da semana e season',
        ru: 'Лига — таблица недели и сезон',
      );
  String get p3TabYou => t(
        'You — profile, streak, reminder, language',
        es: 'Tú — perfil, racha, recordatorio, idioma',
        pt: 'Você — perfil, sequência, lembrete, idioma',
        ru: 'Вы — профиль, серия, напоминание, язык',
      );
  String get p3Title3 => t(
        'Desk buttons you’ll use',
        es: 'Botones del Desk que usarás',
        pt: 'Botões do Desk que você usará',
        ru: 'Кнопки Деска, которыми пользуешься',
      );
  String get p3BtnLong => t(
        'Buy · Long — practice if the bounce looks like the replay',
        es: 'Buy · Long — practica si el rebote parece el replay',
        pt: 'Buy · Long — pratique se o bounce parecer o replay',
        ru: 'Buy · Long — входи, если отскок похож на реплей',
      );
  String get p3BtnShort => t(
        'Short — unlocked carefully; still with a stop',
        es: 'Short — se abre con cuidado; siempre con stop',
        pt: 'Short — abre com cuidado; sempre com stop',
        ru: 'Short — откроется осторожно; всё равно со стопом',
      );
  String get p3BtnDesk => t(
        'Daily Desk strip — still your 4–7 min ritual every day',
        es: 'Daily Desk — sigue siendo tu ritual de 4–7 min al día',
        pt: 'Daily Desk — continua seu ritual de 4–7 min por dia',
        ru: 'Daily Desk — по-прежнему ритуал 4–7 минут каждый день',
      );
  String get p3Next => t('Got it', es: 'Entendido', pt: 'Entendi', ru: 'Понял');
  String get p3ToLeague => t(
        'Open League',
        es: 'Abrir Liga',
        pt: 'Abrir Liga',
        ru: 'Открыть Лигу',
      );
  String get p3LeagueCoach => t(
        'You’re here because you repeated moves. Rank moves on process XP — not on one lucky candle.',
        es: 'Estás aquí porque repetiste movimientos. El rango mueve XP de proceso — no una vela de suerte.',
        pt: 'Você está aqui porque repetiu movimentos. O rank move XP de processo — não um candle de sorte.',
        ru: 'Ты здесь, потому что повторял движения. Ранг двигает XP за процесс — не одна везучая свеча.',
      );

  // League screen explainer
  String get liTitle => t(
        'How to read League',
        es: 'Cómo leer la Liga',
        pt: 'Como ler a Liga',
        ru: 'Как читать Лигу',
      );
  String get liYou => t(
        'Your card — rank, XP and what moved it',
        es: 'Tu tarjeta — rango, XP y qué lo movió',
        pt: 'Seu card — rank, XP e o que o moveu',
        ru: 'Твоя карточка — место, XP и что его сдвинуло',
      );
  String get liScore => t(
        'Score breakdown — stop, size, no revenge = XP',
        es: 'Desglose — stop, tamaño, sin revancha = XP',
        pt: 'Detalhe — stop, tamanho, sem revanche = XP',
        ru: 'Разбор очков — стоп, размер, без отыгрыша = XP',
      );
  String get liFeed => t(
        'Live feed — what other players just closed',
        es: 'Feed en vivo — qué cerraron otros jugadores',
        pt: 'Feed ao vivo — o que outros jogadores fecharam',
        ru: 'Лента — что сейчас закрыли другие игроки',
      );
  String get liBoard => t(
        'Podium & standings — weekly board, resets with the season',
        es: 'Podio y tabla — semanal, se reinicia con la temporada',
        pt: 'Pódio e tabela — semanal, reinicia com a season',
        ru: 'Пьедестал и таблица — неделя, обнуляется с сезоном',
      );
  String get liHowUp => t(
        'How to climb: close today’s Daily Desk with a stop. That’s it.',
        es: 'Cómo subir: cierra el Daily Desk de hoy con stop. Eso es todo.',
        pt: 'Como subir: feche o Daily Desk de hoje com stop. Só isso.',
        ru: 'Как подняться: закрой сегодняшний Daily Desk со стопом. Всё.',
      );
  String get liOk => t('Clear', es: 'Claro', pt: 'Entendi', ru: 'Понятно');
  String get liToDesk => t(
        'To Daily Desk',
        es: 'Al Daily Desk',
        pt: 'Para o Daily Desk',
        ru: 'К Daily Desk',
      );

  String get moveSellLine => t('SELL', es: 'VENDER', pt: 'VENDER', ru: 'ПРОДАЙ');
  String get moveLookLineShort => t(
        'When price returns to this line — sell (Short)',
        es: 'Cuando el precio vuelve a esta línea — vende (Short)',
        pt: 'Quando o preço volta a esta linha — venda (Short)',
        ru: 'Когда цена снова у этой линии — продавай (Short)',
      );
  String get moveCopyCoachShort => t(
        'Same risk 1%. Stop ABOVE the entry. You profit if price falls.',
        es: 'Mismo riesgo 1%. Stop ARRIBA. Ganas si baja.',
        pt: 'Mesmo risco 1%. Stop ACIMA. Lucra se cair.',
        ru: 'Тот же риск 1%. Стоп ВЫШЕ входа. Зарабатываешь, если цена падает.',
      );
  String get moveTargetHintShort => t(
        'small drop · process > PnL',
        es: 'pequeña bajada · proceso > PnL',
        pt: 'queda pequena · processo > PnL',
        ru: 'небольшое падение · процесс > PnL',
      );

  // Glossary
  String get glCap => t('Terms', es: 'Términos', pt: 'Termos', ru: 'Термины');
  String get glTitle => t('Five words you’ll see next', es: 'Cinco palabras que verás', pt: 'Cinco palavras que verá', ru: 'Пять слов, которые увидишь дальше');
  String get glBody => t(
        'After 3 trades — open the dictionary once. Then back to Daily Desk.',
        es: 'Tras 3 operaciones — abre el diccionario una vez. Luego vuelve al Daily Desk.',
        pt: 'Após 3 operações — abra o dicionário uma vez. Depois volte ao Daily Desk.',
        ru: 'После 3 сделок — один раз открой словарь. Потом снова к Daily Desk.',
      );
  String get glTerm1 => 'Long';
  String get glDef1 => t('Buy first — profit if price rises', es: 'Compras primero — ganas si sube', pt: 'Compra primeiro — lucra se subir', ru: 'Сначала покупаешь — прибыль, если цена растёт');
  String get glTerm2 => 'Short';
  String get glDef2 => t('Sell first — profit if price falls', es: 'Vendes primero — ganas si baja', pt: 'Vende primeiro — lucra se cair', ru: 'Сначала продаёшь — прибыль, если цена падает');
  String get glTerm3 => 'Stop';
  String get glDef3 => t('Exit if wrong — protects the account', es: 'Salida si te equivocas — protege la cuenta', pt: 'Saída se errar — protege a conta', ru: 'Выход если ошибся — защищает счёт');
  String get glTerm4 => 'XP / process';
  String get glDef4 => t('League points for stop + size + no revenge — not for luck', es: 'Puntos por stop + tamaño + sin revancha — no por suerte', pt: 'Pontos por stop + tamanho + sem revanche — não por sorte', ru: 'Очки Лиги за стоп + размер + без отыгрыша — не за удачу');
  String get glTerm5 => 'Daily Desk';
  String get glDef5 => t('Today’s 4 micro-missions — close them every day', es: '4 micromisiones de hoy — ciérralas cada día', pt: '4 micromissões de hoje — feche todos os dias', ru: '4 микрозадания на сегодня — закрывай каждый день');
  String get glCta => t('Got it — back to Desk', es: 'Entendido — al Desk', pt: 'Entendi — ao Desk', ru: 'Понятно — к Desk');

  // Phase 4
  String get p4Cap => t('League week', es: 'Semana de Liga', pt: 'Semana de Liga', ru: 'Неделя Лиги');
  String get p4Title => t('Desks 8–14: climb on process', es: 'Desks 8–14: sube por proceso', pt: 'Desks 8–14: suba por processo', ru: 'Desk 8–14: поднимайся процессом');
  String get p4Body => t(
        'Free terminal is open. Every day: finish Daily Desk with a stop, then peek at League rank.',
        es: 'Terminal libre abierto. Cada día: cierra Daily Desk con stop, luego mira el rango.',
        pt: 'Terminal livre aberto. Cada dia: feche Daily Desk com stop, depois veja o rank.',
        ru: 'Свободный терминал открыт. Каждый день: закрой Daily Desk со стопом, потом глянь ранг в Лиге.',
      );
  String get p4Point1 => t('Daily strip on Desk — 4 checks', es: 'Franja Daily en Desk — 4 checks', pt: 'Faixa Daily no Desk — 4 checks', ru: 'Полоска Daily на Desk — 4 галочки');
  String get p4Point2 => t('League tab — your card & board', es: 'Pestaña Liga — tu tarjeta y tabla', pt: 'Aba Liga — seu card e placar', ru: 'Вкладка Лига — твоя карточка и таблица');
  String get p4Point3 => t('Skip revenge trades — XP hates them', es: 'Sin revancha — el XP las odia', pt: 'Sem revanche — XP odeia isso', ru: 'Без отыгрыша — XP это ненавидит');
  String get p4Coach => t('Next tap: complete today’s Daily Desk above the chart.', es: 'Siguiente: cierra el Daily Desk de hoy encima del gráfico.', pt: 'Próximo: feche o Daily Desk de hoje acima do gráfico.', ru: 'Дальше: закрой сегодняшний Daily Desk над графиком.');
  String get p4Cta => t('Open free Desk', es: 'Abrir Desk libre', pt: 'Abrir Desk livre', ru: 'Открыть свободный Desk');

  // Phase 5
  String get p5Cap => t('New skill', es: 'Nueva habilidad', pt: 'Nova habilidade', ru: 'Новый навык');
  String get p5Title => t('Short + Tape Drill', es: 'Short + Tape Drill', pt: 'Short + Tape Drill', ru: 'Short + Tape Drill');
  String get p5Body => t(
        'You held a week in League. Now learn the fade (Short) once, then train eyes on Tape Drill.',
        es: 'Aguantaste una semana en Liga. Ahora aprende el fade (Short) una vez, luego Tape Drill.',
        pt: 'Segurou uma semana na Liga. Agora aprenda o fade (Short) uma vez, depois Tape Drill.',
        ru: 'Ты неделю продержался в Лиге. Теперь один раз выучи Short (падение), потом тренируй глаз в Tape Drill.',
      );
  String get p5Point1 => t('Short = sell the rejection, stop above', es: 'Short = vende el rechazo, stop arriba', pt: 'Short = venda a rejeição, stop acima', ru: 'Short = продай отбой, стоп выше');
  String get p5Point2 => t('Tape Drill = League tab → practice tape', es: 'Tape Drill = pestaña Liga → práctica', pt: 'Tape Drill = aba Liga → prática', ru: 'Tape Drill = вкладка Лига → практика ленты');
  String get p5Point3 => t('Still finish Daily Desk every day', es: 'Sigue cerrando Daily Desk cada día', pt: 'Continue fechando Daily Desk todo dia', ru: 'Daily Desk по-прежнему каждый день');
  String get p5Coach => t('Tap below for the Short lesson — same flow as Move 1, flipped.', es: 'Toca abajo para la lección Short — mismo flujo que Mov. 1, invertido.', pt: 'Toque abaixo para a lição Short — mesmo fluxo do Mov. 1, invertido.', ru: 'Жми ниже урок Short — тот же поток, что Move 1, только наоборот.');
  String get p5CtaShort => t('Start Short lesson', es: 'Empezar lección Short', pt: 'Começar lição Short', ru: 'Начать урок Short');
  String get p5CtaLater => t('Later — open Desk', es: 'Luego — abrir Desk', pt: 'Depois — abrir Desk', ru: 'Позже — открыть Desk');

  // Phase 6
  String get p6Cap => t('Season stretch', es: 'Tramo de temporada', pt: 'Trecho da season', ru: 'Финал сезона');
  String get p6Title => t('Contest → Finals', es: 'Contest → Finals', pt: 'Contest → Finals', ru: 'Contest → Finals');
  String get p6Body => t(
        'Days 22–28. Stakes rise. Same Daily Desk — harder weight on process XP and titles.',
        es: 'Días 22–28. Sube la presión. Mismo Daily Desk — más peso en XP y títulos.',
        pt: 'Dias 22–28. Sobe a pressão. Mesmo Daily Desk — mais peso em XP e títulos.',
        ru: 'Дни 22–28. Ставки выше. Тот же Daily Desk — больше вес у XP процесса и титулов.',
      );
  String get p6Grow => t('Build streak & track', es: 'Construye racha y track', pt: 'Construa sequência e track', ru: 'Строй стрик и трек');
  String get p6Contest => t('XP multiplier up · board bites', es: 'Multiplicador XP · tabla muerde', pt: 'Multiplicador XP · placar aperta', ru: 'Множитель XP · таблица кусается');
  String get p6Finals => t('Titles lock · every desk counts', es: 'Títulos se fijan · cada desk cuenta', pt: 'Títulos travam · cada desk conta', ru: 'Титулы фиксируются · каждый desk важен');
  String get p6Coach => t('Next: open League, check season phase, then close today’s Daily.', es: 'Siguiente: abre Liga, mira la fase, cierra el Daily de hoy.', pt: 'Próximo: abra Liga, veja a fase, feche o Daily de hoje.', ru: 'Дальше: открой Лигу, глянь фазу сезона, закрой сегодняшний Daily.');
  String get p6Cta => t('To League season', es: 'A la temporada', pt: 'Para a season', ru: 'В сезон Лиги');

  // Next-step card on free terminal
  String get nsCap => t('Next step', es: 'Siguiente paso', pt: 'Próximo passo', ru: 'Следующий шаг');
  String get nsDailyTitle => t('Finish today’s Daily Desk', es: 'Cierra el Daily Desk de hoy', pt: 'Feche o Daily Desk de hoje', ru: 'Закрой сегодняшний Daily Desk');
  String get nsDailyBody => t('Four checks above the chart. Planned trade + clean stop first.', es: 'Cuatro checks encima del gráfico. Trade planeado + stop limpio primero.', pt: 'Quatro checks acima do gráfico. Trade planejado + stop limpo primeiro.', ru: 'Четыре галочки над графиком. Сначала плановая сделка + чистый стоп.');
  String get nsDailyCta => t('How: look at Daily strip', es: 'Cómo: mira la franja Daily', pt: 'Como: olhe a faixa Daily', ru: 'Как: смотри полоску Daily');
  String get nsDailyHint => t('Daily Desk is the strip right under the header — tick the boxes with a planned trade + stop.', es: 'Daily Desk es la franja bajo el header — márcala con trade + stop.', pt: 'Daily Desk é a faixa sob o header — marque com trade + stop.', ru: 'Daily Desk — полоска сразу под шапкой. Галочки: плановая сделка + стоп.');
  String get nsLeagueTitle => t('Open League once', es: 'Abre Liga una vez', pt: 'Abra Liga uma vez', ru: 'Открой Лигу один раз');
  String get nsLeagueBody => t('Read your card and how XP moves — then back to Desk.', es: 'Lee tu tarjeta y cómo mueve el XP — luego vuelve.', pt: 'Leia seu card e como o XP move — depois volte.', ru: 'Прочитай свою карточку и как двигается XP — потом снова Desk.');
  String get nsLeagueCta => t('Go to League tab', es: 'Ir a Liga', pt: 'Ir à Liga', ru: 'Во вкладку Лига');
  String get nsShortTitle => t('Short lesson waiting', es: 'Lección Short pendiente', pt: 'Lição Short pendente', ru: 'Ждёт урок Short');
  String get nsShortBody => t('One guided fade — sell line, stop above. Same risk 1%.', es: 'Un fade guiado — línea de venta, stop arriba. Riesgo 1%.', pt: 'Um fade guiado — linha de venda, stop acima. Risco 1%.', ru: 'Один guided fade — линия ПРОДАЙ, стоп выше. Риск 1%.');
  String get nsShortCta => t('Start Short lesson', es: 'Empezar Short', pt: 'Começar Short', ru: 'Начать урок Short');
  String get nsDrillTitle => t('Tape Drill in League', es: 'Tape Drill en Liga', pt: 'Tape Drill na Liga', ru: 'Tape Drill в Лиге');
  String get nsDrillBody => t('Train reading the tape — process points, not PnL.', es: 'Entrena leer el tape — puntos de proceso, no PnL.', pt: 'Treine ler o tape — pontos de processo, não PnL.', ru: 'Тренируй чтение ленты — очки процесса, не PnL.');
  String get nsDrillCta => t('Open Tape Drill', es: 'Abrir Tape Drill', pt: 'Abrir Tape Drill', ru: 'Открыть Tape Drill');
  String get nsSeasonTitle => t('Season grind', es: 'Grind de temporada', pt: 'Grind da season', ru: 'Гринд сезона');
  String get nsSeasonBody => t('Contest/Finals — every Daily Desk weights titles. Check League phase.', es: 'Contest/Finals — cada Daily pesa títulos. Mira la fase en Liga.', pt: 'Contest/Finals — cada Daily pesa títulos. Veja a fase na Liga.', ru: 'Contest/Finals — каждый Daily весит на титулы. Глянь фазу в Лиге.');
  String get nsSeasonCta => t('Open League', es: 'Abrir Liga', pt: 'Abrir Liga', ru: 'Открыть Лигу');
  String get nsDoneTitle => t('Day clear — optional League peek', es: 'Día limpio — mira Liga si quieres', pt: 'Dia limpo — olhe a Liga se quiser', ru: 'День закрыт — можно глянуть Лигу');
  String get nsDoneBody => t('Come back tomorrow. Streak and board wait.', es: 'Vuelve mañana. Racha y tabla esperan.', pt: 'Volte amanhã. Sequência e placar esperam.', ru: 'Возвращайся завтра. Стрик и таблица ждут.');
  String get nsDoneCta => t('Peek League', es: 'Mirar Liga', pt: 'Olhar Liga', ru: 'Глянуть Лигу');

  // Journey roadmap
  String get jmTitle => t('Your path', es: 'Tu ruta', pt: 'Sua trilha', ru: 'Твой путь');
  String jmStage(int i) => switch (i) {
        0 => t('Basics · 4 missions', es: 'Base · 4 misiones', pt: 'Base · 4 missões', ru: 'Основы · 4 миссии'),
        1 => t('Move 1 · bounce', es: 'Mov. 1 · rebote', pt: 'Mov. 1 · bounce', ru: 'Движение 1 · отскок'),
        2 => t('Habit week · 7 desks', es: 'Semana de hábito · 7 desks', pt: 'Semana de hábito · 7 desks', ru: 'Неделя привычки · 7 desk'),
        3 => t('League week', es: 'Semana de Liga', pt: 'Semana de Liga', ru: 'Неделя Лиги'),
        4 => t('Drills · Short practice', es: 'Drills · Short', pt: 'Drills · Short', ru: 'Дриллы · практика Short'),
        _ => t('Season · 28 days', es: 'Temporada · 28 días', pt: 'Season · 28 dias', ru: 'Сезон · 28 дней'),
      };
  String jmUnlock(int i) => switch (i) {
        0 => t('candle → Long → stop → recap', es: 'vela → Long → stop → recap', pt: 'candle → Long → stop → recap', ru: 'свеча → Long → стоп → разбор'),
        1 => t('replay → paper trade', es: 'replay → operación en papel', pt: 'replay → operação no papel', ru: 'реплей → сделка на бумаге'),
        2 => t('day 3: TG club invite · day 7: League', es: 'día 3: invite TG · día 7: Liga', pt: 'dia 3: convite TG · dia 7: Liga', ru: 'день 3: инвайт в TG · день 7: Лига'),
        3 => t('desks 8–14 · rank on process XP', es: 'desks 8–14 · rango por XP', pt: 'desks 8–14 · rank por XP', ru: 'desk 8–14 · ранг за XP процесса'),
        4 => t('desks 15–21 · Tape Drill + cautious Short', es: 'desks 15–21 · Tape Drill + Short', pt: 'desks 15–21 · Tape Drill + Short', ru: 'desk 15–21 · Tape Drill + осторожный Short'),
        _ => t('desks 22–28 · season finale + titles', es: 'desks 22–28 · final + títulos', pt: 'desks 22–28 · final + títulos', ru: 'desk 22–28 · финал сезона + титулы'),
      };

  String _ruDays(int n) {
    final m10 = n % 10;
    final m100 = n % 100;
    if (m10 == 1 && m100 != 11) return 'день';
    if (m10 >= 2 && m10 <= 4 && (m100 < 12 || m100 > 14)) return 'дня';
    return 'дней';
  }

  /// 1 сделка / 2 сделки / 5 сделок
  String _ruTrades(int n) {
    final m10 = n % 10;
    final m100 = n % 100;
    if (m10 == 1 && m100 != 11) return 'сделка';
    if (m10 >= 2 && m10 <= 4 && (m100 < 12 || m100 > 14)) return 'сделки';
    return 'сделок';
  }
}
