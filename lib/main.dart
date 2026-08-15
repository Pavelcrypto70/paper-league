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
import 'package:paper_league/ui/screens/auth_gate_screen.dart';
import 'package:paper_league/ui/screens/language_gate_screen.dart';
import 'package:paper_league/ui/screens/legal_gate_screen.dart';
import 'package:paper_league/ui/screens/shell_screen.dart';
import 'package:paper_league/ui/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  bool _splashDone = false;
  bool _onlineBound = false;

  Future<void> _bindIfNeeded() async {
    if (_onlineBound) return;
    final auth = context.read<AuthController>();
    final desk = context.read<DeskController>();
    if (auth.phase != AuthPhase.ready && auth.phase != AuthPhase.needsGate) {
      return;
    }
    if (auth.phase == AuthPhase.ready) {
      _onlineBound = true;
      await desk.bindOnline(
        auth.league,
        live: auth.onlineConfigured && auth.isSignedIn,
      );
    }
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

    if (!locale.languageChosen) {
      return LanguageGateScreen(
        onPick: context.read<LocaleController>().chooseLanguage,
      );
    }

    if (!locale.disclaimerAccepted) {
      return const LegalGateScreen();
    }

    if (!_splashDone) {
      return SplashScreen(
        onDone: () async {
          setState(() => _splashDone = true);
        },
      );
    }

    if (auth.phase == AuthPhase.booting) {
      return const Scaffold(
        backgroundColor: PlColors.bg,
        body: Center(child: CircularProgressIndicator(color: PlColors.accent)),
      );
    }

    if (auth.phase == AuthPhase.needsGate) {
      return AuthGateScreen(
        onReady: () async {
          await context.read<DeskController>().bindOnline(
            context.read<AuthController>().league,
            live:
                context.read<AuthController>().onlineConfigured &&
                context.read<AuthController>().isSignedIn,
          );
          setState(() => _onlineBound = true);
        },
      );
    }

    // Ready
    if (!_onlineBound) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _bindIfNeeded());
    }
    return const ShellScreen();
  }
}
