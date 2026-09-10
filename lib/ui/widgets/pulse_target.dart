import 'package:flutter/material.dart';
import 'package:paper_league/theme/tokens.dart';

/// Soft pulse around the one control the first gesture needs.
class PulseTarget extends StatefulWidget {
  const PulseTarget({super.key, required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<PulseTarget> createState() => _PulseTargetState();
}

class _PulseTargetState extends State<PulseTarget> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    if (widget.active) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant PulseTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!widget.active && _c.isAnimating) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PlRadius.md),
            boxShadow: [
              BoxShadow(
                color: PlColors.accent.withValues(alpha: 0.18 + t * 0.35),
                blurRadius: 8 + t * 14,
                spreadRadius: 1 + t * 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
