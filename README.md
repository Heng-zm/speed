# ⚡ SpeedCharge — Battery Monitor App

A clean, real-time battery monitoring app for iOS built with Flutter.
Inspired by AOD (Always On Display) charging UIs with live wattage readings.

---

## 📱 Features

- **Animated Charge Ring** — Circular progress ring with glow effect
- **Live Wattage** — Real-time power draw with pulsing indicator
- **Stats Grid** — Voltage, Temperature, Current, Capacity
- **Wattage Chart** — Live fl_chart graph of recent readings
- **History Log** — Session-by-session charge log
- **Settings** — AOD toggle, alerts, heat warnings (CupertinoSwitch)
- **battery_plus** — Real battery level & state via platform API
- **Provider** — Reactive state management throughout

---

## 🚀 Setup

### Requirements
- Flutter 3.19+ (Dart 3.x)
- Xcode 15+ for iOS builds
- iOS device or simulator (battery_plus works on both)

### Install & Run

```bash
cd speedcharge
flutter pub get
flutter run
```

### Run on iOS Device

```bash
open ios/Runner.xcworkspace
# Set your Team in Xcode Signing & Capabilities
flutter run --release
```

---

## 📦 Key Dependencies

| Package | Purpose |
|---|---|
| `battery_plus` | Real battery level & charging state |
| `fl_chart` | Live wattage line chart |
| `percent_indicator` | Circular progress (alternative) |
| `provider` | State management |
| `google_fonts` | DM Sans + Space Grotesk fonts |

---

## 🗂 Project Structure

```
lib/
├── main.dart                    # App entry, shell navigation
├── models/
│   ├── app_theme.dart           # Colors, ThemeData
│   ├── battery_provider.dart    # BatteryProvider (ChangeNotifier)
│   └── battery_stats.dart       # BatteryStats data model
├── screens/
│   ├── charge_screen.dart       # Main charge view
│   ├── stats_screen.dart        # Chart + power details
│   ├── history_screen.dart      # Session log
│   └── profile_screen.dart      # Settings
└── widgets/
    ├── charge_ring.dart         # Custom painted charge ring
    ├── stat_card.dart           # Reusable metric card
    └── wattage_chart.dart       # fl_chart wrapper
```

---

## 🎨 Design System

- **Background**: `#0A0A0A`
- **Cards**: `#111111`
- **Accent Green**: `#1D9E75` / `#5DCAA5`
- **Fonts**: DM Sans (body) + Space Grotesk (numbers/headers)
- **iOS-native**: `CupertinoSwitch`, system safe areas, bounce scrolling

---

## ⚙️ Real Battery vs Simulated

The app uses `battery_plus` for real battery level and charge state.
Voltage, current, wattage, and temperature are **simulated** with realistic
variance — iOS does not expose these via public APIs.

For real hardware data, pair with a USB power meter and BLE integration.

---

## 📝 License

MIT — free to use and modify.
