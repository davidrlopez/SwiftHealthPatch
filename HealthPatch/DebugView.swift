import SwiftUI
import CoreBluetooth

struct DebugView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var environmentObjectsAvailable = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        // Información de la app
                        appInfoSection
                        
                        // Estado de autenticación
                        authenticationSection
                        
                        // Estado de Bluetooth
                        bluetoothSection
                        
                        // Estado del dispositivo
                        deviceSection
                        
                        // Botones de acción
                        actionButtons
                    }
                    .padding()
                }
            }
            .navigationTitle("Debug")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGray6))
        }
    }
    
    private func testEnvironmentObjects() {
        print("DebugView: Testing environment objects...")
        
        do {
            // Intentar acceder a los EnvironmentObjects
            let _ = bluetoothManager
            let _ = authManager
            
            environmentObjectsAvailable = true
            errorMessage = "Enviroments Unavailable"
            print("DebugView: All environment objects are available")
            
        } catch {
            environmentObjectsAvailable = false
            errorMessage = "Error accessing environment objects: \(error.localizedDescription)"
            print("DebugView: Error with environment objects: \(error)")
        }
    }
    
    private func clearAllData() {
        print("DebugView: Clearing all data...")
        
        // Limpiar UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        // Limpiar datos específicos
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.removeObject(forKey: "user_data")
        UserDefaults.standard.removeObject(forKey: "registeredDeviceUUID")
        
        print("DebugView: All data cleared")
    }
    
    // MARK: - App Info Section
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Información de la App")
                .font(.headline)
                .foregroundColor(.blue)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "Versión de la App",
                    subtitle: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
                    color: .blue,
                    showChevron: false
                ) {
                    // No action needed
                }
                
                Divider()
                    .padding(.leading, 50)
                
                SettingsRow(
                    icon: "hammer.fill",
                    title: "Build",
                    subtitle: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown",
                    color: .blue,
                    showChevron: false
                ) {
                    // No action needed
                }
                
                Divider()
                    .padding(.leading, 50)
                
                SettingsRow(
                    icon: "iphone",
                    title: "Dispositivo",
                    subtitle: UIDevice.current.model,
                    color: .blue,
                    showChevron: false
                ) {
                    // No action needed
                }
                
                Divider()
                    .padding(.leading, 50)
                
                SettingsRow(
                    icon: "gear",
                    title: "iOS Version",
                    subtitle: UIDevice.current.systemVersion,
                    color: .blue,
                    showChevron: false
                ) {
                    // No action needed
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Authentication Section
    private var authenticationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estado de Autenticación")
                .font(.headline)
                .foregroundColor(.green)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "person.circle.fill",
                    title: "Usuario Actual",
                    subtitle: authManager.currentUser?.email ?? "No autenticado",
                    color: .green,
                    showChevron: false
                ) {
                    // No action needed
                }
                
                Divider()
                    .padding(.leading, 50)
                
                SettingsRow(
                    icon: "checkmark.shield.fill",
                    title: "Estado de Autenticación",
                    subtitle: authManager.isAuthenticated ? "Autenticado" : "No autenticado",
                    color: .green,
                    showChevron: false
                ) {
                    // No action needed
                }
                
                Divider()
                    .padding(.leading, 50)
                
                SettingsRow(
                    icon: "arrow.clockwise",
                    title: "Cargando",
                    subtitle: authManager.isLoading ? "Sí" : "No",
                    color: .green,
                    showChevron: false
                ) {
                    // No action needed
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Bluetooth Section
    private var bluetoothSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estado de Bluetooth")
                .font(.headline)
                .foregroundColor(.blue)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "dot.radiowaves.left.and.right",
                    title: "Estado de Bluetooth",
                    subtitle: bluetoothStateDescription,
                    color: .blue,
                    showChevron: false
                ) {
                    // No action needed
                }
                
                Divider()
                    .padding(.leading, 50)
                
                SettingsRow(
                    icon: "wifi",
                    title: "Dispositivo Conectado",
                    subtitle: bluetoothManager.connectedDevice?.name ?? "Ninguno",
                    color: .blue,
                    showChevron: false
                ) {
                    // No action needed
                }
                
                Divider()
                    .padding(.leading, 50)
                
                SettingsRow(
                    icon: "magnifyingglass",
                    title: "Dispositivos Descubiertos",
                    subtitle: "\(bluetoothManager.discoveredDevices.count) dispositivos",
                    color: .blue,
                    showChevron: false
                ) {
                    // No action needed
                }
                
                Divider()
                    .padding(.leading, 50)
                
                SettingsRow(
                    icon: "exclamationmark.triangle.fill",
                    title: "Permisos Denegados",
                    subtitle: bluetoothManager.isPermissionDenied ? "Sí" : "No",
                    color: bluetoothManager.isPermissionDenied ? .red : .blue,
                    showChevron: false
                ) {
                    // No action needed
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Device Section
    private var deviceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Información del Sistema")
                .font(.headline)
                .foregroundColor(.orange)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "memorychip",
                    title: "Memoria Física",
                    subtitle: "\(ProcessInfo.processInfo.physicalMemory / 1024 / 1024) MB",
                    color: .orange,
                    showChevron: false
                ) {
                    // No action needed
                }
                
                Divider()
                    .padding(.leading, 50)
                
                SettingsRow(
                    icon: "cpu",
                    title: "Procesadores",
                    subtitle: "\(ProcessInfo.processInfo.processorCount) cores",
                    color: .orange,
                    showChevron: false
                ) {
                    // No action needed
                }
                
                Divider()
                    .padding(.leading, 50)
                
                SettingsRow(
                    icon: "clock",
                    title: "Tiempo de Sistema",
                    subtitle: "\(ProcessInfo.processInfo.systemUptime / 3600) horas",
                    color: .orange,
                    showChevron: false
                ) {
                    // No action needed
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button("Probar Environment Objects") {
                testEnvironmentObjects()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Button("Ir a Vista de Emergencia") {
                // Navegar a emergency view
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Button("Limpiar Todos los Datos") {
                clearAllData()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Settings Row
    private func SettingsRow(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        showChevron: Bool = true,
        showToggle: Bool = false,
        toggleValue: Bool = false,
        badge: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Badge
                if let badge = badge {
                    Text(badge)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                
                // Toggle or Chevron
                if showToggle {
                    Toggle("", isOn: .constant(toggleValue))
                        .labelsHidden()
                } else if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper Methods
    private var bluetoothStateDescription: String {
        switch bluetoothManager.bluetoothState {
        case .poweredOn:
            return "Encendido"
        case .poweredOff:
            return "Apagado"
        case .unauthorized:
            return "No autorizado"
        case .unknown:
            return "Desconocido"
        case .resetting:
            return "Reiniciando"
        case .unsupported:
            return "No soportado"
        @unknown default:
            return "Desconocido"
        }
    }
} 
