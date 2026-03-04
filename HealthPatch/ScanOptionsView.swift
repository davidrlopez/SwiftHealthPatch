import SwiftUI

struct ScanOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scanTimeout: Double = 10.0
    @State private var allowDuplicates = true
    @State private var scanInterval: Double = 5.0
    @State private var powerLevel: Double = 0.5
    
    var body: some View {
        List {
            // Configuración de Tiempo
            Section("Configuración de Tiempo") {
                HStack {
                    Text("Tiempo de Escaneo")
                    Spacer()
                    Text("\(Int(scanTimeout))s")
                        .foregroundColor(.secondary)
                }
                
                Slider(value: $scanTimeout, in: 5...30, step: 1)
                
                HStack {
                    Text("Intervalo entre Escaneos")
                    Spacer()
                    Text("\(Int(scanInterval))s")
                        .foregroundColor(.secondary)
                }
                
                Slider(value: $scanInterval, in: 1...60, step: 1)
            }
            
            // Configuración de Escaneo
            Section("Configuración de Escaneo") {
                Toggle("Permitir Duplicados", isOn: $allowDuplicates)
                    .tint(.green)
                
                Toggle("Escaneo Continuo", isOn: .constant(false))
                    .tint(.green)
                
                Toggle("Escaneo en Segundo Plano", isOn: .constant(true))
                    .tint(.green)
            }
            
            // Configuración de Potencia
            Section("Configuración de Potencia") {
                HStack {
                    Text("Nivel de Potencia")
                    Spacer()
                    Text("\(Int(powerLevel * 100))%")
                        .foregroundColor(.secondary)
                }
                
                Slider(value: $powerLevel, in: 0.1...1.0, step: 0.1)
                
                Text("Niveles más altos pueden detectar dispositivos más lejanos pero consumen más batería")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Configuración Avanzada
            Section("Configuración Avanzada") {
                NavigationLink("Filtros de Dispositivos") {
                    DeviceFiltersView()
                }
                
                NavigationLink("Configuración de Servicios") {
                    ServiceConfigurationView()
                }
                
                NavigationLink("Configuración de RSSI") {
                    RSSIConfigurationView()
                }
            }
            
            // Información del Sistema
            Section("Información del Sistema") {
                InfoRow(title: "Estado Bluetooth", value: "Activado")
                InfoRow(title: "Versión", value: "5.0")
                InfoRow(title: "Capacidades", value: "BLE Central")
                InfoRow(title: "Último Escaneo", value: "Hace 2 minutos")
            }
        }
        .navigationTitle("Opciones de Escaneo")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Aplicar") {
                    // Aplicar configuración de escaneo
                    print("Aplicando configuración de escaneo...")
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
    }
}

// Vistas auxiliares (placeholder)
struct DeviceFiltersView: View {
    var body: some View {
        Text("Filtros de Dispositivos")
            .navigationTitle("Filtros de Dispositivos")
    }
}

struct ServiceConfigurationView: View {
    var body: some View {
        Text("Configuración de Servicios")
            .navigationTitle("Configuración de Servicios")
    }
}

struct RSSIConfigurationView: View {
    var body: some View {
        Text("Configuración de RSSI")
            .navigationTitle("Configuración de RSSI")
    }
}

#Preview {
    NavigationView {
        ScanOptionsView()
    }
}
