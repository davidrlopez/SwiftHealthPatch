# HealthPatch iOS App

![Platform](https://img.shields.io/badge/Platform-iOS-000000?logo=apple)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Blue?logo=swift)
![Bluetooth](https://img.shields.io/badge/CoreBluetooth-00599C?logo=bluetooth)

HealthPatch is a comprehensive iOS demonstration application built with Swift and SwiftUI. It serves as the companion app for a simulated wearable medical health patch, showcasing how a modern medical app integrates with hardware, manages user data, and handles real-time monitoring.

## Features

- **Real-Time Monitoring:** Dashboard (`MonitoringView`) to display simulated vital signs and real-time data from the connected patch.
- **Bluetooth Integration:** Utilizes `CoreBluetooth` via a custom `BluetoothManager` to scan, connect, and receive data from peripherals. Includes a `MockPeripheral` to simulate patch behavior without needing actual hardware.
- **Authentication:** Complete sign-up, login, and forgot password flows (`AuthenticationManager`), including integration for Apple Sign-In and Google Sign-In.
- **Device Management:** A dedicated `DeviceListView` to manage connected patches, along with a "Find My" feature (`FindMyView`) to locate misplaced hardware.
- **User Settings & Profile:** Extensive settings including `UserAccountView`, `PrivacySettingsView`, `NotificationSettingsView`, `EmergencyView`, and `FamilySharingView`.
- **Debugging & Logs:** Built-in `DebugView` and `BluetoothLogsView` for tracking connection states and data payloads during development.

## Tech Stack

- **Language:** Swift 5+
- **UI Framework:** SwiftUI
- **Hardware Integration:** CoreBluetooth
- **Architecture:** MVVM (Model-View-ViewModel)

## Getting Started

### Prerequisites

- macOS with Xcode 15 or later.
- iOS 16.0+ deployment target.

### Installation & Running

1. Clone this repository.
2. Open `HealthPatch.xcodeproj` in Xcode.
3. Select your target device or simulator.
4. Press `Cmd + R` to build and run the application.

_Note: If running on a physical device, ensure you have a valid Apple Developer account configured in the Xcode Signing & Capabilities tab._

## Bluetooth Simulation

To facilitate development and testing without physical hardware, the app includes a **Mock Peripheral** system. When the app scans for devices, it will automatically populate a simulated "HealthPatch" device that broadcasts dummy telemetry data (heart rate, temperature, etc.), allowing UI and logic testing in a fully disconnected environment.

## Context and History

## Context

Built in under two weeks with no prior Swift experience — the only background
at the time was basic C, self-taught C# from the OracleManager project, and SQL.

The app was developed during the same professional internship as OracleManager,
as a companion deliverable for an investor demo the company was preparing to
present in Denmark. The requirement was a polished, working iOS application
that could demonstrate a wearable medical patch concept to external stakeholders
— built from scratch, under a hard deadline, in a language and framework
learned on the job.

SwiftUI, CoreBluetooth, MVVM architecture, and the Apple authentication stack
were all picked up during development. The mock peripheral system was built
specifically to allow a convincing live demo without requiring physical hardware.

## License

This project is intended for demonstration and portfolio purposes. Feel free to explore the code, learn from the Bluetooth implementation, and adapt the UI patterns for your own SwiftUI projects.
