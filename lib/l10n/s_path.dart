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
        'You copied the bounce for $days days',
        es: 'Copiaste el rebote durante $days días',
        pt: 'Você copiou o bounce por $days dias',
        ru: 'Ты $days ${_ruDays(days)} копировал отскок',
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
        'Watch the replay → copy on paper → set stop → close',
        es: 'Miras el replay → copias en papel → pones stop → cierras',
        pt: 'Assiste o replay → copia no papel → coloca stop → fecha',
        ru: 'Смотришь реплей → повторяешь на бумаге → ставишь стоп → закрываешь',
      );
  String get bridgeCta => t(
        'Watch the move',
        es: 'Ver el movimiento',
        pt: 'Ver o movimento',
        ru: 'Смотреть движение',
      );
  String get bridgeLockBook => t(
        'Journal · opens after the first copy',
        es: 'Diario · se abre tras la primera copia',
        pt: 'Diário · abre após a primeira cópia',
        ru: 'Журнал · откроется после первой копии',
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
        'Copy on paper',
        es: 'Copiar en papel',
        pt: 'Copiar no papel',
        ru: 'Повторить на бумаге',
      );
  String get moveCopyLabel => t(
        'Copy · move 1',
        es: 'Copia · movimiento 1',
        pt: 'Cópia · movimento 1',
        ru: 'Копия · движение 1',
      );
  String get moveCopyCoach => t(
        'Tap Buy · Long when price is near this line again. The stop will sit below — like in the replay.',
        es: 'Pulsa Buy · Long cuando el precio esté cerca de esta línea. El stop irá debajo — como en el replay.',
        pt: 'Toque Buy · Long quando o preço estiver perto desta linha. O stop fica abaixo — como no replay.',
        ru: 'Жми Buy · Long, когда цена снова у этой линии. Стоп система поставит ниже — как в реплее.',
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
        'Copy done',
        es: 'Copia hecha',
        pt: 'Cópia feita',
        ru: 'Копия готова',
      );
  String get moveCopyDoneBody => t(
        'You repeated the bounce on paper. Tomorrow — the same move. On day 3 we show it live.',
        es: 'Repetiste el rebote en papel. Mañana — el mismo movimiento. El día 3 lo mostramos en vivo.',
        pt: 'Você repetiu o bounce no papel. Amanhã — o mesmo movimento. No dia 3 mostramos ao vivo.',
        ru: 'Ты повторил отскок на бумаге. Завтра — то же движение. На 3-й день покажем live.',
      );
  String get moveToToday => t(
        'Go to Today',
        es: 'Ir a Hoy',
        pt: 'Ir para Hoje',
        ru: 'К экрану Сегодня',
      );

  String get todayCap => t('Today', es: 'Hoy', pt: 'Hoje', ru: 'Сегодня');
  String todayDayCap(String weekday, int day) => t(
        '$weekday · day $day',
        es: '$weekday · día $day',
        pt: '$weekday · dia $day',
        ru: '$weekday · день $day',
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
        'Each copy with a 1% stop',
        es: 'Cada copia con stop del 1%',
        pt: 'Cada cópia com stop de 1%',
        ru: 'Каждая копия — со стопом 1%',
      );
  String get todayTask3 => t(
        'Short recap at the end',
        es: 'Un recap corto al final',
        pt: 'Um recap curto no fim',
        ru: 'Короткий разбор в конце',
      );
  String get todayStart => t(
        'Start today',
        es: 'Empezar hoy',
        pt: 'Começar hoje',
        ru: 'Начать сегодня',
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
        'Desk Club live',
        es: 'Desk Club live',
        pt: 'Desk Club live',
        ru: 'Desk Club live',
      );
  String get todayClubLockedSub => t(
        'Opens on streak day 3',
        es: 'Se abre el día 3 de racha',
        pt: 'Abre no dia 3 da sequência',
        ru: 'Откроется на 3-й день серии',
      );
  String get todayNeedMove => t(
        'First copy the move — then Daily Desk opens fully',
        es: 'Primero copia el movimiento — luego se abre el Daily Desk',
        pt: 'Primeiro copie o movimento — depois o Daily Desk abre',
        ru: 'Сначала скопируй движение — потом откроется Daily Desk',
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
        'Journal opens after your first move copy',
        es: 'El diario se abre tras tu primera copia',
        pt: 'O diário abre após sua primeira cópia',
        ru: 'Журнал откроется после первой копии движения',
      );
  String get leagueLockedHint => t(
        'League opens after 7 days of discipline',
        es: 'La liga se abre tras 7 días de disciplina',
        pt: 'A liga abre após 7 dias de disciplina',
        ru: 'Лига откроется после 7 дней дисциплины',
      );

  String _ruDays(int n) {
    final m10 = n % 10;
    final m100 = n % 100;
    if (m10 == 1 && m100 != 11) return 'день';
    if (m10 >= 2 && m10 <= 4 && (m100 < 12 || m100 > 14)) return 'дня';
    return 'дней';
  }
}
