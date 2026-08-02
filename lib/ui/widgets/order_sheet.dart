import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paper_league/domain/models.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/format.dart';

Future<void> showOrderSheet(
  BuildContext context, {
  required DeskController desk,
  required Side side,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: PlColors.surface,
    builder: (ctx) => OrderSheet(desk: desk, initialSide: side),
  );
}

class OrderSheet extends StatefulWidget {
  const OrderSheet({super.key, required this.desk, required this.initialSide});

  final DeskController desk;
  final Side initialSide;

  @override
  State<OrderSheet> createState() => _OrderSheetState();
}

class _OrderSheetState extends State<OrderSheet> {
  late Side _side;
  double _riskPct = DeskController.riskDefault;
  double _stopPct = 0.015;
  double _tpR = 1.5;

  @override
  void initState() {
    super.initState();
    _side = widget.initialSide;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.desk,
      builder: (context, _) {
        final desk = widget.desk;
        final s = S.of(context);
        final mark = desk.mark;
        final stop = _side == Side.long ? mark * (1 - _stopPct) : mark * (1 + _stopPct);
        final risk = (mark - stop).abs();
        final tp = risk <= 0
            ? null
            : (_side == Side.long ? mark + risk * _tpR : mark - risk * _tpR);
        final riskCash = desk.equity * _riskPct;
        final qty = desk.qtyForRisk(side: _side, entry: mark, stop: stop, riskPct: _riskPct);
        final bottom = MediaQuery.viewInsetsOf(context).bottom;
        final tone = _side == Side.long ? PlColors.bull : PlColors.bear;

        return Padding(
      padding: EdgeInsets.fromLTRB(PlSpace.lg, PlSpace.md, PlSpace.lg, PlSpace.lg + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PlColors.line,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: PlSpace.lg),
          Row(
            children: [
              Text(s.ticket, style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              Text(
                '${s.mark} ${priceFmt(mark)}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: PlColors.accent),
              ),
            ],
          ),
          const SizedBox(height: PlSpace.lg),
          Row(
            children: [
              Expanded(
                child: _Side(
                  label: s.long,
                  on: _side == Side.long,
                  color: PlColors.bull,
                  onTap: () => setState(() => _side = Side.long),
                ),
              ),
              const SizedBox(width: PlSpace.sm),
              Expanded(
                child: _Side(
                  label: s.short,
                  on: _side == Side.short,
                  color: PlColors.bear,
                  onTap: () => setState(() => _side = Side.short),
                ),
              ),
            ],
          ),
          const SizedBox(height: PlSpace.xl),
          Text(s.stopDistance, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: PlSpace.sm),
          Row(
            children: [0.006, 0.008, 0.015, 0.025].where((v) {
              if (v == 0.006 && !desk.hasTightRisk) return false;
              return true;
            }).map((v) {
              final on = (_stopPct - v).abs() < 0.0001;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('${(v * 100).toStringAsFixed(1)}%'),
                  selected: on,
                  onSelected: (_) => setState(() => _stopPct = v),
                  selectedColor: PlColors.accentSoft,
                  labelStyle: TextStyle(
                    color: on ? PlColors.accent : PlColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                  backgroundColor: PlColors.surface2,
                  side: BorderSide(color: on ? PlColors.accent : PlColors.line),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: PlSpace.lg),
          Text(s.riskEquity, style: Theme.of(context).textTheme.labelSmall),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: tone,
              thumbColor: tone,
              inactiveTrackColor: PlColors.line,
            ),
            child: Slider(
              value: _riskPct,
              min: 0.005,
              max: 0.05,
              onChanged: (v) => setState(() => _riskPct = v),
            ),
          ),
          Text(
            '${(_riskPct * 100).toStringAsFixed(1)}% · ${s.ifStopped(money(riskCash))}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: PlColors.warn),
          ),
          const SizedBox(height: PlSpace.lg),
          Text(s.takeProfit, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: PlSpace.sm),
          Row(
            children: [1.0, 1.5, 2.0, 3.0].map((r) {
              final on = (_tpR - r).abs() < 0.01;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('${r.toStringAsFixed(1)}R'),
                  selected: on,
                  onSelected: (_) => setState(() => _tpR = r),
                  selectedColor: PlColors.bullSoft,
                  labelStyle: TextStyle(
                    color: on ? PlColors.bull : PlColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                  backgroundColor: PlColors.surface2,
                  side: BorderSide(color: on ? PlColors.bull : PlColors.line),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: PlSpace.xl),
          Container(
            padding: const EdgeInsets.all(PlSpace.md),
            decoration: BoxDecoration(
              color: PlColors.bgElevated,
              borderRadius: BorderRadius.circular(PlRadius.md),
              border: Border.all(color: PlColors.lineSoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${s.qtyLabel} ${qtyFmt(qty)} · ${s.notionalLabel} ${money(qty * mark)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  '${s.slLabel} ${priceFmt(stop)} · ${s.tpLabel} ${priceFmt(tp ?? 0)} · R:R ${_tpR.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: PlSpace.xl),
          SizedBox(
            height: 54,
            child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: tone,
                    foregroundColor: _side == Side.long ? PlColors.onBull : PlColors.onBear,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PlRadius.md)),
                  ),
              onPressed: () {
                // Atomic: recompute levels from the same mark used as entry.
                final fill = desk.mark;
                final fillStop =
                    _side == Side.long ? fill * (1 - _stopPct) : fill * (1 + _stopPct);
                final fillRisk = (fill - fillStop).abs();
                final fillTp = fillRisk <= 0
                    ? null
                    : (_side == Side.long ? fill + fillRisk * _tpR : fill - fillRisk * _tpR);
                final err = desk.placeMarket(
                  side: _side,
                  riskPct: _riskPct,
                  stop: fillStop,
                  tp: fillTp,
                  entryOverride: fill,
                );
                if (err != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.orderError(err))),
                  );
                  return;
                }
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
              },
              child: Text(
                _side == Side.long ? s.placeLong : s.placeShort,
                style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({
    required this.label,
    required this.on,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool on;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: on ? color.withValues(alpha: 0.16) : PlColors.surface2,
      borderRadius: BorderRadius.circular(PlRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PlRadius.md),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PlRadius.md),
            border: Border.all(color: on ? color : PlColors.line),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: on ? color : PlColors.muted,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
