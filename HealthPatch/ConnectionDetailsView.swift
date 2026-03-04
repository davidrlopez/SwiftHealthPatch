import SwiftUI
import CoreBluetooth

struct ConnectionDetailsView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            if let connectedDevice = bluetoothManager.connectedDevice {
                // Información del Dispositivo
                Section("Información del Dispositivo") {
                    InfoRow(title: "Nombre", value: connectedDevice.name ?? "Desconocido")
                    InfoRow(title: "ID", value: connectedDevice.identifier.uuidString)
                    InfoRow(title: "Tipo", value: deviceTypeDescription(for: connectedDevice))
                    InfoRow(title: "Estado", value: "Conectado", color: .green)
                }
                
                // Métricas de Conexión
                Section("Métricas de Conexión") {
                    InfoRow(title: "RSSI", value: "\(connectedDevice.rssi) dBm", color: signalColor(for: connectedDevice.rssi))
                    InfoRow(title: "Calidad de Señal", value: signalQualityDescription(for: connectedDevice.rssi), color: signalColor(for: connectedDevice.rssi))
                    InfoRow(title: "Distancia Estimada", value: estimateDistance(rssi: connectedDevice.rssi))
                    
                    if let batteryLevel = connectedDevice.batteryLevel {
                        InfoRow(title: "Nivel de Batería", value: "\(Int(batteryLevel * 100))%", color: batteryColor(for: batteryLevel))
                    }
                }
                
                // Estadísticas de Conexión
                Section("Estadísticas de Conexión") {
                    InfoRow(title: "Tiempo Conectado", value: "2h 34m")
                    InfoRow(title: "Última Actualización", value: "Ahora")
                    InfoRow(title: "Paquetes Transmitidos", value: "1,247")
                    InfoRow(title: "Paquetes Recibidos", value: "1,245")
                    InfoRow(title: "Tasa de Error", value: "0.16%", color: .green)
                }
                
                // Servicios y Características
                Section("Servicios y Características") {
                    NavigationLink("Ver Servicios") {
                        DeviceServicesView()
                    }
                    
                    NavigationLink("Ver Características") {
                        DeviceCharacteristicsView()
                    }
                    
                    NavigationLink("Logs de Comunicación") {
                        CommunicationLogsView()
                    }
                }
                
                // Acciones
                Section("Acciones") {
                    Button("Reconectar") {
                        // Lógica de reconexión
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    
                    Button("Probar Conexión") {
                        // Lógica de prueba
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    
                    Button("Desconectar") {
                        bluetoothManager.disconnect()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .frame(maxWidth: .infinity)
                }
            } else {
                // Sin Dispositivo Conectado
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No hay dispositivo conectado")
                            .font(.headline)
                        
                        Text("Conecta un dispositivo para ver los detalles de la conexión")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Conectar Dispositivo") {
                            // Abrir lista de dispositivos
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
        }
        .navigationTitle("Detalles de Conexión")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Reconectar") {
                    // Lógica de reconexión
                    print("Reconectando dispositivo...")
                }
                .fontWeight(.semibold)
            }
        }
    }
    
    private func deviceTypeDescription(for device: AnyPeripheral) -> String {
        if case .mock = device.base {
            return "Dispositivo de Prueba (Demo)"
        } else {
            return "Dispositivo Bluetooth Real"
        }
    }
    
    private func signalQualityDescription(for rssi: Int) -> String {
        if rssi > -50 { return "Excelente" }
        else if rssi > -60 { return "Muy Buena" }
        else if rssi > -70 { return "Buena" }
        else if rssi > -80 { return "Regular" }
        else { return "Débil" }
    }
    
    private func signalColor(for rssi: Int) -> Color {
        if rssi > -50 { return .green }
        else if rssi > -70 { return .orange }
        else { return .red }
    }
    
    private func batteryColor(for level: Double) -> Color {
        if level > 0.7 { return .green }
        else if level > 0.3 { return .orange }
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

// MARK: - Device Services View
struct DeviceServicesView: View {
    var body: some View {
        Text("Servicios del Dispositivo")
            .navigationTitle("Servicios")
    }
}

// MARK: - Device Characteristics View
struct DeviceCharacteristicsView: View {
    var body: some View {
        Text("Características del Dispositivo")
            .navigationTitle("Características")
    }
}

// MARK: - Communication Logs View
struct CommunicationLogsView: View {
    var body: some View {
        Text("Logs de Comunicación")
            .navigationTitle("Logs de Comunicación")
    }
}

#Preview {
    ConnectionDetailsView()
        .environmentObject(BluetoothManager())
}
