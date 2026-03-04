import SwiftUI
import CoreBluetooth

struct LocationInfoView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingMap = false
    @State private var locationHistory: [LocationEntry] = [
        LocationEntry(timestamp: Date(), rssi: -45, distance: "Cerca", location: "Sala de estar"),
        LocationEntry(timestamp: Date().addingTimeInterval(-3600), rssi: -52, distance: "Mediana", location: "Cocina"),
        LocationEntry(timestamp: Date().addingTimeInterval(-7200), rssi: -38, distance: "Muy cerca", location: "Sala de estar"),
        LocationEntry(timestamp: Date().addingTimeInterval(-10800), rssi: -65, distance: "Lejos", location: "Dormitorio")
    ]
    
    var body: some View {
        List {
            if let connectedDevice = bluetoothManager.connectedDevice {
                // Estado Actual
                Section("Estado Actual") {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text("Ubicación del Parche")
                                .font(.headline)
                            Text("Última actualización: Ahora")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Actualizar") {
                            // Lógica de actualización
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                // Información de Ubicación
                Section("Información de Ubicación") {
                    InfoRow(title: "Dispositivo", value: connectedDevice.name ?? "Desconocido")
                    InfoRow(title: "RSSI Actual", value: "\(connectedDevice.rssi) dBm", color: signalColor(for: connectedDevice.rssi))
                    InfoRow(title: "Distancia Estimada", value: estimateDistance(rssi: connectedDevice.rssi))
                    InfoRow(title: "Habitación", value: "Sala de estar")
                    InfoRow(title: "Precisión", value: "±2 metros")
                }
                
                // Mapa de Ubicación
                Section("Mapa de Ubicación") {
                    VStack(spacing: 16) {
                        Image(systemName: "map")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        Text("Visualizar Ubicación")
                            .font(.headline)
                        
                        Text("Abre el mapa para ver la ubicación exacta del parche")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Abrir Mapa") {
                            showingMap = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                // Historial de Ubicación
                Section("Historial de Ubicación") {
                    ForEach(locationHistory, id: \.timestamp) { entry in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(entry.location)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(entry.timestamp, style: .time)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text(entry.distance)
                                    .font(.subheadline)
                                    .foregroundColor(signalColor(for: entry.rssi))
                                
                                Text("\(entry.rssi) dBm")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // Configuración de Ubicación
                Section("Configuración de Ubicación") {
                    NavigationLink("Configurar Habitaciones") {
                        RoomConfigurationView()
                    }
                    
                    NavigationLink("Configurar Alertas") {
                        LocationAlertsView()
                    }
                    
                    NavigationLink("Configurar Precisión") {
                        PrecisionSettingsView()
                    }
                }
            } else {
                // Sin Dispositivo Conectado
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "location.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No hay dispositivo conectado")
                            .font(.headline)
                        
                        Text("Conecta un dispositivo para ver la información de ubicación")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
        }
        .navigationTitle("Información de Ubicación")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Actualizar") {
                    // Actualizar ubicación
                    print("Actualizando ubicación...")
                }
                .fontWeight(.semibold)
            }
        }
        .sheet(isPresented: $showingMap) {
            MapView()
        }
    }
    
    private func signalColor(for rssi: Int) -> Color {
        if rssi > -50 { return .green }
        else if rssi > -60 { return .yellow }
        else if rssi > -70 { return .orange }
        else { return .red }
    }
    
    private func estimateDistance(rssi: Int) -> String {
        if rssi > -50 { return "Muy cerca (< 1m)" }
        else if rssi > -60 { return "Cerca (1-3m)" }
        else if rssi > -70 { return "Mediana (3-10m)" }
        else if rssi > -80 { return "Lejos (10-20m)" }
        else { return "Muy lejos (> 20m)" }
    }
}

// MARK: - Map View
struct MapView: View {
    var body: some View {
        Text("Mapa de Ubicación")
            .navigationTitle("Mapa de Ubicación")
    }
}

// MARK: - Room Configuration View
struct RoomConfigurationView: View {
    var body: some View {
        Text("Configurar Habitaciones")
            .navigationTitle("Configurar Habitaciones")
    }
}

// MARK: - Location Alerts View
struct LocationAlertsView: View {
    var body: some View {
        Text("Configurar Alertas")
            .navigationTitle("Configurar Alertas")
    }
}

// MARK: - Precision Settings View
struct PrecisionSettingsView: View {
    var body: some View {
        Text("Configurar Precisión")
            .navigationTitle("Configurar Precisión")
    }
}

// MARK: - Location Entry
struct LocationEntry {
    let timestamp: Date
    let rssi: Int
    let distance: String
    let location: String
}

#Preview {
    NavigationView {
        LocationInfoView()
            .environmentObject(BluetoothManager())
    }
}
