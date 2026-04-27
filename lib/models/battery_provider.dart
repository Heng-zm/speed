import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:battery_plus/battery_plus.dart';
import '../models/battery_stats.dart';

class BatteryProvider extends ChangeNotifier {
  final Battery _battery = Battery();

  // NATIVE BRIDGE: Communicates directly with Android/iOS hardware sensors
  static const MethodChannel _hardwareChannel =
      MethodChannel('com.speedcharge/hardware');

  Timer? _pollingTimer;
  StreamSubscription<BatteryState>? _batterySubscription;

  // Initial zeroed-out state until real hardware data arrives
  BatteryStats _stats = BatteryStats(
    percentage: 0.0,
    voltage: 0.0,
    temperature: 0.0,
    wattage: 0.0,
    current: 0.0,
    capacityMah: 0,
    isCharging: false,
    isFastCharging: false,
    minutesToFull: 0,
    timestamp: DateTime.now(),
  );

  final List<BatteryStats> _history = [];
  final List<FlSpotData> _wattageHistory = [];

  double _chartXCounter = 0;
  int _currentNavIndex = 0;
  BatteryState _batteryState = BatteryState.unknown;

  BatteryStats get stats => _stats;
  List<BatteryStats> get history => _history;
  List<FlSpotData> get wattageHistory => _wattageHistory;
  int get currentNavIndex => _currentNavIndex;
  BatteryState get batteryState => _batteryState;

  BatteryProvider() {
    _initBatteryStream();
    _startHardwarePolling();
  }

  void _initBatteryStream() {
    _batterySubscription = _battery.onBatteryStateChanged.listen((state) {
      _batteryState = state;
      _fetchRealData(); // Immediately fetch new data when state changes
    });
  }

  void _startHardwarePolling() {
    // Fetch real hardware stats every 3 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchRealData();
    });

    // Trigger initial fetch
    _fetchRealData();
  }

  Future<void> _fetchRealData() async {
    try {
      // 1. Get standard data via battery_plus
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      final isCharging =
          state == BatteryState.charging || state == BatteryState.full;

      // 2. Fetch advanced hardware data via Native MethodChannel
      double voltage = 0.0;
      double temperature = 0.0;
      double current = 0.0;
      int capacityMah = 0;

      try {
        final hwData = await _hardwareChannel
            .invokeMapMethod<String, dynamic>('getBatteryHardware');

        if (hwData != null) {
          // Android Native values require conversion to standard units

          // Voltage is usually returned in millivolts (mV). Convert to Volts (V).
          voltage = (hwData['voltage'] as num? ?? 0) / 1000.0;

          // Temperature is returned in tenths of a degree Celsius. Convert to °C.
          temperature = (hwData['temperature'] as num? ?? 0) / 10.0;

          // Current is usually in microamps (μA). Convert to Amps (A).
          // We use absolute value because discharging is often represented as negative.
          current = ((hwData['current'] as num? ?? 0).abs()) / 1000000.0;

          capacityMah = (hwData['capacity'] as num? ?? 0).toInt();
        }
      } on PlatformException catch (_) {
        // Fallback gracefully if iOS or Native channel isn't implemented yet
      }

      // 3. Calculate Wattage (W = V * A)
      final wattage = voltage * current;

      // Fast charging heuristic (Generally > 15W)
      final isFastCharging = isCharging && wattage > 15.0;

      // Update state
      _stats = _stats.copyWith(
        percentage: level.toDouble(),
        voltage: _round(voltage, 3),
        temperature: _round(temperature, 1),
        wattage: _round(wattage, 2),
        current: _round(current, 2),
        capacityMah: capacityMah,
        isCharging: isCharging,
        isFastCharging: isFastCharging,
        minutesToFull: _estimateTimeToFull(
            level.toDouble(), current, capacityMah, isCharging),
        timestamp: DateTime.now(),
      );

      _updateHistoryLog();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching real battery data: $e");
    }
  }

  void _updateHistoryLog() {
    // Ignore updating history if wattage/current is basically 0 to prevent
    // flooding the history chart when the device is idle/unchanging.
    if (_stats.wattage < 0.1 && !_stats.isCharging) return;

    // Update Chart
    if (_wattageHistory.length > 30) _wattageHistory.removeAt(0);
    _wattageHistory.add(FlSpotData(x: _chartXCounter++, y: _stats.wattage));

    // Update List
    if (_history.isEmpty ||
        _history.first.percentage != _stats.percentage ||
        _stats.isCharging) {
      _history.insert(0, _stats);
      if (_history.length > 50) _history.removeLast();
    }
  }

  // Real-world math estimation since OS doesn't easily expose 'minutes to full'
  int _estimateTimeToFull(
      double pct, double amps, int capacityMah, bool charging) {
    if (!charging || pct >= 100 || amps <= 0.1 || capacityMah <= 0) return 0;

    final remainingMah = capacityMah * ((100 - pct) / 100);
    final chargingMa = amps * 1000;

    final hoursRemaining = remainingMah / chargingMa;
    return (hoursRemaining * 60).round();
  }

  double _round(double value, int places) {
    final mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  String get chargeTimeString {
    final h = _stats.minutesToFull ~/ 60;
    final m = _stats.minutesToFull % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m} min';
    return _stats.percentage == 100 ? 'Full' : '--';
  }

  String get fullByTime {
    if (_stats.minutesToFull <= 0) return '--:--';
    final now = DateTime.now();
    final full = now.add(Duration(minutes: _stats.minutesToFull));
    final hour = full.hour % 12 == 0 ? 12 : full.hour % 12;
    final min = full.minute.toString().padLeft(2, '0');
    final period = full.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $period';
  }

  Color get tempColor {
    if (_stats.temperature <= 0) return const Color(0xFF1E1E1E); // No data
    if (_stats.temperature < 35) return const Color(0xFF1d9e75);
    if (_stats.temperature < 40) return const Color(0xFFFF9800);
    return const Color(0xFFFF4444);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _batterySubscription?.cancel();
    super.dispose();
  }
}

class FlSpotData {
  final double x;
  final double y;
  const FlSpotData({required this.x, required this.y});
}
