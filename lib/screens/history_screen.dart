import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/battery_provider.dart';
import '../models/app_theme.dart';
import '../models/battery_stats.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // PERFORMANCE FIX: The main column and header are now const.
    // They will not rebuild when new history data arrives.
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(),
        Expanded(
          child: _HistoryList(),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'History',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const Text(
            'Session log',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList();

  @override
  Widget build(BuildContext context) {
    // Localized Consumer: Only the list rebuilds when history updates
    return Consumer<BatteryProvider>(
      builder: (context, provider, _) {
        final history = provider.history;

        if (history.isEmpty) {
          return const Center(
            child: Text(
              'No data yet.\nStay on the Charge screen to collect data.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final entry = history[index];
            return _HistoryTile(
              // PERFORMANCE FIX: ValueKey helps Flutter efficiently shift items
              // down when a new log is inserted at the top of the list.
              key: ValueKey(entry.timestamp),
              entry: entry,
            );
          },
        );
      },
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final BatteryStats entry;

  const _HistoryTile({super.key, required this.entry});

  // PERFORMANCE FIX: Cache DateFormat! Allocating this inside the ListView
  // builder creates massive GC (Garbage Collection) pauses during scrolling.
  static final DateFormat _timeFormat = DateFormat('h:mm:ss a');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.bgCardAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.accentBorder),
            ),
            child: Center(
              child: Text(
                '${entry.percentage.toStringAsFixed(0)}%',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentLight,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.wattage.toStringAsFixed(2)} W · ${entry.voltage.toStringAsFixed(3)} V',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${entry.temperature.toStringAsFixed(1)}°C · ${entry.current.toStringAsFixed(2)} A',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _timeFormat.format(entry.timestamp),
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
