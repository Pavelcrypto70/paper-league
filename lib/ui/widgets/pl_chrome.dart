import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:paper_league/theme/tokens.dart';

class PlAvatar extends StatelessWidget {
  const PlAvatar({
    super.key,
    required this.nickname,
    required this.hue,
    this.path,
    this.size = 64,
    this.onTap,
  });

  final String nickname;
  final int hue;
  final String? path;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final initial = nickname.trim().isEmpty
        ? 'T'
        : nickname.trim().substring(0, 1).toUpperCase();
    final bg = HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.42).toColor();

    Widget child;
    final p = path;
    if (p != null && p.isNotEmpty && !kIsWeb) {
      child = ClipOval(
        child: Image.file(
          File(p),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _Initials(initial: initial, bg: bg, size: size),
        ),
      );
    } else if (p != null && p.isNotEmpty && kIsWeb) {
      // Web: image_picker may give blob URL — use NetworkImage/XFile display via Image.network when http
      child = ClipOval(
        child: Image.network(
          p,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _Initials(initial: initial, bg: bg, size: size),
        ),
      );
    } else {
      child = _Initials(initial: initial, bg: bg, size: size);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: PlColors.accent.withValues(alpha: 0.45), width: 1.5),
          boxShadow: const [],
        ),
        child: child,
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.initial, required this.bg, required this.size});
  final String initial;
  final Color bg;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        initial,
        style: TextStyle(
          color: PlColors.text,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}

class PlSurface extends StatelessWidget {
  const PlSurface({
    super.key,
    required this.child,
    this.padding,
    this.accentBorder = false,
    this.gradient = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool accentBorder;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(PlSpace.lg),
      decoration: BoxDecoration(
        color: gradient ? null : PlColors.surface,
        gradient: gradient
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [PlColors.surface, PlColors.bgElevated],
              )
            : null,
        borderRadius: BorderRadius.circular(PlRadius.lg),
        border: Border.all(
          color: accentBorder ? PlColors.accent.withValues(alpha: 0.35) : PlColors.lineSoft,
        ),
      ),
      child: child,
    );
  }
}

class PlSectionTitle extends StatelessWidget {
  const PlSectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: PlColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        ?trailing,
      ],
    );
  }
}

class PlStatTile extends StatelessWidget {
  const PlStatTile({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.sub,
  });

  final String label;
  final String value;
  final Color? color;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return PlSurface(
      padding: const EdgeInsets.all(PlSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color ?? PlColors.text,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(sub!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
