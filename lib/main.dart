import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/services/analytics.dart';
import 'package:paper_league/state/auth_controller.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/theme.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/screens/language_gate_screen.dart';
import 'package:paper_league/ui/screens/legal_gate_screen.dart';
import 'package:paper_league/ui/screens/shell_screen.dart';
import 'package:paper_league/ui/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DeskController.wipeLocalProgressIfNeeded();
  await DeskController.applyQaPreset(Uri.base.queryParameters['qa']);
  await Analytics.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: PlColors.bgElevated,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const PaperLeagueApp());
}

class PaperLeagueApp extends StatelessWidget {
  const PaperLeagueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleController()..load()),
        ChangeNotifierProvider(create: (_) => AuthController()..bootstrap()),
        ChangeNotifierProvider(create: (_) => DeskController()..bootstrap()),
      ],
      child: Consumer<LocaleController>(
        builder: (context, loc, _) {
          return MaterialApp(
            title: 'Paper League',
            debugShowCheckedModeBanner: false,
            theme: buildPaperLeagueTheme(),
            locale: loc.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('es'),
              Locale('pt'),
              Locale('ru'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const _Root(),
          );
        },
      ),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  /// QA presets (`?qa=…`) skip the promise splash — Flutter web automation
  /// cannot reliably click canvas buttons.
  bool _splashDone = Uri.base.queryParameters.containsKey('qa');
  bool _onlineBound = false;
  bool _autoGuestStarted = false;

  Future<void> _bindIfNeeded() async {
    if (_onlineBound) return;
    final auth = context.read<AuthController>();
    final desk = context.read<DeskController>();
    if (auth.phase != AuthPhase.ready) return;
    _onlineBound = true;
    await desk.bindOnline(
      auth.league,
      live: auth.onlineConfigured && auth.isSignedIn,
    );
  }

  Future<void> _autoGuestIfNeeded() async {
    if (_autoGuestStarted) return;
    final auth = context.read<AuthController>();
    if (auth.phase != AuthPhase.needsGate) return;
    _autoGuestStarted = true;
    await auth.continueAsGuest();
    if (!mounted) return;
    await _bindIfNeeded();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final auth = context.watch<AuthController>();

    // Do not reveal splash (or its previous locale) until stored language
    // choice has been loaded.
    if (!locale.ready) {
      return const Scaffold(
        backgroundColor: PlColors.bg,
        body: Center(child: CircularProgressIndicator(color: PlColors.accent)),
      );
    }

    // 1) Language
    if (!locale.languageChosen) {
      return LanguageGateScreen(
        onPick: context.read<LocaleController>().chooseLanguage,
      );
    }

    // 2) Promise (splash) before legal
    if (!_splashDone) {
      return SplashScreen(
        onDone: () async {
          await Analytics.log('promise_seen');
          if (!mounted) return;
          setState(() => _splashDone = true);
        },
      );
    }

    // 3) Legal
    if (!locale.disclaimerAccepted) {
      return const LegalGateScreen();
    }

    if (auth.phase == AuthPhase.booting) {
      return const Scaffold(
        backgroundColor: PlColors.bg,
        body: Center(child: CircularProgressIndicator(color: PlColors.accent)),
      );
    }

    // 4) Auto-guest — never block cold start on AuthGate
    if (auth.phase == AuthPhase.needsGate) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _autoGuestIfNeeded());
      return const Scaffold(
        backgroundColor: PlColors.bg,
        body: Center(child: CircularProgressIndicator(color: PlColors.accent)),
      );
    }

    // 5) Shell
    if (!_onlineBound) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _bindIfNeeded());
    }
    return const ShellScreen();
  }
}
