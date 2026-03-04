import SwiftUI
import CoreBluetooth

struct FindMyView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var findMyEnabled = true
    @State private var networkSharing = true
    @State private var offlineFinding = true
    @State private var locationHistory = true
    @State private var showingMap = false
    @State private var showingLocationHistory = false
    @State private var isSearching = false
    
    let locationHistoryData = [
        LocationHistoryEntry(timestamp: Date(), location: "Sala de estar", coordinates: "40.7128, -74.0060"),
        LocationHistoryEntry(timestamp: Date().addingTimeInterval(-3600), location: "Cocina", coordinates: "40.7128, -74.0060"),
        LocationHistoryEntry(timestamp: Date().addingTimeInterval(-7200), location: "Dormitorio", coordinates: "40.7128, -74.0060"),
        LocationHistoryEntry(timestamp: Date().addingTimeInterval(-10800), location: "Oficina", coordinates: "40.7128, -74.0060")
    ]
    
    var body: some View {
        List {
            // Estado de Find My
            Section {
                HStack {
                    Image(systemName: "location.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text("Buscar")
                            .font(.headline)
                        Text("Localiza tu parche HealthPatch en caso de pérdida")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $findMyEnabled)
                        .labelsHidden()
                        .tint(.green)
                }
            }
            
            if findMyEnabled {
                // Estado Actual del Parche
                if let connectedDevice = bluetoothManager.connectedDevice {
                    Section("Estado Actual del Parche") {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading) {
                                Text("Parche Conectado")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("Última ubicación: Sala de estar")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Buscar Ahora") {
                                startSearch()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                } else {
                    Section("Estado del Parche") {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            
                            VStack(alignment: .leading) {
                                Text("Parche No Conectado")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("No se puede localizar el parche")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Conectar Parche") {
                                // Lógica para conectar
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
                
                // Configuración de Find My
                Section("Configuración de Find My") {
                    Toggle("Compartir en Red Find My", isOn: $networkSharing)
                        .tint(.green)
                    
                    if networkSharing {
                        Text("Tu parche será visible en la red Find My de Apple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Toggle("Búsqueda Sin Conexión", isOn: $offlineFinding)
                        .tint(.green)
                    
                    if offlineFinding {
                        Text("Otros dispositivos Apple pueden ayudar a encontrar tu parche")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Toggle("Historial de Ubicación", isOn: $locationHistory)
                        .tint(.green)
                    
                    if locationHistory {
                        Text("Se guardará el historial de ubicaciones del parche")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Acciones de Búsqueda
                Section("Acciones de Búsqueda") {
                    Button("Buscar Parche") {
                        startSearch()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    
                    Button("Marcar como Perdido") {
                        markAsLost()
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    
                    Button("Reproducir Sonido") {
                        playSound()
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
                
                // Mapa e Historial
                Section("Mapa e Historial") {
                    NavigationLink("Ver en Mapa") {
                        FindMyMapView()
                    }
                    
                    NavigationLink("Historial de Ubicaciones") {
                        LocationHistoryView()
                    }
                    
                    NavigationLink("Configurar Zonas") {
                        ZoneConfigurationView()
                    }
                }
                
                // Configuración Avanzada
                Section("Configuración Avanzada") {
                    NavigationLink("Configuración de Red") {
                        NetworkConfigurationView()
                    }
                    
                    NavigationLink("Configuración de Privacidad") {
                        PrivacyConfigurationView()
                    }
                    
                    NavigationLink("Configuración de Notificaciones") {
                        NotificationConfigurationView()
                    }
                }
            } else {
                // Información cuando está desactivado
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "location.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("Buscar Desactivado")
                            .font(.headline)
                        
                        Text("Activa esta función para poder localizar tu parche en caso de pérdida")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
        }
        .navigationTitle("Buscar Parche")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Buscar") {
                    // Iniciar búsqueda del parche
                    print("Iniciando búsqueda del parche...")
                }
                .fontWeight(.semibold)
            }
        }
        .sheet(isPresented: $showingMap) {
            FindMyMapView()
        }
        .sheet(isPresented: $showingLocationHistory) {
            LocationHistoryView()
        }
    }
    
    private func startSearch() {
        isSearching = true
        print("Iniciando búsqueda del parche...")
        // Lógica de búsqueda
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isSearching = false
        }
    }
    
    private func markAsLost() {
        print("Marcando parche como perdido...")
        // Lógica para marcar como perdido
    }
    
    private func playSound() {
        // Lógica para sonar alarma
        print("Sonando alarma del parche...")
    }
}

// MARK: - Find My Map View
struct FindMyMapView: View {
    var body: some View {
        Text("Mapa de Find My")
            .navigationTitle("Mapa de Find My")
    }
}

// MARK: - Location History View
struct LocationHistoryView: View {
    var body: some View {
        Text("Historial de Ubicaciones")
            .navigationTitle("Historial de Ubicaciones")
    }
}

// MARK: - Zone Configuration View
struct ZoneConfigurationView: View {
    var body: some View {
        Text("Configurar Zonas")
            .navigationTitle("Configurar Zonas")
    }
}

// MARK: - Network Configuration View
struct NetworkConfigurationView: View {
    var body: some View {
        Text("Configuración de Red")
            .navigationTitle("Configuración de Red")
    }
}

// MARK: - Privacy Configuration View
struct PrivacyConfigurationView: View {
    var body: some View {
        Text("Configuración de Privacidad")
            .navigationTitle("Configuración de Privacidad")
    }
}

// MARK: - Notification Configuration View
struct NotificationConfigurationView: View {
    var body: some View {
        Text("Configuración de Notificaciones")
            .navigationTitle("Configuración de Notificaciones")
    }
}

// MARK: - Location History Entry
struct LocationHistoryEntry {
    let timestamp: Date
    let location: String
    let coordinates: String
}

#Preview {
    NavigationView {
        FindMyView()
            .environmentObject(BluetoothManager())
    }
}
