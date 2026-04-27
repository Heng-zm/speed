import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/battery_provider.dart';
import '../models/app_theme.dart';
import '../widgets/wattage_chart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BatteryProvider>(
      builder: (context, provider, _) {
        final stats = provider.stats;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Statistics',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const Text(
                'Live monitoring data',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 24),

              _SectionLabel('Wattage History'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${stats.wattage.toStringAsFixed(2)} W',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentLight,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0c2018),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: AppTheme.accentBorder),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    WattageChart(data: provider.wattageHistory),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _SectionLabel('Power Details'),
              const SizedBox(height: 8),

              _InfoRow('Voltage', '${stats.voltage.toStringAsFixed(3)} V'),
              _InfoRow('Current', '${stats.current.toStringAsFixed(2)} A'),
              _InfoRow('Wattage',
                  '${stats.wattage.toStringAsFixed(2)} W'),
              _InfoRow('Power In',
                  '${(stats.wattage * 0.92).toStringAsFixed(2)} W net'),
              _InfoRow('Capacity', '${stats.capacityMah} mAh'),
              _InfoRow('Temperature',
                  '${stats.temperature.toStringAsFixed(1)}°C'),

              const SizedBox(height: 16),
              _SectionLabel('Charge Status'),
              const SizedBox(height: 8),

              _InfoRow('Status',
                  stats.isCharging ? 'Charging' : 'Discharging',
                  valueColor: stats.isCharging
                      ? AppTheme.accent
                      : AppTheme.warn),
              _InfoRow(
                  'Mode',
                  stats.isFastCharging ? 'Fast Charge' : 'Standard',
                  valueColor: stats.isFastCharging
                      ? AppTheme.accent
                      : AppTheme.textSecondary),
              _InfoRow('Time Remaining', provider.chargeTimeString),
              _InfoRow('Full By', provider.fullByTime),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        color: AppTheme.textMuted,
        letterSpacing: 1.0,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 1),
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(
          bottom: BorderSide(color: Color(0xFF161616), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.textPrimary,
              fontFamily: 'SpaceGrotesk',
            ),
          ),
        ],
      ),
    );
  }
}
