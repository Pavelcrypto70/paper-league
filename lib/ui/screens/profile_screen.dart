import 'package:paper_league/config/app_links.dart';
import 'package:paper_league/services/analytics.dart';
import 'package:paper_league/services/desk_audio.dart';
import 'package:paper_league/state/auth_controller.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/format.dart';
import 'package:paper_league/ui/screens/guide_screen.dart';
import 'package:paper_league/ui/widgets/achievements.dart';
import 'package:paper_league/ui/widgets/equity_sparkline.dart';
import 'package:paper_league/ui/widgets/pl_chrome.dart';
import 'package:paper_league/ui/widgets/recap_sheet.dart';
import 'package:paper_league/ui/widgets/upgrade_shop.dart';
import 'package:paper_league/ui/widgets/weekly_report_sheet.dart';
import 'package:paper_league/ui/screens/tape_drill_screen.dart';
import 'package:paper_league/ui/widgets/playbooks_sheet.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nick;

  @override
  void initState() {
    super.initState();
    _nick = TextEditingController(
      text: context.read<DeskController>().nickname,
    );
  }

  @override
  void dispose() {
    _nick.dispose();
    super.dispose();
  }

  Future<void> _photo(DeskController desk) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (file != null) {
      await desk.setAvatarPath(file.path);
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final desk = context.watch<DeskController>();
    final loc = context.watch<LocaleController>();
    final s = S.of(context);
    final retColor = desk.returnFromStartPct >= 0
        ? PlColors.bull
        : PlColors.bear;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text(s.profile, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(s.profileSub, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  DeskAudio.instance.play(DeskSfx.tap);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const TapeDrillScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.slow_motion_video_rounded, size: 18),
                label: Text(s.tapeDrill),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  DeskAudio.instance.play(DeskSfx.tap);
                  showPlaybooksSheet(context);
                },
                icon: const Icon(Icons.bookmark_added_outlined, size: 18),
                label: Text(s.playbooks),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Material(
          color: PlColors.accentDim,
          borderRadius: BorderRadius.circular(PlRadius.md),
          child: InkWell(
            borderRadius: BorderRadius.circular(PlRadius.md),
            onTap: () {
              DeskAudio.instance.play(DeskSfx.tap);
              openGuide(context);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PlRadius.md),
                border: Border.all(
                  color: PlColors.accent.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: PlColors.accentSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: PlColors.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.guideTitle,
                          style: const TextStyle(
                            color: PlColors.accent,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.guideCta,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: PlColors.accent,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: PlColors.accentDim,
          borderRadius: BorderRadius.circular(PlRadius.md),
          child: InkWell(
            borderRadius: BorderRadius.circular(PlRadius.md),
            onTap: () async {
              DeskAudio.instance.play(DeskSfx.tap);
              await Analytics.log('tg_cta_tap', {
                'source': AppLinks.communitySource,
                'url': AppLinks.communityUrl,
              });
              final uri = Uri.parse(AppLinks.communityUrl);
              final ok = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(s.communityOpenError)));
              }
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PlRadius.md),
                border: Border.all(
                  color: PlColors.accent.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: PlColors.accentSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.forum_outlined,
                      color: PlColors.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.joinCommunity,
                          style: const TextStyle(
                            color: PlColors.accent,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.joinCommunityBody,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppLinks.communityHandle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: PlColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.open_in_new_rounded,
                    color: PlColors.accent,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: PlColors.surface,
          borderRadius: BorderRadius.circular(PlRadius.md),
          child: InkWell(
            borderRadius: BorderRadius.circular(PlRadius.md),
            onTap: () {
              DeskAudio.instance.play(DeskSfx.tap);
              showWeeklyReportSheet(context);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PlRadius.md),
                border: Border.all(color: PlColors.lineSoft),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: PlColors.surface2,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      color: PlColors.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.weeklyReport,
                          style: const TextStyle(
                            color: PlColors.text,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.weeklyReportCta,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: PlColors.muted,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        PlSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.language, style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final language in AppLang.values)
                    _LangChip(
                      label: language.nativeLabel,
                      on: loc.lang == language,
                      onTap: () => loc.setCode(language.code),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => loc.resetLanguageChoice(),
                icon: const Icon(Icons.restart_alt_rounded, size: 18),
                label: Text(
                  s.t(
                    'Choose language from start',
                    es: 'Elegir idioma desde el inicio',
                    pt: 'Escolher idioma desde o início',
                    ru: 'Выбрать язык с начала',
                  ),
                ),
              ),
              TextButton(
                onPressed: () => launchUrl(
                  Uri.parse(AppLinks.privacyUrl),
                  mode: LaunchMode.externalApplication,
                ),
                child: Text(s.privacyPolicy),
              ),
              TextButton(
                onPressed: () => launchUrl(
                  Uri.parse(AppLinks.termsUrl),
                  mode: LaunchMode.externalApplication,
                ),
                child: Text(s.termsOfService),
              ),
              Consumer<AuthController>(
                builder: (context, auth, _) {
                  if (!auth.onlineConfigured || !auth.isAnonymous) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: OutlinedButton(
                      onPressed: () async {
                        DeskAudio.instance.play(DeskSfx.tap);
                        final email = TextEditingController();
                        final pass = TextEditingController();
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: PlColors.surface,
                            title: Text(s.upgradeAccount),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: email,
                                  decoration: InputDecoration(
                                    labelText: s.email,
                                  ),
                                ),
                                TextField(
                                  controller: pass,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: s.password,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(s.back),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(s.signUp),
                              ),
                            ],
                          ),
                        );
                        if (ok == true && context.mounted) {
                          await auth.signUpEmail(
                            email.text,
                            pass.text,
                            nickname: desk.nickname,
                          );
                        }
                      },
                      child: Text(s.upgradeAccount),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PlSurface(
          accentBorder: true,
          child: Row(
            children: [
              PlAvatar(
                nickname: desk.nickname,
                hue: desk.avatarHue,
                path: desk.avatarPath,
                size: 72,
                onTap: () => _photo(desk),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nick,
                      maxLength: 18,
                      style: Theme.of(context).textTheme.titleLarge,
                      decoration: InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        isDense: true,
                        hintText: s.nicknameField,
                      ),
                      onChanged: (v) {
                        if (v.trim().length >= 2) desk.setNickname(v);
                      },
                    ),
                    Text(
                      s.tapPhoto,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [188, 152, 28, 340, 210].map((h) {
                        final on = desk.avatarHue == h;
                        return GestureDetector(
                          onTap: () => desk.setAvatarHue(h),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: HSLColor.fromAHSL(
                                1,
                                h.toDouble(),
                                0.55,
                                0.42,
                              ).toColor(),
                              border: Border.all(
                                color: on ? PlColors.text : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PlSurface(
          gradient: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    s.equityCurve,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const Spacer(),
                  Text(
                    money(desk.equity),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              EquitySparkline(values: desk.equityCurve),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.5,
          children: [
            PlStatTile(
              label: s.trades,
              value: '${desk.tradesCount}',
              sub: '${desk.winsCount}W / ${desk.lossesCount}L',
            ),
            PlStatTile(
              label: s.winRate,
              value: '${desk.winRatePct.toStringAsFixed(1)}%',
              color: PlColors.bull,
              sub: s.ofClosed,
            ),
            PlStatTile(
              label: s.lossRate,
              value: '${desk.lossRatePct.toStringAsFixed(1)}%',
              color: PlColors.bear,
              sub: s.ofClosed,
            ),
            PlStatTile(
              label: s.fromStart,
              value: pctPoints(desk.returnFromStartPct),
              color: retColor,
              sub: s.vsStart,
            ),
          ],
        ),
        const SizedBox(height: 12),
        PlSurface(
          child: Column(
            children: [
              _row(context, s.discipline, '${desk.discipline}'),
              _row(context, S.of(context).avgR, desk.avgR.toStringAsFixed(2)),
              _row(context, s.maxDd, pctPoints(-desk.maxDrawdown)),
              _row(context, s.league, desk.leagueScore.toStringAsFixed(1)),
              _row(context, s.credits, '${desk.meta.credits}'),
              _row(context, s.streakLabel, '${desk.meta.loginStreak}'),
              _row(context, s.shields, '${desk.seasonProgress.streakShields}'),
              _row(context, 'SP', '${desk.seasonProgress.seasonXp}'),
              _row(
                context,
                '${s.season} ${desk.season.number}',
                '#${desk.yourRank} · ${desk.season.phaseLabel(s.isRu)}',
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            DeskAudio.instance.play(DeskSfx.tap);
            showUpgradeShop(context);
          },
          child: Text(s.upgradeShop),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () async {
            DeskAudio.instance.play(DeskSfx.tap);
            final text = await Analytics.exportText();
            await SharePlus.instance.share(ShareParams(text: text));
          },
          child: Text(s.exportTelemetry),
        ),
        const SizedBox(height: 20),
        AchievementsGrid(unlocked: desk.unlockedAchievements),
        const SizedBox(height: 20),
        Text(s.journal, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (desk.history.isEmpty)
          Text(s.noTrades, style: Theme.of(context).textTheme.bodySmall)
        else
          ...desk.history.take(10).map((t) {
            final c = t.pnl >= 0 ? PlColors.bull : PlColors.bear;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () => showRecapSheet(context, t),
              title: Text('${t.symbol} ${t.side.name.toUpperCase()}'),
              subtitle: Text(
                money(t.pnl),
                style: TextStyle(color: c, fontSize: 12),
              ),
              trailing: Text(
                '${t.rMultiple >= 0 ? '+' : ''}${t.rMultiple.toStringAsFixed(2)}R',
                style: TextStyle(color: c, fontWeight: FontWeight.w700),
              ),
            );
          }),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) {
                final ds = S.of(ctx);
                return AlertDialog(
                  backgroundColor: PlColors.surface,
                  title: Text(ds.resetTitle),
                  content: Text(ds.resetBody),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(ds.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(
                        ds.reset,
                        style: const TextStyle(color: PlColors.bear),
                      ),
                    ),
                  ],
                );
              },
            );
            if (ok == true) await desk.resetAccount();
          },
          style: OutlinedButton.styleFrom(foregroundColor: PlColors.bear),
          child: Text(s.resetAccount),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, String k, String v, {bool last = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Row(
        children: [
          Expanded(
            child: Text(k, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(v, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: on ? PlColors.accentSoft : PlColors.surface2,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: on ? PlColors.accent : PlColors.lineSoft),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: on ? PlColors.accent : PlColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
