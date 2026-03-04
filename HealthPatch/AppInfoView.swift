import SwiftUI

struct AppInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    let appVersion = "2.0.1"
    let buildNumber = "2025.1.0"
    let developer = "David Roman Lopez"
    let company = "Health Technologies"
    let copyright = "© 2025 Health Technologies. Todos los derechos reservados."
    
    var body: some View {
        List {
            // Información de la Aplicación
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "cross.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("HealthPatch")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Tu compañero de salud inteligente")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            
            // Detalles de Versión
            Section("Información de Versión") {
                InfoRow(title: "Versión", value: appVersion)
                InfoRow(title: "Build", value: buildNumber)
                InfoRow(title: "Plataforma", value: "iOS")
                InfoRow(title: "Arquitectura", value: "ARM64")
                InfoRow(title: "Fecha de Compilación", value: "8 de Enero, 2025")
            }
            
            // Información del Desarrollador
            Section("Desarrollador") {
                InfoRow(title: "Desarrollador", value: developer)
                InfoRow(title: "Empresa", value: company)
                InfoRow(title: "Contacto", value: "david@healthpatch.com")
                InfoRow(title: "Sitio Web", value: "www.healthpatch.com")
            }
            
            // Características de la Aplicación
            Section("Características") {
                FeatureRow(icon: "heart.fill", title: "Monitoreo de Salud", description: "Seguimiento continuo de signos vitales")
                FeatureRow(icon: "location.fill", title: "Localización", description: "Ubicación precisa del parche")
                FeatureRow(icon: "wifi", title: "Conectividad", description: "Conexión Bluetooth de bajo consumo")
                FeatureRow(icon: "shield.fill", title: "Seguridad", description: "Cifrado de datos de salud")
                FeatureRow(icon: "bell.fill", title: "Alertas", description: "Notificaciones inteligentes")
                FeatureRow(icon: "chart.bar.fill", title: "Análisis", description: "Métricas y estadísticas detalladas")
            }
            
            // Tecnologías Utilizadas
            Section("Tecnologías") {
                TechRow(name: "SwiftUI", version: "5.0", description: "Framework de interfaz de usuario")
                TechRow(name: "Core Bluetooth", version: "5.0", description: "Comunicación Bluetooth Low Energy")
                TechRow(name: "HealthKit", version: "8.0", description: "Integración con datos de salud")
                TechRow(name: "Core Location", version: "8.0", description: "Servicios de ubicación")
                TechRow(name: "UserNotifications", version: "10.0", description: "Sistema de notificaciones")
            }
            
            // Licencias y Términos
            Section("Licencias y Términos") {
                NavigationLink("Términos de Servicio") {
                    TermsOfServiceView()
                }
                
                NavigationLink("Política de Privacidad") {
                    PrivacyPolicyView()
                }
                
                NavigationLink("Licencias de Software") {
                    SoftwareLicensesView()
                }
            }
            
            // Soporte y Ayuda
            Section("Soporte y Ayuda") {
                NavigationLink("Centro de Ayuda") {
                    HelpCenterView()
                }
                
                NavigationLink("Reportar un Problema") {
                    ReportIssueView()
                }
                
                NavigationLink("Solicitar Función") {
                    FeatureRequestView()
                }
            }
            
            // Información de Contacto
            Section("Información de Contacto") {
                ContactRow(
                    icon: "envelope", 
                    title: "Email", 
                    subtitle: "soporte@healthpatch.com", 
                    color: .blue
                ) {
                    // Enviar email
                    print("Enviando email...")
                }
                
                ContactRow(
                    icon: "phone", 
                    title: "Teléfono", 
                    subtitle: "+34 900 123 456", 
                    color: .green
                ) {
                    // Llamar
                    print("Llamando...")
                }
                
                ContactRow(
                    icon: "message", 
                    title: "Chat", 
                    subtitle: "Disponible 24/7", 
                    color: .purple
                ) {
                    // Iniciar chat
                    print("Iniciando chat...")
                }
                
                ContactRow(
                    icon: "globe", 
                    title: "Sitio Web", 
                    subtitle: "www.healthpatch.com", 
                    color: .blue
                ) {
                    // Visitar sitio web
                    print("Visitando sitio web...")
                }
            }
            
            // Redes Sociales
            Section("Redes Sociales") {
                ContactRow(
                    icon: "bird", 
                    title: "Twitter", 
                    subtitle: "@HealthPatch", 
                    color: .blue
                ) {
                    // Seguir en Twitter
                    print("Siguiendo en Twitter...")
                }
                
                ContactRow(
                    icon: "camera", 
                    title: "Instagram", 
                    subtitle: "@healthpatch", 
                    color: .pink
                ) {
                    // Seguir en Instagram
                    print("Siguiendo en Instagram...")
                }
                
                ContactRow(
                    icon: "link", 
                    title: "LinkedIn", 
                    subtitle: "Health Technologies", 
                    color: .blue
                ) {
                    // Conectar en LinkedIn
                    print("Conectando en LinkedIn...")
                }
            }
        }
        .navigationTitle("Acerca de HealthPatch")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Compartir") {
                    // Compartir información de la app
                    print("Compartiendo información de la app...")
                }
                .fontWeight(.semibold)
            }
        }
    }
}

// MARK: - Terms of Service View
struct TermsOfServiceView: View {
    var body: some View {
        Text("Términos de Servicio")
            .navigationTitle("Términos de Servicio")
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    var body: some View {
        Text("Política de Privacidad")
            .navigationTitle("Política de Privacidad")
    }
}

// MARK: - Software Licenses View
struct SoftwareLicensesView: View {
    var body: some View {
        Text("Licencias de Software")
            .navigationTitle("Licencias de Software")
    }
}

// MARK: - Help Center View
struct HelpCenterView: View {
    var body: some View {
        Text("Centro de Ayuda")
            .navigationTitle("Centro de Ayuda")
    }
}

// MARK: - Report Issue View
struct ReportIssueView: View {
    var body: some View {
        Text("Reportar un Problema")
            .navigationTitle("Reportar un Problema")
    }
}

// MARK: - Feature Request View
struct FeatureRequestView: View {
    var body: some View {
        Text("Solicitar Función")
            .navigationTitle("Solicitar Función")
    }
}

#Preview {
    NavigationView {
        AppInfoView()
    }
}
