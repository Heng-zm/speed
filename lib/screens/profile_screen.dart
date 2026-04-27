import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Real Hardware State
  String _deviceModel = "Loading Device...";
  String _batteryLevel = "--";
  String _appVersion = "1.0.0";
  String _buildNumber = "1";

  // Persistent Settings State
  final _smartCharge = ValueNotifier<bool>(true);
  final _notifications = ValueNotifier<bool>(true);
  final _overchargeAlert = ValueNotifier<bool>(true);
  final _heatAlert = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  @override
  void dispose() {
    _smartCharge.dispose();
    _notifications.dispose();
    _overchargeAlert.dispose();
    _heatAlert.dispose();
    super.dispose();
  }

  Future<void> _initApp() async {
    await Future.wait([
      _loadHardwareData(),
      _loadSettings(),
    ]);
  }

  // --- 1. Fetch Real Hardware & Version Data ---
  Future<void> _loadHardwareData() async {
    final battery = Battery();
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    final level = await battery.batteryLevel;
    final state = await battery.batteryState;
    String statusStr =
        state == BatteryState.charging ? "⚡ Charging" : "On Battery";

    String model = "Unknown Device";
    try {
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        model = _mapIosMachineCode(iosInfo.utsname.machine);
      } else {
        final androidInfo = await deviceInfo.androidInfo;
        model = androidInfo.model;
      }
    } catch (e) {
      model = "SpeedCharge Device";
    }

    if (mounted) {
      setState(() {
        _deviceModel = model;
        _batteryLevel = "$level% · $statusStr";
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    }
  }

  // --- 2. Load Saved Toggles ---
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _smartCharge.value = prefs.getBool('smartCharge') ?? true;
    _notifications.value = prefs.getBool('notifications') ?? true;
    _overchargeAlert.value = prefs.getBool('overchargeAlert') ?? true;
    _heatAlert.value = prefs.getBool('heatAlert') ?? true;
  }

  // --- 3. Save Toggles ---
  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // Helper to make "iPhone16,1" look like "iPhone 15 Pro"
  String _mapIosMachineCode(String machineCode) {
    const map = {
      "iPhone14,2": "iPhone 13 Pro",
      "iPhone14,3": "iPhone 13 Pro Max",
      "iPhone14,7": "iPhone 14",
      "iPhone15,2": "iPhone 14 Pro",
      "iPhone15,3": "iPhone 14 Pro Max",
      "iPhone15,4": "iPhone 15",
      "iPhone16,1": "iPhone 15 Pro",
      "iPhone16,2": "iPhone 15 Pro Max",
      "iPhone17,1": "iPhone 16 Pro",
      "iPhone17,2": "iPhone 16 Pro Max",
    };
    return map[machineCode] ?? machineCode;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const _HeaderSection(),
          const SizedBox(height: 24),

          // REAL Device Card
          _DeviceCard(model: _deviceModel, status: _batteryLevel),

          const SizedBox(height: 28),

          const _SectionHeader('Optimization'),
          _SettingGroup(children: [
            _ToggleRow(
              label: 'Smart Charge Limit',
              subtitle: 'Extend battery life by stopping at 80%',
              notifier: _smartCharge,
              onToggled: (v) => _saveSetting('smartCharge', v),
            ),
          ]),

          const _SectionHeader('Alerts'),
          _SettingGroup(children: [
            _ToggleRow(
              label: 'Notifications',
              subtitle: 'Status updates & alerts',
              notifier: _notifications,
              onToggled: (v) => _saveSetting('notifications', v),
            ),
            _ToggleRow(
              label: 'Overcharge Alert',
              subtitle: 'Notify when reaching 100%',
              notifier: _overchargeAlert,
              onToggled: (v) => _saveSetting('overchargeAlert', v),
            ),
            _ToggleRow(
              label: 'Heat Warning',
              subtitle: 'Alert when temp > 40°C',
              notifier: _heatAlert,
              isLast: true,
              onToggled: (v) => _saveSetting('heatAlert', v),
            ),
          ]),

          const _SectionHeader('System Info'),
          _SettingGroup(children: [
            _InfoTile(label: 'Version', value: _appVersion),
            _InfoTile(label: 'Build', value: _buildNumber),
            const _InfoTile(
                label: 'Data Source', value: 'System API', isLast: true),
          ]),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// --- Local UI Components ---

class _SettingGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -1.0,
          ),
        ),
        const Text(
          'Manage SpeedCharge performance',
          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
      ],
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final String model;
  final String status;

  const _DeviceCard({required this.model, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.bgCardAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF0a1a12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.bolt_rounded,
                color: AppTheme.accentLight, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  status,
                  style:
                      const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
              ],
            ),
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
  final Function(bool) onToggled;
  final bool isLast;

  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.notifier,
    required this.onToggled,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            notifier.value = !notifier.value;
            onToggled(notifier.value);
            HapticFeedback.selectionClick();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                            fontSize: 15,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textMuted),
                      ),
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
                        onToggled(v);
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
        GestureDetector(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: value));
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('$label copied!'),
                  duration: const Duration(seconds: 1)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 15, color: AppTheme.textSecondary)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15, color: AppTheme.textMuted)),
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

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          color: AppTheme.accent,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
