import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/services/desk_audio.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/screens/desk_screen.dart';
import 'package:paper_league/ui/screens/league_screen.dart';
import 'package:paper_league/ui/screens/positions_screen.dart';
import 'package:paper_league/ui/screens/profile_screen.dart';
import 'package:paper_league/ui/widgets/achievements.dart';
import 'package:paper_league/ui/widgets/recap_share_card.dart';
import 'package:paper_league/ui/widgets/recap_sheet.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;
  DeskController? _desk;
  bool _recapOpen = false;
  bool _achBusy = false;

  static const _pages = [
    DeskScreen(),
    PositionsScreen(),
    LeagueScreen(),
    ProfileScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final desk = context.read<DeskController>();
    if (!identical(_desk, desk)) {
      _desk?.removeListener(_onDesk);
      _desk = desk;
      _desk!.addListener(_onDesk);
    }
  }

  @override
  void dispose() {
    _desk?.removeListener(_onDesk);
    super.dispose();
  }

  void _onDesk() {
    final desk = _desk;
    if (desk == null || !mounted) return;

    final trade = desk.lastRecap;
    if (trade != null && !_recapOpen) {
      desk.consumeRecap();
      _recapOpen = true;
      HapticFeedback.heavyImpact();
      showRecapSheet(context, trade).whenComplete(() async {
        if (!mounted) return;
        _recapOpen = false;
        await _flushAchievements();
        if (!mounted) return;
        await _offerShareRitual();
      });
      return;
    }

    if (!_recapOpen && desk.pendingAchievements.isNotEmpty) {
      _flushAchievements();
    }
  }

  Future<void> _offerShareRitual() async {
    final desk = _desk;
    if (desk == null || !mounted) return;
    final trade = desk.consumeShareRitual();
    if (trade == null) return;
    final s = S.of(context);
    final share = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PlColors.surface,
        title: Text(s.shareRitualTitle),
        content: Text(s.shareRitualBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.skip)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.shareRecap),
          ),
        ],
      ),
    );
    if (share == true && mounted) {
      await shareRecapCard(context, trade: trade, nickname: desk.nickname);
      await desk.markDailyShare();
      DeskAudio.instance.play(DeskSfx.win);
    }
  }

  Future<void> _flushAchievements() async {
    final desk = _desk;
    if (desk == null || _achBusy || !mounted) return;
    final keys = desk.consumeAchievements();
    if (keys.isEmpty) return;
    _achBusy = true;
    try {
      await showAchievementToasts(context, keys);
    } finally {
      _achBusy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final unlocked = context.select((DeskController d) => d.tabsUnlocked);
    return Scaffold(
      backgroundColor: PlColors.bg,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _index,
          children: _pages,
        ),
      ),
      bottomNavigationBar: _TerminalNav(
        index: _index,
        labels: [s.desk, s.book, s.league, s.you],
        hints: [null, s.navBookHint, s.navLeagueHint, s.navYouHint],
        unlocked: unlocked,
        onSelect: (i) {
          if (i == _index) return;
          if (!unlocked && i != 0) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.tabsLocked)));
            return;
          }
          DeskAudio.instance.play(DeskSfx.tap);
          HapticFeedback.selectionClick();
          setState(() => _index = i);
        },
      ),
    );
  }
}

class _TerminalNav extends StatelessWidget {
  const _TerminalNav({
    required this.index,
    required this.labels,
    required this.onSelect,
    this.hints = const [],
    this.unlocked = true,
  });

  final int index;
  final List<String> labels;
  final List<String?> hints;
  final bool unlocked;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.show_chart_rounded, labels[0]),
      (Icons.layers_rounded, labels[1]),
      (Icons.military_tech_rounded, labels[2]),
      (Icons.person_rounded, labels[3]),
    ];

    return Container(
      decoration: BoxDecoration(
        color: PlColors.bgElevated,
        border: const Border(top: BorderSide(color: PlColors.lineSoft)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
          child: Row(
            children: List.generate(items.length, (i) {
              final on = index == i;
              final item = items[i];
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(PlRadius.md),
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: PlMotion.micro,
                    curve: PlMotion.curveToggle,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: on ? PlColors.accentSoft : Colors.transparent,
                      borderRadius: BorderRadius.circular(PlRadius.md),
                      border: Border.all(
                        color: on ? PlColors.accent.withValues(alpha: 0.35) : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: on ? 1.08 : 1,
                          duration: PlMotion.micro,
                          child: Icon(
                            (!unlocked && i != 0) ? Icons.lock_outline : item.$1,
                            size: 22,
                            color: on ? PlColors.accent : PlColors.faint,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          (!unlocked && i != 0 && hints.length > i && hints[i] != null)
                              ? hints[i]!
                              : item.$2,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: on ? FontWeight.w800 : FontWeight.w500,
                            letterSpacing: on ? 0.3 : 0,
                            color: on ? PlColors.accent : PlColors.faint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
