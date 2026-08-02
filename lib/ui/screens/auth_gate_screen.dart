import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/services/desk_audio.dart';
import 'package:paper_league/state/auth_controller.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key, required this.onReady});
  final VoidCallback onReady;

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _nick = TextEditingController(text: 'desk');
  bool _signup = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _nick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final s = S.of(context);

    return Scaffold(
      backgroundColor: PlColors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            Text(
              'PAPER LEAGUE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: PlColors.accent,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 12),
            Text(s.authTitle, style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              auth.onlineConfigured ? s.authSubOnline : s.authSubDemo,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _nick,
              maxLength: 18,
              style: const TextStyle(color: PlColors.text),
              decoration: InputDecoration(
                labelText: S.of(context).nicknameField,
                counterText: '',
                filled: true,
                fillColor: PlColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(PlRadius.md)),
              ),
            ),
            const SizedBox(height: 12),
            if (auth.onlineConfigured) ...[
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: PlColors.text),
                decoration: InputDecoration(
                  labelText: s.email,
                  filled: true,
                  fillColor: PlColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(PlRadius.md)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                style: const TextStyle(color: PlColors.text),
                decoration: InputDecoration(
                  labelText: s.password,
                  filled: true,
                  fillColor: PlColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(PlRadius.md)),
                ),
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 10),
                Text(auth.error!, style: const TextStyle(color: PlColors.bear, fontSize: 12)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: auth.busy
                    ? null
                    : () async {
                        DeskAudio.instance.play(DeskSfx.tap);
                        HapticFeedback.mediumImpact();
                        if (_signup) {
                          await auth.signUpEmail(_email.text, _password.text, nickname: _nick.text.trim());
                        } else {
                          await auth.signInEmail(_email.text, _password.text);
                        }
                        if (auth.phase == AuthPhase.ready && context.mounted) {
                          final desk = context.read<DeskController>();
                          final nick = _nick.text.trim();
                          if (nick.length >= 2) await desk.setNickname(nick);
                          widget.onReady();
                        }
                      },
                child: Text(_signup ? s.signUp : s.signIn),
              ),
              TextButton(
                onPressed: () => setState(() => _signup = !_signup),
                child: Text(_signup ? s.haveAccount : s.needAccount),
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton(
              onPressed: auth.busy
                  ? null
                    : () async {
                      DeskAudio.instance.play(DeskSfx.tap);
                      await auth.continueAsGuest();
                      if (context.mounted) {
                        final desk = context.read<DeskController>();
                        final nick = _nick.text.trim();
                        if (nick.length >= 2) await desk.setNickname(nick);
                        if (auth.mode == OnlineMode.localApi) {
                          await auth.local.upsertProfile(nickname: desk.nickname, hue: desk.avatarHue);
                        }
                        widget.onReady();
                      }
                    },
              child: Text(s.continueGuest),
            ),
            const SizedBox(height: 16),
            Text(
              s.authFootnote,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
