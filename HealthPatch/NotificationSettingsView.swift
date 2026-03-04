import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var hasUnsavedChanges = false
    @State private var showingSaveAlert = false
    
    // Configuración de Notificaciones
    @State private var healthAlerts = true
    @State private var connectionAlerts = true
    @State private var batteryAlerts = true
    @State private var locationAlerts = false
    @State private var emergencyAlerts = true
    @State private var weeklyReports = true
    @State private var dailySummaries = false
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    @State private var badgeEnabled = true
    @State private var quietHoursEnabled = false
    @State private var quietHoursStart = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date()
    @State private var quietHoursEnd = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
    
    var body: some View {
        List {
            // Tipos de Notificaciones
            Section("Tipos de Notificaciones") {
                Toggle("Alertas de Conexión", isOn: $connectionAlerts)
                    .tint(.green)
                
                Toggle("Alertas de Batería", isOn: $batteryAlerts)
                    .tint(.green)
                    .onChange(of: batteryAlerts) { _ in
                        hasUnsavedChanges = true
                    }
                
                Toggle("Alertas de Ubicación", isOn: $locationAlerts)
                    .tint(.green)
                    .onChange(of: locationAlerts) { _ in
                        hasUnsavedChanges = true
                    }
                
                Toggle("Alertas de Salud", isOn: $healthAlerts)
                    .tint(.green)
                    .onChange(of: healthAlerts) { _ in
                        hasUnsavedChanges = true
                    }
                
                Toggle("Alertas de Emergencia", isOn: $emergencyAlerts)
                    .tint(.green)
                    .onChange(of: emergencyAlerts) { _ in
                        hasUnsavedChanges = true
                    }
                
                Toggle("Reportes Semanales", isOn: $weeklyReports)
                    .tint(.green)
                    .onChange(of: weeklyReports) { _ in
                        hasUnsavedChanges = true
                    }
                
                Toggle("Resúmenes Diarios", isOn: $dailySummaries)
                    .tint(.green)
                    .onChange(of: dailySummaries) { _ in
                        hasUnsavedChanges = true
                    }
            }
            
            // Configuración de Sonido y Vibración
            Section("Sonido y Vibración") {
                Toggle("Sonido", isOn: $soundEnabled)
                    .tint(.green)
                    .onChange(of: soundEnabled) { _ in
                        hasUnsavedChanges = true
                    }
                
                Toggle("Vibración", isOn: $vibrationEnabled)
                    .tint(.green)
                    .onChange(of: vibrationEnabled) { _ in
                        hasUnsavedChanges = true
                    }
                
                Toggle("Badges", isOn: $badgeEnabled)
                    .tint(.green)
                    .onChange(of: badgeEnabled) { _ in
                        hasUnsavedChanges = true
                    }
                
                if soundEnabled {
                    NavigationLink("Seleccionar Sonido") {
                        SoundSelectionView()
                    }
                }
            }
            
            // Horas Silenciosas
            Section("Horas Silenciosas") {
                Toggle("Activar Horas Silenciosas", isOn: $quietHoursEnabled)
                    .tint(.green)
                    .onChange(of: quietHoursEnabled) { _ in
                        hasUnsavedChanges = true
                    }
                
                if quietHoursEnabled {
                    HStack {
                        Text("Inicio")
                        Spacer()
                        DatePicker("", selection: $quietHoursStart, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .onChange(of: quietHoursStart) { _ in
                                hasUnsavedChanges = true
                            }
                    }
                    
                    HStack {
                        Text("Fin")
                        Spacer()
                        DatePicker("", selection: $quietHoursEnd, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .onChange(of: quietHoursEnd) { _ in
                                hasUnsavedChanges = true
                            }
                    }
                    
                    Text("Durante las horas silenciosas, solo se mostrarán notificaciones críticas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Configuración de Frecuencia
            Section("Frecuencia de Notificaciones") {
                NavigationLink("Configurar Frecuencia") {
                    FrequencySettingsView()
                }
                
                NavigationLink("Configurar Prioridades") {
                    PrioritySettingsView()
                }
            }
            
            // Configuración de Aplicaciones
            Section("Configuración de Aplicaciones") {
                NavigationLink("Notificaciones del Sistema") {
                    SystemNotificationsView()
                }
                
                NavigationLink("Configuración de Badges") {
                    BadgeSettingsView()
                }
            }
            
            // Configuración de Contactos
            Section("Configuración de Contactos") {
                NavigationLink("Contactos de Emergencia") {
                    EmergencyContactsView()
                }
                
                NavigationLink("Grupos de Notificación") {
                    NotificationGroupsView()
                }
            }
            
            // Configuración de Dispositivos
            Section("Configuración de Dispositivos") {
                NavigationLink("Configuración por Dispositivo") {
                    DeviceNotificationSettingsView()
                }
                
                NavigationLink("Sincronización de Configuración") {
                    NotificationSyncView()
                }
            }
        }
        .navigationTitle("Configuración de Notificaciones")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") {
                    if hasUnsavedChanges {
                        showingSaveAlert = true
                    } else {
                        dismiss()
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Guardar") {
                    saveNotificationSettings()
                }
                .fontWeight(.semibold)
                .disabled(!hasUnsavedChanges)
            }
        }
        .alert("Cambios sin Guardar", isPresented: $showingSaveAlert) {
            Button("Descartar Cambios", role: .destructive) {
                dismiss()
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Tienes cambios sin guardar en la configuración de notificaciones. ¿Estás seguro de que quieres salir?")
        }
    }
    
    private func resetToDefaults() {
        connectionAlerts = true
        batteryAlerts = true
        locationAlerts = false
        healthAlerts = true
        emergencyAlerts = true
        weeklyReports = true
        dailySummaries = false
        soundEnabled = true
        vibrationEnabled = true
        badgeEnabled = true
        quietHoursEnabled = false
        quietHoursStart = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date()
        quietHoursEnd = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
        
        hasUnsavedChanges = true
    }
    
    private func saveNotificationSettings() {
        // Aquí se guardarían los cambios en el sistema
        print("Guardando configuración de notificaciones...")
        print("Alertas de salud: \(healthAlerts)")
        print("Alertas de conexión: \(connectionAlerts)")
        print("Alertas de batería: \(batteryAlerts)")
        print("Alertas de ubicación: \(locationAlerts)")
        print("Alertas de emergencia: \(emergencyAlerts)")
        print("Reportes semanales: \(weeklyReports)")
        print("Resúmenes diarios: \(dailySummaries)")
        print("Sonido habilitado: \(soundEnabled)")
        print("Vibración habilitada: \(vibrationEnabled)")
        print("Badges habilitados: \(badgeEnabled)")
        
        hasUnsavedChanges = false
        dismiss()
    }
}

// MARK: - Sound Selection View
struct SoundSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    
    let sounds = ["Predeterminado", "Campana", "Chime", "Cristal", "Nota", "Ping", "Pop", "Purr", "Suspenso"]
    @State private var selectedSound = "Predeterminado"
    
    var body: some View {
        List {
            ForEach(sounds, id: \.self) { sound in
                HStack {
                    Text(sound)
                    Spacer()
                    if selectedSound == sound {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedSound = sound
                }
            }
        }
        .navigationTitle("Seleccionar Sonido")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Listo") {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Frequency Settings View
struct FrequencySettingsView: View {
    var body: some View {
        Text("Configuración de Frecuencia")
            .navigationTitle("Frecuencia de Notificaciones")
    }
}

// MARK: - Priority Settings View
struct PrioritySettingsView: View {
    var body: some View {
        Text("Configuración de Prioridades")
            .navigationTitle("Prioridades de Notificaciones")
    }
}

// MARK: - System Notifications View
struct SystemNotificationsView: View {
    var body: some View {
        Text("Notificaciones del Sistema")
            .navigationTitle("Notificaciones del Sistema")
    }
}

// MARK: - Badge Settings View
struct BadgeSettingsView: View {
    var body: some View {
        Text("Configuración de Badges")
            .navigationTitle("Configuración de Badges")
    }
}

// MARK: - Emergency Contacts View
struct EmergencyContactsView: View {
    var body: some View {
        Text("Contactos de Emergencia")
            .navigationTitle("Contactos de Emergencia")
    }
}

// MARK: - Notification Groups View
struct NotificationGroupsView: View {
    var body: some View {
        Text("Grupos de Notificación")
            .navigationTitle("Grupos de Notificación")
    }
}

// MARK: - Device Notification Settings View
struct DeviceNotificationSettingsView: View {
    var body: some View {
        Text("Configuración por Dispositivo")
            .navigationTitle("Configuración por Dispositivo")
    }
}

// MARK: - Notification Sync View
struct NotificationSyncView: View {
    var body: some View {
        Text("Sincronización de Configuración")
            .navigationTitle("Sincronización de Configuración")
    }
}

#Preview {
    NavigationView {
        NotificationSettingsView()
    }
}
