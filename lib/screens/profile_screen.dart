import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // PERFORMANCE: ValueNotifiers ensure only the specific switch/text rebuilds
  final _smartCharge = ValueNotifier<bool>(true);
  final _notifications = ValueNotifier<bool>(true);
  final _overchargeAlert = ValueNotifier<bool>(true);
  final _heatAlert = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _smartCharge.dispose();
    _notifications.dispose();
    _overchargeAlert.dispose();
    _heatAlert.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const _HeaderSection(),
          const SizedBox(height: 24),
          const _DeviceCard(),
          const SizedBox(height: 24),
          const _SectionHeader('Optimization'),
          _SettingGroup(children: [
            _ToggleRow(
              label: 'Smart Charge Limit',
              subtitle: 'Prevent wear by stopping at 80%',
              notifier: _smartCharge,
            ),
          ]),
          const _SectionHeader('Alerts'),
          _SettingGroup(children: [
            _ToggleRow(
              label: 'Notifications',
              subtitle: 'Charge complete & warnings',
              notifier: _notifications,
            ),
            _ToggleRow(
              label: 'Overcharge Alert',
              subtitle: 'Notify at 100%',
              notifier: _overchargeAlert,
            ),
            _ToggleRow(
              label: 'Heat Warning',
              subtitle: 'Alert when temp > 40°C',
              notifier: _heatAlert,
              isLast: true,
            ),
          ]),
          const _SectionHeader('About'),
          _SettingGroup(children: [
            const _InfoTile(label: 'Version', value: '1.1.0'),
            const _InfoTile(label: 'Build', value: '2025.01.RC1'),
            const _InfoTile(
                label: 'Data Source', value: 'battery_plus', isLast: true),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// --- Components ---

class _SettingGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentBorder.withOpacity(0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const Text(
          'Manage SpeedCharge performance',
          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
      ],
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0a1a12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bolt_rounded,
                color: AppTheme.accentLight, size: 26),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'iPhone 16 Pro',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Text(
                'Health: 98% · 3847 mAh',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final ValueNotifier<bool> notifier;
  final bool isLast;

  const _ToggleRow(
      {required this.label,
      required this.subtitle,
      required this.notifier,
      this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            notifier.value = !notifier.value;
            HapticFeedback.selectionClick();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              fontSize: 14, color: AppTheme.textPrimary)),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: notifier,
                  builder: (context, value, _) {
                    return CupertinoSwitch(
                      value: value,
                      onChanged: (v) {
                        notifier.value = v;
                        HapticFeedback.selectionClick();
                      },
                      activeColor: AppTheme.accent,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: AppTheme.accentBorder.withOpacity(0.3)),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _InfoTile(
      {required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textSecondary)),
              Text(value,
                  style:
                      const TextStyle(fontSize: 14, color: AppTheme.textMuted)),
            ],
          ),
        ),
        if (!isLast)
          Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: AppTheme.accentBorder.withOpacity(0.3)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textMuted,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
