import Foundation
import CoreBluetooth

struct MockPeripheral: Identifiable {
    let id = UUID()
    let name: String
    let batteryLevel: Double
    let rssi: Int
    let isConnected: Bool = false
    
    // Propiedades adicionales para demo
    let deviceType: DeviceType
    let firmwareVersion: String
    let lastSeen: Date
    
    init(name: String, batteryLevel: Double, rssi: Int, deviceType: DeviceType = .medicalPatch, firmwareVersion: String = "2.1.0") {
        self.name = name
        self.batteryLevel = batteryLevel
        self.rssi = rssi
        self.deviceType = deviceType
        self.firmwareVersion = firmwareVersion
        self.lastSeen = Date()
    }
    
    enum DeviceType: String, CaseIterable {
        case medicalPatch = "Medical Patch"
        case healthMonitor = "Health Monitor"
        case fitnessTracker = "Fitness Tracker"
        case sensorDevice = "Sensor Device"
        
        var icon: String {
            switch self {
            case .medicalPatch: return "cross.circle.fill"
            case .healthMonitor: return "heart.circle.fill"
            case .fitnessTracker: return "figure.walk.circle.fill"
            case .sensorDevice: return "waveform.path.ecg.circle.fill"
            }
        }
        
        var color: String {
            switch self {
            case .medicalPatch: return "red"
            case .healthMonitor: return "blue"
            case .fitnessTracker: return "green"
            case .sensorDevice: return "orange"
            }
        }
    }
}

// MARK: - Mock Devices Factory
extension MockPeripheral {
    static let demoDevices: [MockPeripheral] = [
        MockPeripheral(
            name: "HealthPatch v2.1",
            batteryLevel: 0.88,
            rssi: -45,
            deviceType: .medicalPatch,
            firmwareVersion: "2.1.0"
        )
    ]
}
