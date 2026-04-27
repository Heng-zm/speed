class BatteryStats {
  final double percentage;
  final double voltage;
  final double temperature;
  final double wattage;
  final double current;
  final int capacityMah;
  final bool isCharging;
  final bool isFastCharging;
  final int minutesToFull;
  final DateTime timestamp;

  // Added 'const' to allow for compile-time optimizations
  const BatteryStats({
    required this.percentage,
    required this.voltage,
    required this.temperature,
    required this.wattage,
    required this.current,
    required this.capacityMah,
    required this.isCharging,
    required this.isFastCharging,
    required this.minutesToFull,
    required this.timestamp,
  });

  BatteryStats copyWith({
    double? percentage,
    double? voltage,
    double? temperature,
    double? wattage,
    double? current,
    int? capacityMah,
    bool? isCharging,
    bool? isFastCharging,
    int? minutesToFull,
    DateTime? timestamp,
  }) {
    return BatteryStats(
      percentage: percentage ?? this.percentage,
      voltage: voltage ?? this.voltage,
      temperature: temperature ?? this.temperature,
      wattage: wattage ?? this.wattage,
      current: current ?? this.current,
      capacityMah: capacityMah ?? this.capacityMah,
      isCharging: isCharging ?? this.isCharging,
      isFastCharging: isFastCharging ?? this.isFastCharging,
      minutesToFull: minutesToFull ?? this.minutesToFull,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Prevents unnecessary UI rebuilds by comparing actual data values
  // instead of memory references.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BatteryStats &&
        other.percentage == percentage &&
        other.voltage == voltage &&
        other.temperature == temperature &&
        other.wattage == wattage &&
        other.current == current &&
        other.capacityMah == capacityMah &&
        other.isCharging == isCharging &&
        other.isFastCharging == isFastCharging &&
        other.minutesToFull == minutesToFull &&
        other.timestamp == timestamp;
  }

  // Required when overriding ==. Object.hash is highly optimized in modern Dart.
  @override
  int get hashCode {
    return Object.hash(
      percentage,
      voltage,
      temperature,
      wattage,
      current,
      capacityMah,
      isCharging,
      isFastCharging,
      minutesToFull,
      timestamp,
    );
  }

  // Makes debugging and logging exponentially easier
  @override
  String toString() {
    return 'BatteryStats(percentage: $percentage, voltage: $voltage, temperature: $temperature, wattage: $wattage, current: $current, capacityMah: $capacityMah, isCharging: $isCharging, isFastCharging: $isFastCharging, minutesToFull: $minutesToFull, timestamp: $timestamp)';
  }
}
