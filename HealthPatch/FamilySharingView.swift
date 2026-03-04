import SwiftUI

struct FamilySharingView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var familySharingEnabled = false
    @State private var shareHealthData = false
    @State private var shareLocationData = false
    @State private var shareNotifications = false
    @State private var emergencyContacts = false
    @State private var selectedFamilyMembers: Set<String> = []
    
    let familyMembers = [
        "María López (Esposa)",
        "Carlos López (Hijo)",
        "Ana López (Hija)",
        "Roberto López (Padre)"
    ]
    
    var body: some View {
        List {
            // Estado de Compartir en Familia
            Section {
                HStack {
                    Image(systemName: "person.2.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text("Compartir en Familia")
                            .font(.headline)
                        Text("Permite que miembros de tu familia accedan a información importante")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $familySharingEnabled)
                        .labelsHidden()
                        .tint(.green)
                }
            }
            
            if familySharingEnabled {
                // Miembros de la Familia
                Section("Miembros de la Familia") {
                    ForEach(familyMembers, id: \.self) { member in
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text(member)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("Miembro de la familia")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedFamilyMembers.contains(member) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedFamilyMembers.contains(member) {
                                selectedFamilyMembers.remove(member)
                            } else {
                                selectedFamilyMembers.insert(member)
                            }
                        }
                    }
                    
                    Button("Agregar Miembro") {
                        // Lógica para agregar miembro
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
                
                // Datos a Compartir
                Section("Datos a Compartir") {
                    Toggle("Datos de Salud", isOn: $shareHealthData)
                        .tint(.green)
                    
                    if shareHealthData {
                        Text("Los miembros de la familia podrán ver métricas de salud básicas")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Toggle("Datos de Ubicación", isOn: $shareLocationData)
                        .tint(.green)
                    
                    if shareLocationData {
                        Text("Los miembros de la familia podrán ver la ubicación del parche")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Toggle("Notificaciones", isOn: $shareNotifications)
                        .tint(.green)
                    
                    if shareNotifications {
                        Text("Los miembros de la familia recibirán alertas importantes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Toggle("Contactos de Emergencia", isOn: $emergencyContacts)
                        .tint(.green)
                    
                    if emergencyContacts {
                        Text("Los miembros de la familia serán contactados en emergencias")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Configuración de Permisos
                Section("Configuración de Permisos") {
                    NavigationLink("Permisos por Miembro") {
                        MemberPermissionsView()
                    }
                    
                    NavigationLink("Configuración de Acceso") {
                        AccessConfigurationView()
                    }
                    
                    NavigationLink("Historial de Acceso") {
                        AccessHistoryView()
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
                
                // Configuración de Notificaciones
                Section("Configuración de Notificaciones") {
                    NavigationLink("Configuración de Alertas") {
                        AlertConfigurationView()
                    }
                    
                    NavigationLink("Configuración de Frecuencia") {
                        FrequencyConfigurationView()
                    }
                    
                    NavigationLink("Configuración de Horarios") {
                        ScheduleConfigurationView()
                    }
                }
            } else {
                // Información cuando está desactivado
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("Compartir en Familia Desactivado")
                            .font(.headline)
                        
                        Text("Activa esta función para permitir que miembros de tu familia accedan a información importante de tu parche")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
        }
        .navigationTitle("Compartir en Familia")
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
                    // Guardar configuración de familia
                    print("Guardando configuración de familia...")
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
    }
    
    private func saveSettings() {
        // Lógica para guardar configuración
        print("Guardando configuración de compartir en familia...")
    }
}

// MARK: - Member Permissions View
struct MemberPermissionsView: View {
    var body: some View {
        Text("Permisos por Miembro")
            .navigationTitle("Permisos por Miembro")
    }
}

// MARK: - Access Configuration View
struct AccessConfigurationView: View {
    var body: some View {
        Text("Configuración de Acceso")
            .navigationTitle("Configuración de Acceso")
    }
}

// MARK: - Access History View
struct AccessHistoryView: View {
    var body: some View {
        Text("Historial de Acceso")
            .navigationTitle("Historial de Acceso")
    }
}

// MARK: - Alert Configuration View
struct AlertConfigurationView: View {
    var body: some View {
        Text("Configuración de Alertas")
            .navigationTitle("Configuración de Alertas")
    }
}

// MARK: - Frequency Configuration View
struct FrequencyConfigurationView: View {
    var body: some View {
        Text("Configuración de Frecuencia")
            .navigationTitle("Configuración de Frecuencia")
    }
}

// MARK: - Schedule Configuration View
struct ScheduleConfigurationView: View {
    var body: some View {
        Text("Configuración de Horarios")
            .navigationTitle("Configuración de Horarios")
    }
}

// MARK: - Family Privacy Settings View
struct FamilyPrivacySettingsView: View {
    var body: some View {
        Text("Configuración de Privacidad Familiar")
            .navigationTitle("Privacidad Familiar")
    }
}

// MARK: - Family Alerts View
struct FamilyAlertsView: View {
    var body: some View {
        Text("Configurar Alertas Familiares")
            .navigationTitle("Alertas Familiares")
    }
}

// MARK: - Message Templates View
struct MessageTemplatesView: View {
    var body: some View {
        Text("Plantillas de Mensajes")
            .navigationTitle("Plantillas de Mensajes")
    }
}

// MARK: - Sharing History View
struct SharingHistoryView: View {
    var body: some View {
        Text("Historial de Compartido")
            .navigationTitle("Historial de Compartido")
    }
}

// MARK: - Family Security View
struct FamilySecurityView: View {
    var body: some View {
        Text("Configuración de Seguridad Familiar")
            .navigationTitle("Seguridad Familiar")
    }
}

// MARK: - Access Audit View
struct AccessAuditView: View {
    var body: some View {
        Text("Auditoría de Acceso")
            .navigationTitle("Auditoría de Acceso")
    }
}

// MARK: - Family Encryption View
struct FamilyEncryptionView: View {
    var body: some View {
        Text("Configuración de Cifrado Familiar")
            .navigationTitle("Cifrado Familiar")
    }
}

#Preview {
    NavigationView {
        FamilySharingView()
    }
}
