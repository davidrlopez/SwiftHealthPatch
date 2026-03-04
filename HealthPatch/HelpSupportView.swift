import SwiftUI

struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var selectedCategory: HelpCategory = .general
    
    let helpCategories: [HelpCategory] = [
        .general, .connection, .health, .location, .notifications, .privacy, .technical
    ]
    
    var body: some View {
        List {
            // Búsqueda
            Section {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Buscar ayuda...", text: $searchText)
                }
            }
            
            // Categorías de Ayuda
            Section("Categorías de Ayuda") {
                ForEach(helpCategories, id: \.self) { category in
                    NavigationLink(category.displayName) {
                        HelpCategoryView(category: category)
                    }
                }
            }
            
            // Preguntas Frecuentes
            Section("Preguntas Frecuentes") {
                NavigationLink("¿Cómo conectar mi parche?") {
                    FAQDetailView(question: "¿Cómo conectar mi parche?", answer: "Para conectar tu parche...")
                }
                
                NavigationLink("¿Qué hacer si se pierde la conexión?") {
                    FAQDetailView(question: "¿Qué hacer si se pierde la conexión?", answer: "Si se pierde la conexión...")
                }
                
                NavigationLink("¿Cómo interpretar las métricas?") {
                    FAQDetailView(question: "¿Cómo interpretar las métricas?", answer: "Las métricas te muestran...")
                }
                
                NavigationLink("Ver todas las preguntas") {
                    AllFAQView()
                }
            }
            
            // Contacto Directo
            Section("Contacto Directo") {
                ContactRow(
                    icon: "envelope.fill",
                    title: "Email de Soporte",
                    subtitle: "soporte@healthpatch.com",
                    color: .blue
                ) {
                    // Abrir email
                }
                
                ContactRow(
                    icon: "phone.fill",
                    title: "Teléfono de Soporte",
                    subtitle: "+1-800-Ihealth",
                    color: .green
                ) {
                    // Llamar
                }
                
                ContactRow(
                    icon: "message.fill",
                    title: "Chat en Vivo",
                    subtitle: "Disponible 24/7",
                    color: .purple
                ) {
                    // Abrir chat
                }
            }
            
            // Recursos de Ayuda
            Section("Recursos de Ayuda") {
                NavigationLink("Manual de Usuario") {
                    UserManualView()
                }
                
                NavigationLink("Videos Tutoriales") {
                    TutorialVideosView()
                }
                
                NavigationLink("Guía de Solución de Problemas") {
                    TroubleshootingGuideView()
                }
                
                NavigationLink("Base de Conocimientos") {
                    KnowledgeBaseView()
                }
                
                NavigationLink("Comunidad de Usuarios") {
                    UserCommunityView()
                }
                
                NavigationLink("Foro de Discusión") {
                    DiscussionForumView()
                }
            }
            
            // Configuración de Ayuda
            Section("Configuración de Ayuda") {
                NavigationLink("Preferencias de Ayuda") {
                    HelpPreferencesView()
                }
                
                NavigationLink("Historial de Consultas") {
                    HelpHistoryView()
                }
                
                NavigationLink("Guardar Artículos") {
                    SavedArticlesView()
                }
            }
            
            // Información del Sistema
            Section("Información del Sistema") {
                NavigationLink("Estado del Sistema") {
                    SystemStatusView()
                }
                
                NavigationLink("Mantenimiento Programado") {
                    MaintenanceScheduleView()
                }
                
                NavigationLink("Notas de Versión") {
                    ReleaseNotesView()
                }
            }
        }
        .navigationTitle("Ayuda y Soporte")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Contactar") {
                    // Abrir opciones de contacto
                    print("Abriendo opciones de contacto...")
                }
                .fontWeight(.semibold)
            }
        }
    }
}

// MARK: - Help Category View
struct HelpCategoryView: View {
    let category: HelpCategory
    
    var body: some View {
        Text("Categoría: \(category.displayName)")
            .navigationTitle(category.displayName)
    }
}

// MARK: - Help Article View
struct HelpArticleView: View {
    var body: some View {
        Text("Artículo de Ayuda")
            .navigationTitle("Artículo de Ayuda")
    }
}

// MARK: - FAQ Detail View
struct FAQDetailView: View {
    let question: String
    let answer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question)
                .font(.headline)
            
            Text(answer)
                .font(.body)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Pregunta Frecuente")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - All FAQ View
struct AllFAQView: View {
    var body: some View {
        Text("Todas las Preguntas Frecuentes")
            .navigationTitle("Preguntas Frecuentes")
    }
}

// MARK: - User Manual View
struct UserManualView: View {
    var body: some View {
        Text("Manual de Usuario")
            .navigationTitle("Manual de Usuario")
    }
}

// MARK: - Tutorial Videos View
struct TutorialVideosView: View {
    var body: some View {
        Text("Videos Tutoriales")
            .navigationTitle("Videos Tutoriales")
    }
}

// MARK: - Troubleshooting Guide View
struct TroubleshootingGuideView: View {
    var body: some View {
        Text("Guía de Solución de Problemas")
            .navigationTitle("Guía de Solución de Problemas")
    }
}

// MARK: - Knowledge Base View
struct KnowledgeBaseView: View {
    var body: some View {
        Text("Base de Conocimientos")
            .navigationTitle("Base de Conocimientos")
    }
}

// MARK: - User Community View
struct UserCommunityView: View {
    var body: some View {
        Text("Comunidad de Usuarios")
            .navigationTitle("Comunidad de Usuarios")
    }
}

// MARK: - Discussion Forum View
struct DiscussionForumView: View {
    var body: some View {
        Text("Foro de Discusión")
            .navigationTitle("Foro de Discusión")
    }
}

// MARK: - Help Preferences View
struct HelpPreferencesView: View {
    var body: some View {
        Text("Preferencias de Ayuda")
            .navigationTitle("Preferencias de Ayuda")
    }
}

// MARK: - Help History View
struct HelpHistoryView: View {
    var body: some View {
        Text("Historial de Consultas")
            .navigationTitle("Historial de Consultas")
    }
}

// MARK: - Saved Articles View
struct SavedArticlesView: View {
    var body: some View {
        Text("Guardar Artículos")
            .navigationTitle("Guardar Artículos")
    }
}

// MARK: - System Status View
struct SystemStatusView: View {
    var body: some View {
        Text("Estado del Sistema")
            .navigationTitle("Estado del Sistema")
    }
}

// MARK: - Maintenance Schedule View
struct MaintenanceScheduleView: View {
    var body: some View {
        Text("Mantenimiento Programado")
            .navigationTitle("Mantenimiento Programado")
    }
}

// MARK: - Release Notes View
struct ReleaseNotesView: View {
    var body: some View {
        Text("Notas de Versión")
            .navigationTitle("Notas de Versión")
    }
}

// MARK: - Help Category Enum
enum HelpCategory: CaseIterable {
    case general, connection, health, location, notifications, privacy, technical
    
    var displayName: String {
        switch self {
        case .general: return "General"
        case .connection: return "Conexión"
        case .health: return "Salud"
        case .location: return "Ubicación"
        case .notifications: return "Notificaciones"
        case .privacy: return "Privacidad"
        case .technical: return "Técnico"
        }
    }
}

#Preview {
    NavigationView {
        HelpSupportView()
    }
}
