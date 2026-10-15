# HealthPatch iOS App

![Platform](https://img.shields.io/badge/Platform-iOS-000000?logo=apple)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Blue?logo=swift)
![Bluetooth](https://img.shields.io/badge/CoreBluetooth-00599C?logo=bluetooth)

HealthPatch is an iOS demo app built with Swift and SwiftUI, the companion app for a simulated wearable medical patch. It connects to the patch over Bluetooth and shows its vital signs in real time, and it has the sign-in, device and settings screens of a real medical app.

## Features

- Real-time monitoring: `MonitoringView` shows the simulated vital signs coming from the connected patch.
- Bluetooth: a custom `BluetoothManager` uses CoreBluetooth to scan for peripherals, connect and receive data. `MockPeripheral` stands in for the patch when there is no hardware (see [Bluetooth simulation](#bluetooth-simulation)).
- Authentication: sign-up, login and forgot-password flows in `AuthenticationManager`, with Apple Sign-In and Google Sign-In.
- Device management: `DeviceListView` manages the connected patches, and `FindMyView` helps locate a misplaced one.
- Settings and profile: `UserAccountView`, `PrivacySettingsView`, `NotificationSettingsView`, `EmergencyView` and `FamilySharingView`.
- Debugging: `DebugView` and `BluetoothLogsView` track connection states and data payloads during development.

## Tech stack

- Swift 5+
- SwiftUI
- CoreBluetooth
- MVVM architecture

## Getting started

You need macOS with Xcode 15 or later. The deployment target is iOS 16.0+.

1. Clone this repository.
2. Open `HealthPatch.xcodeproj` in Xcode.
3. Select your target device or simulator.
4. Press `Cmd + R` to build and run.

To run it on a physical device you need a valid Apple Developer account set up in Xcode under Signing & Capabilities.

## Bluetooth simulation

The app includes a mock peripheral so it can be developed and tested without the physical patch. When the app scans for devices, a simulated "HealthPatch" appears and broadcasts dummy telemetry (heart rate, temperature, etc.), so the UI and logic can be tested with no hardware connected.

## Context

Built in under two weeks with no prior Swift experience. At the time the only background was basic C, self-taught C# from the OracleManager project, and SQL.

The app was developed during the same professional internship as OracleManager, for an investor demo the company was preparing to present in Denmark. It had to be a polished, working iOS app that could show the wearable patch concept to people outside the company, and it was built from scratch against a hard deadline, in a language and framework learned on the job.

SwiftUI, CoreBluetooth, MVVM and the Apple authentication stack were all learned during development. The mock peripheral was built so the live demo could be convincing without the physical hardware.

## License

Apache-2.0, see [LICENSE](LICENSE). The project is meant for demonstration and as a portfolio piece. You are welcome to read the code and reuse the Bluetooth and UI patterns in your own SwiftUI projects.
