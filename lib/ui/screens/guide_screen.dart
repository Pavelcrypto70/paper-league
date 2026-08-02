import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/services/desk_audio.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/guide/guide_mocks.dart';
import 'package:paper_league/ui/guide/guide_slides.dart';

Future<void> openGuide(BuildContext context) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (_, a, _) => const GuideScreen(),
      transitionsBuilder: (_, a, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: PlMotion.curveIn),
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
                .animate(CurvedAnimation(parent: a, curve: PlMotion.curveIn)),
            child: child,
          ),
        );
      },
      transitionDuration: PlMotion.standard,
    ),
  );
}

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final _page = PageController();
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _go(int i) {
    DeskAudio.instance.play(DeskSfx.tap);
    HapticFeedback.selectionClick();
    _page.animateToPage(
      i,
      duration: PlMotion.standard,
      curve: PlMotion.curveIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final slides = buildGuideSlides(ru: s.isRu);
    final last = _index >= slides.length - 1;

    return Scaffold(
      backgroundColor: PlColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: PlColors.muted),
                  ),
                  Text(
                    s.guideTitle,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: PlColors.accent,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '${_index + 1} / ${slides.length}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: PlColors.faint),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final slide = slides[i];
                  return _SlidePage(slide: slide, ru: s.isRu);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: List.generate(slides.length, (i) {
                  final on = i == _index;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: PlMotion.micro,
                      height: 3,
                      margin: EdgeInsets.only(right: i == slides.length - 1 ? 0 : 4),
                      decoration: BoxDecoration(
                        color: on ? PlColors.accent : PlColors.lineSoft,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  if (_index > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _go(_index - 1),
                        child: Text(s.guideBack),
                      ),
                    )
                  else
                    const Spacer(),
                  if (_index > 0) const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: PlColors.accent,
                        foregroundColor: PlColors.onAccent,
                      ),
                      onPressed: () {
                        if (last) {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context);
                        } else {
                          _go(_index + 1);
                        }
                      },
                      child: Text(last ? s.guideDone : s.guideNext),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  const _SlidePage({required this.slide, required this.ru});
  final GuideSlide slide;
  final bool ru;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;

    final visual = GuideMockFrame(kind: slide.mock, ru: ru);
    final copy = _CopyColumn(slide: slide);

    if (wide) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(28, 8, 28, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 5, child: Center(child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: visual,
            ))),
            const SizedBox(width: 28),
            Expanded(flex: 6, child: copy),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300, maxHeight: 380),
            child: visual,
          ),
        ),
        const SizedBox(height: 18),
        copy,
      ],
    );
  }
}

class _CopyColumn extends StatelessWidget {
  const _CopyColumn({required this.slide});
  final GuideSlide slide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          slide.kicker,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: PlColors.accent,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          slide.title,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 30,
                height: 1.05,
                letterSpacing: -1.1,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          slide.body,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: PlColors.muted,
                height: 1.4,
                fontSize: 15,
              ),
        ),
        const SizedBox(height: 18),
        ...slide.points.map((p) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PlColors.surface,
                borderRadius: BorderRadius.circular(PlRadius.md),
                border: Border.all(color: PlColors.lineSoft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.label,
                    style: const TextStyle(
                      color: PlColors.accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.detail,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: PlColors.text,
                          height: 1.35,
                        ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
