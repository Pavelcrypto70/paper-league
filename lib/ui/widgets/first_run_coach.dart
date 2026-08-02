import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/services/desk_audio.dart';
import 'package:paper_league/theme/tokens.dart';

/// 3-step first-run coach before the first stop trade.
Future<void> showFirstRunCoach(BuildContext context) async {
  final s = S.of(context);
  final pages = [
    (s.firstRunStep1Title, s.firstRunStep1Body),
    (s.firstRunStep2Title, s.firstRunStep2Body),
    (s.firstRunStep3Title, s.firstRunStep3Body),
  ];
  var i = 0;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: PlColors.surface,
    isDismissible: false,
    enableDrag: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final page = pages[i];
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + MediaQuery.viewInsetsOf(ctx).bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: PlColors.line, borderRadius: BorderRadius.circular(99)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('${i + 1}/3', style: Theme.of(ctx).textTheme.labelSmall),
                const SizedBox(height: 8),
                Text(page.$1, style: Theme.of(ctx).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(page.$2, style: Theme.of(ctx).textTheme.bodyMedium),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    DeskAudio.instance.play(DeskSfx.tap);
                    HapticFeedback.selectionClick();
                    if (i >= pages.length - 1) {
                      Navigator.pop(ctx);
                    } else {
                      setState(() => i++);
                    }
                  },
                  child: Text(i >= pages.length - 1 ? s.firstRunCta : s.guideNext),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
