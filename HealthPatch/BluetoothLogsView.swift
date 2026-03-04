import SwiftUI

struct BluetoothLogsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLogLevel: LogLevel = .all
    @State private var showingClearConfirmation = false
    
    let logEntries = [
        LogEntry(timestamp: Date(), level: .info, message: "Iniciando escaneo Bluetooth", device: "N/A"),
        LogEntry(timestamp: Date().addingTimeInterval(-10), level: .info, message: "Dispositivo descubierto: iPhone 15", device: "iPhone 15"),
        LogEntry(timestamp: Date().addingTimeInterval(-20), level: .info, message: "Dispositivo descubierto: MacBook Pro", device: "MacBook Pro"),
        LogEntry(timestamp: Date().addingTimeInterval(-30), level: .warning, message: "Conexión perdida con parche", device: "HealthPatch"),
        LogEntry(timestamp: Date().addingTimeInterval(-40), level: .error, message: "Error al conectar con parche", device: "HealthPatch"),
        LogEntry(timestamp: Date().addingTimeInterval(-50), level: .info, message: "Parche reconectado exitosamente", device: "HealthPatch"),
        LogEntry(timestamp: Date().addingTimeInterval(-60), level: .debug, message: "RSSI actualizado: -45 dBm", device: "HealthPatch"),
        LogEntry(timestamp: Date().addingTimeInterval(-70), level: .info, message: "Escaneo completado", device: "N/A")
    ]
    
    var filteredLogs: [LogEntry] {
        if selectedLogLevel == .all {
            return logEntries
        } else {
            return logEntries.filter { $0.level == selectedLogLevel }
        }
    }
    
    var body: some View {
        List {
            // Filtros
            Section("Filtros") {
                Picker("Nivel de Log", selection: $selectedLogLevel) {
                    ForEach(LogLevel.allCases, id: \.self) { level in
                        Text(level.displayName).tag(level)
                    }
                }
                .pickerStyle(.segmented)
                
                HStack {
                    Text("Total de entradas")
                    Spacer()
                    Text("\(filteredLogs.count)")
                        .foregroundColor(.secondary)
                }
            }
            
            // Logs
            Section("Registros de Bluetooth") {
                ForEach(filteredLogs, id: \.timestamp) { entry in
                    LogEntryRow(entry: entry)
                }
            }
            
            // Acciones
            Section {
                Button("Limpiar Logs") {
                    showingClearConfirmation = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .frame(maxWidth: .infinity)
                
                Button("Exportar Logs") {
                    exportLogs()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
            
            // Información del Sistema
            Section("Información del Sistema") {
                InfoRow(title: "Última Limpieza", value: "Hace 2 horas")
                InfoRow(title: "Tamaño del Log", value: "2.4 MB")
                InfoRow(title: "Entradas Totales", value: "\(logEntries.count)")
                InfoRow(title: "Nivel de Debug", value: "Activado")
            }
        }
        .navigationTitle("Logs de Bluetooth")
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
                    // Actualizar logs
                    print("Actualizando logs...")
                }
                .fontWeight(.semibold)
            }
        }
        .alert("Limpiar Logs", isPresented: $showingClearConfirmation) {
            Button("Cancelar", role: .cancel) { }
            Button("Limpiar", role: .destructive) {
                clearLogs()
            }
        } message: {
            Text("¿Estás seguro de que quieres limpiar todos los logs? Esta acción no se puede deshacer.")
        }
    }
    
    private func clearLogs() {
        print("Limpiando logs...")
        // Lógica para limpiar logs
    }
    
    private func exportLogs() {
        print("Exportando logs...")
        // Lógica para exportar logs
    }
}

// MARK: - Log Entry Row
struct LogEntryRow: View {
    let entry: LogEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: entry.level.iconName)
                    .foregroundColor(entry.level.color)
                    .font(.caption)
                
                Text(entry.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if entry.device != "N/A" {
                    Text(entry.device)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            
            Text(entry.message)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Log Entry Model
struct LogEntry {
    let timestamp: Date
    let level: LogLevel
    let message: String
    let device: String
}

// MARK: - Log Level Enum
enum LogLevel: CaseIterable {
    case all, debug, info, warning, error
    
    var displayName: String {
        switch self {
        case .all: return "Todos"
        case .debug: return "Debug"
        case .info: return "Info"
        case .warning: return "Advertencia"
        case .error: return "Error"
        }
    }
    
    var iconName: String {
        switch self {
        case .all: return "list.bullet"
        case .debug: return "ladybug"
        case .info: return "info.circle"
        case .warning: return "exclamationmark.triangle"
        case .error: return "xmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .primary
        case .debug: return .purple
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        }
    }
}

#Preview {
    NavigationView {
        BluetoothLogsView()
    }
}
