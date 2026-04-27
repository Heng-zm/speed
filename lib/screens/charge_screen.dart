import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/battery_provider.dart';
import '../models/app_theme.dart';
import '../models/battery_stats.dart'; // Ensure stats model is imported for typing
import '../widgets/charge_ring.dart';
import '../widgets/stat_card.dart';

class ChargeScreen extends StatelessWidget {
  const ChargeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // PERFORMANCE FIX: The entire scroll view structure is now const.
    // Rebuilds are pushed deep into the specific leaf nodes that need them.
    return const SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          _HeaderSection(),
          SizedBox(height: 28),
          _RingSection(),
          SizedBox(height: 20),
          _TimeChipsSection(),
          SizedBox(height: 12),
          _WattageSection(),
          SizedBox(height: 12),
          _StatsGridSection(),
          SizedBox(height: 12),
          _ProgressSection(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

// --- Localized Components ---

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final isFastCharging = context.select<BatteryProvider, bool>(
      (p) => p.stats.isFastCharging,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SpeedCharge',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            if (isFastCharging) const _FastBadge(),
          ],
        ),
        const _LiveClock(),
      ],
    );
  }
}

class _LiveClock extends StatelessWidget {
  const _LiveClock();

  // PERFORMANCE FIX: Cache DateFormat to prevent expensive re-allocation
  static final _formatter = DateFormat('EEE, MMM d · h:mm a');

  @override
  Widget build(BuildContext context) {
    // Tie the clock strictly to the provider's timestamp ticks
    final timestamp = context.select<BatteryProvider, DateTime>(
      (p) => p.stats.timestamp,
    );

    return Text(
      _formatter.format(timestamp),
      style: const TextStyle(
        fontSize: 12,
        color: AppTheme.textMuted,
      ),
    );
  }
}

class _RingSection extends StatelessWidget {
  const _RingSection();

  @override
  Widget build(BuildContext context) {
    final percentage =
        context.select<BatteryProvider, double>((p) => p.stats.percentage);
    final isCharging =
        context.select<BatteryProvider, bool>((p) => p.stats.isCharging);

    return Center(
      child: ChargeRingWidget(
        percentage: percentage,
        isCharging: isCharging,
      ),
    );
  }
}

class _TimeChipsSection extends StatelessWidget {
  const _TimeChipsSection();

  @override
  Widget build(BuildContext context) {
    final chargeTime =
        context.select<BatteryProvider, String>((p) => p.chargeTimeString);
    final fullBy = context.select<BatteryProvider, String>((p) => p.fullByTime);

    return Row(
      children: [
        Expanded(
          child: _TimeChip(
            icon: Icons.timer_outlined,
            label: chargeTime,
            sublabel: 'to full',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TimeChip(
            icon: Icons.schedule_rounded,
            label: fullBy,
            sublabel: 'full by',
          ),
        ),
      ],
    );
  }
}

class _WattageSection extends StatelessWidget {
  const _WattageSection();

  @override
  Widget build(BuildContext context) {
    final wattage =
        context.select<BatteryProvider, double>((p) => p.stats.wattage);
    return _WattageRow(wattage: wattage);
  }
}

class _StatsGridSection extends StatelessWidget {
  const _StatsGridSection();

  @override
  Widget build(BuildContext context) {
    // PERFORMANCE FIX: GridView layout is now const and never rebuilds.
    // The inner _DynamicStatCards handle their own localized state updates.
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _DynamicStatCard(
          label: 'Voltage',
          unit: 'V',
          valueSelector: (s) => s.voltage.toStringAsFixed(3),
        ),
        _DynamicStatCard(
          label: 'Temp',
          unit: '°C',
          isAccent: true,
          valueSelector: (s) => s.temperature.toStringAsFixed(1),
          colorSelector: (p) => p.tempColor,
        ),
        _DynamicStatCard(
          label: 'Current',
          unit: 'A',
          valueSelector: (s) => s.current.toStringAsFixed(2),
        ),
        _DynamicStatCard(
          label: 'Capacity',
          unit: 'mAh',
          valueSelector: (s) => s.capacityMah.toString(),
        ),
      ],
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection();

  @override
  Widget build(BuildContext context) {
    final pct =
        context.select<BatteryProvider, double>((p) => p.stats.percentage);
    return _ProgressBar(percentage: pct);
  }
}

// --- Custom Reusable Components ---

class _DynamicStatCard extends StatelessWidget {
  final String label;
  final String unit;
  final bool isAccent;
  final String Function(BatteryStats) valueSelector;
  final Color Function(BatteryProvider)? colorSelector;

  const _DynamicStatCard({
    required this.label,
    required this.unit,
    this.isAccent = false,
    required this.valueSelector,
    this.colorSelector,
  });

  @override
  Widget build(BuildContext context) {
    final value =
        context.select<BatteryProvider, String>((p) => valueSelector(p.stats));
    final color = colorSelector != null
        ? context.select<BatteryProvider, Color>((p) => colorSelector!(p))
        : null;

    return StatCard(
      value: value,
      unit: unit,
      label: label,
      isAccent: isAccent,
      valueColor: color,
    );
  }
}

class _FastBadge extends StatefulWidget {
  const _FastBadge();

  @override
  State<_FastBadge> createState() => _FastBadgeState();
}

class _FastBadgeState extends State<_FastBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1A3A2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.accent, width: 1),
        ),
        // Added const to avoid rebuilding the static Row
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, color: AppTheme.accent, size: 12),
            SizedBox(width: 3),
            Text(
              'FAST',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.accent,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;

  const _TimeChip({
    required this.icon,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textMuted, size: 14),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                sublabel,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WattageRow extends StatelessWidget {
  final double wattage;
  const _WattageRow({required this.wattage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.bgCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentBorder, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              _PulsingDot(),
              SizedBox(width: 10),
              Text(
                'LIVE WATTAGE',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          Text(
            '${wattage.toStringAsFixed(2)} W',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.accentLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // PERFORMANCE FIX: Moved from AnimatedBuilder (CPU calculation) to
    // FadeTransition (GPU/Render tree acceleration). O(1) performance.
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme
              .accent, // Base color handles rendering, Fade handles opacity
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double percentage;
  const _ProgressBar({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CHARGE LEVEL',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: const Color(0xFF1A1A1A),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
