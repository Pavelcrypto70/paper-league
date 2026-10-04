import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/l10n/s_path.dart';
import 'package:paper_league/services/desk_audio.dart';
import 'package:paper_league/theme/tokens.dart';

/// Visual kit shared by the first-contact screens (promise → missions → ceremonies).
abstract final class PathInk {
  static const accentLine = Color(0xFF1F5566);
  static const coachLine = Color(0xFF2B6F82);
  static const coachText = Color(0xFFD7F7FF);
  static const warnSoft = Color(0xFF2C2108);
  static const warnLine = Color(0xFF5A4210);
  static const warnText = Color(0xFFFFE1A3);
  static const bullLine = Color(0xFF1D5A45);
  static const bullText = Color(0xFFBFF5E1);
  static const bearLine = Color(0xFF5A1D27);
  static const body = Color(0xFFDCE4EE);
}

TextStyle pathMono({double size = 14, FontWeight weight = FontWeight.w600, Color color = PlColors.text}) =>
    GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

TextStyle pathTitleStyle(BuildContext context, {double size = 24}) =>
    (Theme.of(context).textTheme.headlineSmall ?? const TextStyle()).copyWith(
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.4,
      color: PlColors.text,
    );

const pathSubStyle = TextStyle(fontSize: 15, color: PlColors.muted, height: 1.5);
const pathCapStyle = TextStyle(fontSize: 12, color: PlColors.muted, letterSpacing: 0.2);
const pathFineStyle = TextStyle(fontSize: 12, color: PlColors.faint, height: 1.45);

void pathTap({bool strong = false}) {
  DeskAudio.instance.play(DeskSfx.tap);
  if (strong) {
    HapticFeedback.mediumImpact();
  } else {
    HapticFeedback.selectionClick();
  }
}

enum PathTone { neutral, accent, bull, bear, warn }

class PathChip extends StatelessWidget {
  const PathChip(this.label, {super.key, this.tone = PathTone.neutral, this.icon});

  final String label;
  final PathTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (tone) {
      PathTone.accent => (PlColors.accentDim, PlColors.accent, PathInk.accentLine),
      PathTone.bull => (PlColors.bullSoft, PlColors.bull, PathInk.bullLine),
      PathTone.bear => (PlColors.bearSoft, PlColors.bear, PathInk.bearLine),
      PathTone.warn => (PathInk.warnSoft, PlColors.warn, PathInk.warnLine),
      PathTone.neutral => (PlColors.surface2, PlColors.muted, PlColors.lineSoft),
    };
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          Text(label, style: pathMono(size: 12, weight: FontWeight.w500, color: fg)),
        ],
      ),
    );
  }
}

enum PathButtonTone { primary, ghost, bull, bear, off }

class PathButton extends StatefulWidget {
  const PathButton(
    this.label, {
    super.key,
    this.onPressed,
    this.tone = PathButtonTone.primary,
    this.icon,
    this.trailingIcon,
    this.pulse = false,
    this.faded = false,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final PathButtonTone tone;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool pulse;
  final bool faded;
  final double height;

  @override
  State<PathButton> createState() => _PathButtonState();
}

class _PathButtonState extends State<PathButton> with SingleTickerProviderStateMixin {
  AnimationController? _pulse;

  @override
  void initState() {
    super.initState();
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant PathButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulse != widget.pulse) _syncPulse();
  }

  void _syncPulse() {
    if (widget.pulse && _pulse == null) {
      _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
        ..repeat(reverse: true);
    } else if (!widget.pulse && _pulse != null) {
      _pulse!.dispose();
      _pulse = null;
    }
  }

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tone = widget.onPressed == null && widget.tone != PathButtonTone.ghost
        ? PathButtonTone.off
        : widget.tone;
    final (bg, fg, border) = switch (tone) {
      PathButtonTone.primary => (PlColors.accent, PlColors.onAccent, Colors.transparent),
      PathButtonTone.bull => (PlColors.bull, PlColors.onBull, Colors.transparent),
      PathButtonTone.bear => (PlColors.bear, PlColors.onBear, Colors.transparent),
      PathButtonTone.ghost => (Colors.transparent, PlColors.text, PlColors.line),
      PathButtonTone.off => (PlColors.surface3, PlColors.faint, Colors.transparent),
    };
    final radius = BorderRadius.circular(widget.height >= 50 ? 14 : 12);
    Widget button = Opacity(
      opacity: widget.faded ? 0.35 : 1,
      child: Material(
        color: bg,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: widget.onPressed,
          child: Container(
            height: widget.height,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 18, color: fg),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      fontSize: widget.height >= 50 ? 16 : 14,
                    ),
                  ),
                ),
                if (widget.trailingIcon != null) ...[
                  const SizedBox(width: 10),
                  Icon(widget.trailingIcon, size: 18, color: fg),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    final pulse = _pulse;
    if (pulse != null && widget.onPressed != null) {
      final ringColor = widget.tone == PathButtonTone.bull ? PlColors.bull : PlColors.accent;
      button = AnimatedBuilder(
        animation: pulse,
        builder: (context, child) => Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: ringColor.withValues(alpha: 0.16 + 0.22 * pulse.value),
              width: 4,
            ),
          ),
          child: child,
        ),
        child: button,
      );
    }
    return button;
  }
}

class PathCard extends StatelessWidget {
  const PathCard({
    super.key,
    required this.child,
    this.accent = false,
    this.dim = false,
    this.padding = const EdgeInsets.all(15),
  });

  final Widget child;
  final bool accent;
  final bool dim;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dim ? 0.55 : 1,
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: PlColors.surface,
          borderRadius: BorderRadius.circular(PlRadius.lg),
          border: Border.all(color: accent ? PathInk.accentLine : PlColors.lineSoft),
        ),
        child: child,
      ),
    );
  }
}

class CoachBubble extends StatelessWidget {
  const CoachBubble(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
      decoration: BoxDecoration(
        color: PlColors.accentDim,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PathInk.coachLine),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2, right: 11),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: PlColors.accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: PlColors.accent.withValues(alpha: 0.18), spreadRadius: 4),
              ],
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.45, color: PathInk.coachText),
            ),
          ),
        ],
      ),
    );
  }
}

class PathBanner extends StatelessWidget {
  const PathBanner({
    super.key,
    required this.tone,
    required this.icon,
    required this.title,
    required this.body,
  });

  final PathTone tone;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final (bg, border, text, iconColor) = switch (tone) {
      PathTone.bull => (PlColors.bullSoft, PathInk.bullLine, PathInk.bullText, PlColors.bull),
      PathTone.bear => (PlColors.bearSoft, PathInk.bearLine, const Color(0xFFFFC7CE), PlColors.bear),
      _ => (PathInk.warnSoft, PathInk.warnLine, PathInk.warnText, PlColors.warn),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(PlRadius.md),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: ' $body'),
                ],
              ),
              style: TextStyle(fontSize: 14, height: 1.4, color: text),
            ),
          ),
        ],
      ),
    );
  }
}

class KvRow extends StatelessWidget {
  const KvRow(this.label, this.value, {super.key, this.valueColor = PlColors.text});

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: PlColors.muted)),
          const Spacer(),
          Text(value, style: pathMono(color: valueColor)),
        ],
      ),
    );
  }
}

class CheckLine extends StatelessWidget {
  const CheckLine(this.text, {super.key, this.ok = true, this.divider = true});

  final String text;
  final bool ok;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: divider ? const Border(bottom: BorderSide(color: PlColors.lineSoft)) : null,
      ),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_rounded : Icons.error_outline_rounded,
            size: 18,
            color: ok ? PlColors.bull : PlColors.warn,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14, color: PathInk.body)),
          ),
        ],
      ),
    );
  }
}

/// "Mission N of 4" + close + four progress segments.
class MissionHeader extends StatelessWidget {
  const MissionHeader({super.key, required this.mission, required this.onClose});

  final int mission;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      children: [
        Row(
          children: [
            Text(s.missionOf(mission), style: pathMono(size: 13, weight: FontWeight.w600, color: PlColors.muted)),
            const Spacer(),
            InkResponse(
              onTap: onClose,
              radius: 22,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close_rounded, size: 22, color: PlColors.muted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            for (var i = 1; i <= 4; i++) ...[
              if (i > 1) const SizedBox(width: 6),
              Expanded(
                child: AnimatedContainer(
                  duration: PlMotion.standard,
                  height: 5,
                  decoration: BoxDecoration(
                    color: i < mission
                        ? PlColors.bull
                        : i == mission
                            ? PlColors.accent
                            : PlColors.surface3,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Bottom sheet frame with grab handle, used by reminder and other path sheets.
class PathSheet extends StatelessWidget {
  const PathSheet({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PlColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(top: BorderSide(color: PlColors.line)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(color: PlColors.line, borderRadius: BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
