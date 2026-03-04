import SwiftUI

struct PrivacySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var shareHealthData = false
    @State private var shareUsageAnalytics = false
    @State private var shareDiagnosticData = false
    @State private var shareLocationData = true
    @State private var shareDeviceInfo = true
    @State private var allowDataCollection = true
    @State private var allowThirdPartyAccess = false
    @State private var dataRetentionPeriod = 1 // años
    @State private var showPrivacyReport = false
    
    var body: some View {
        List {
            // Compartir Datos de Salud
            Section("Datos de Salud") {
                Toggle("Compartir Datos de Salud", isOn: $shareHealthData)
                    .tint(.green)
                
                if shareHealthData {
                    Text("Los datos de salud se compartirán de forma anónima para mejorar la precisión del parche")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                NavigationLink("Configurar Datos de Salud") {
                    HealthDataSettingsView()
                }
            }
            
            // Análisis de Uso
            Section("Análisis de Uso") {
                Toggle("Compartir Análisis de Uso", isOn: $shareUsageAnalytics)
                    .tint(.green)
                
                if shareUsageAnalytics {
                    Text("Los datos de uso se utilizan para mejorar la experiencia de la aplicación")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                NavigationLink("Configurar Análisis") {
                    AnalyticsSettingsView()
                }
            }
            
            // Datos de Diagnóstico
            Section("Datos de Diagnóstico") {
                Toggle("Compartir Datos de Diagnóstico", isOn: $shareDiagnosticData)
                    .tint(.green)
                
                if shareDiagnosticData {
                    Text("Los datos de diagnóstico ayudan a resolver problemas técnicos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                NavigationLink("Configurar Diagnósticos") {
                    DiagnosticSettingsView()
                }
            }
            
            // Ubicación y Dispositivo
            Section("Ubicación y Dispositivo") {
                Toggle("Compartir Datos de Ubicación", isOn: $shareLocationData)
                    .tint(.green)
                
                Toggle("Compartir Información del Dispositivo", isOn: $shareDeviceInfo)
                    .tint(.green)
            }
            
            // Control de Datos
            Section("Control de Datos") {
                Toggle("Permitir Recolección de Datos", isOn: $allowDataCollection)
                    .tint(.green)
                
                Toggle("Permitir Acceso de Terceros", isOn: $allowThirdPartyAccess)
                    .tint(.green)
                
                HStack {
                    Text("Período de Retención")
                    Spacer()
                    Picker("", selection: $dataRetentionPeriod) {
                        Text("1 año").tag(1)
                        Text("2 años").tag(2)
                        Text("3 años").tag(3)
                        Text("5 años").tag(5)
                        Text("Indefinido").tag(0)
                    }
                    .pickerStyle(.menu)
                }
            }
            
            // Acceso a Datos
            Section("Acceso a Datos") {
                NavigationLink("Descargar Mis Datos") {
                    DataDownloadView()
                }
                
                NavigationLink("Eliminar Mis Datos") {
                    DataDeletionView()
                }
                
                NavigationLink("Reporte de Privacidad") {
                    PrivacyReportView()
                }
            }
            
            // Configuración de Seguridad
            Section("Configuración de Seguridad") {
                NavigationLink("Configuración de Cifrado") {
                    EncryptionSettingsView()
                }
                
                NavigationLink("Configuración de Autenticación") {
                    AuthenticationSettingsView()
                }
                
                NavigationLink("Configuración de Auditoría") {
                    AuditSettingsView()
                }
            }
            
            // Configuración de Terceros
            Section("Configuración de Terceros") {
                NavigationLink("Aplicaciones Conectadas") {
                    ConnectedAppsView()
                }
                
                NavigationLink("Permisos de API") {
                    APIPermissionsView()
                }
                
                NavigationLink("Configuración de Webhooks") {
                    WebhookSettingsView()
                }
            }
        }
        .navigationTitle("Privacidad y Seguridad")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Guardar") {
                    // Guardar configuración de privacidad
                    print("Guardando configuración de privacidad...")
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
    }
    
    private func resetToDefaults() {
        shareHealthData = false
        shareUsageAnalytics = false
        shareDiagnosticData = false
        shareLocationData = true
        shareDeviceInfo = true
        allowDataCollection = true
        allowThirdPartyAccess = false
        dataRetentionPeriod = 1
    }
    
    private func saveSettings() {
        // Lógica para guardar configuración
        print("Guardando configuración de privacidad...")
    }
}

// MARK: - Health Data Settings View
struct HealthDataSettingsView: View {
    var body: some View {
        Text("Configurar Datos de Salud")
            .navigationTitle("Configurar Datos de Salud")
    }
}

// MARK: - Analytics Settings View
struct AnalyticsSettingsView: View {
    var body: some View {
        Text("Configurar Análisis")
            .navigationTitle("Configurar Análisis")
    }
}

// MARK: - Diagnostic Settings View
struct DiagnosticSettingsView: View {
    var body: some View {
        Text("Configurar Diagnósticos")
            .navigationTitle("Configurar Diagnósticos")
    }
}

// MARK: - Data Download View
struct DataDownloadView: View {
    var body: some View {
        Text("Descargar Mis Datos")
            .navigationTitle("Descargar Mis Datos")
    }
}

// MARK: - Data Deletion View
struct DataDeletionView: View {
    var body: some View {
        Text("Eliminar Mis Datos")
            .navigationTitle("Eliminar Mis Datos")
    }
}

// MARK: - Privacy Report View
struct PrivacyReportView: View {
    var body: some View {
        Text("Reporte de Privacidad")
            .navigationTitle("Reporte de Privacidad")
    }
}

// MARK: - Encryption Settings View
struct EncryptionSettingsView: View {
    var body: some View {
        Text("Configuración de Cifrado")
            .navigationTitle("Configuración de Cifrado")
    }
}

// MARK: - Authentication Settings View
struct AuthenticationSettingsView: View {
    var body: some View {
        Text("Configuración de Autenticación")
            .navigationTitle("Configuración de Autenticación")
    }
}

// MARK: - Audit Settings View
struct AuditSettingsView: View {
    var body: some View {
        Text("Configuración de Auditoría")
            .navigationTitle("Configuración de Auditoría")
    }
}

// MARK: - Connected Apps View
struct ConnectedAppsView: View {
    var body: some View {
        Text("Aplicaciones Conectadas")
            .navigationTitle("Aplicaciones Conectadas")
    }
}

// MARK: - API Permissions View
struct APIPermissionsView: View {
    var body: some View {
        Text("Permisos de API")
            .navigationTitle("Permisos de API")
    }
}

// MARK: - Webhook Settings View
struct WebhookSettingsView: View {
    var body: some View {
        Text("Configuración de Webhooks")
            .navigationTitle("Configuración de Webhooks")
    }
}

#Preview {
    NavigationView {
        PrivacySettingsView()
    }
}
