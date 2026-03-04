import SwiftUI

@main
struct HealthPatchApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var bluetoothManager = BluetoothManager()

    var body: some Scene {
        WindowGroup {
            AppFlowView()
                .environmentObject(authManager)
                .environmentObject(bluetoothManager)
                .onAppear {
                    print("HealthPatchApp: App launched successfully")
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    print("HealthPatchApp: App became active")
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    print("HealthPatchApp: App will resign active")
                }
        }
    }
}

