import SwiftUI
import PhotosUI

struct UserAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var profileImage: Image?
    @State private var profileUIImage: UIImage? // Añadido para guardar la imagen real
    @State private var showingActionSheet = false
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    @State private var showingSaveAlert = false
    @State private var hasUnsavedChanges = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    
    // Datos del usuario
    @State private var userName = "David Roman Lopez"
    @State private var userEmail = "screen.mp3@gmail.com"
    @State private var userPhone = "+34 600 123 456"
    
    var body: some View {
        List {
            // Sección de Perfil (Centrada como Apple Account)
            Section {
                VStack(spacing: 16) {
                    // Foto de Perfil - Grande y centrada
                    Button(action: {
                        showingActionSheet = true
                    }) {
                        if let profileImage = profileImage {
                            profileImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 3)
                                )
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Nombre del Usuario
                    Text(userName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // Email del Usuario
                    Text(userEmail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            .listRowBackground(Color.clear)
            
            // Sección de Información Personal
            Section("Información Personal") {
                NavigationLink("Nombre") {
                    EditNameView(name: $userName, hasChanges: $hasUnsavedChanges)
                }
                
                NavigationLink("Email") {
                    EditEmailView(email: $userEmail, hasChanges: $hasUnsavedChanges)
                }
                
                NavigationLink("Teléfono") {
                    EditPhoneView(phone: $userPhone, hasChanges: $hasUnsavedChanges)
                }
            }
            
            // Sección de Seguridad
            Section("Seguridad") {
                NavigationLink("Cambiar Contraseña") {
                    ChangePasswordView()
                }
                
                NavigationLink("Autenticación de Dos Factores") {
                    TwoFactorAuthView()
                }
                
                NavigationLink("Privacidad de la Cuenta") {
                    AccountPrivacyView()
                }
            }
            
            // Sección de Sincronización
            Section("Sincronización") {
                NavigationLink("Configuración de Sincronización") {
                    SyncSettingsView()
                }
                
                NavigationLink("Dispositivos Conectados") {
                    DeviceManagementView()
                }
                
                NavigationLink("Historial de Sesiones") {
                    SessionHistoryView()
                }
            }
            
            // Sección de Actividad
            Section("Actividad") {
                NavigationLink("Actividad de la Cuenta") {
                    AccountActivityView()
                }
                
                NavigationLink("Datos y Exportación") {
                    DataExportView()
                }
                
                NavigationLink("Eliminar Cuenta") {
                    DeleteAccountView()
                }
            }
        }
        .navigationTitle("Cuenta de Usuario")
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
                    saveChanges()
                }
                .fontWeight(.semibold)
                .disabled(!hasUnsavedChanges)
            }
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Seleccionar Foto"),
                message: Text("¿Cómo quieres añadir tu foto de perfil?"),
                buttons: [
                    .default(Text("Cámara")) {
                        showingCamera = true
                    },
                    .default(Text("Galería de Fotos")) {
                        showingPhotoPicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingCamera) {
            CameraView { image in
                if let image = image {
                    profileImage = Image(uiImage: image)
                    profileUIImage = image // Guardar la imagen real
                    hasUnsavedChanges = true
                }
            }
        }
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    profileImage = Image(uiImage: uiImage)
                    profileUIImage = uiImage // Guardar la imagen real
                    hasUnsavedChanges = true
                }
            }
        }
        .alert("Cambios sin Guardar", isPresented: $showingSaveAlert) {
            Button("Descartar Cambios", role: .destructive) {
                dismiss()
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Tienes cambios sin guardar. ¿Estás seguro de que quieres salir?")
        }
        .onAppear {
            loadSavedUserData()
        }
        .onChange(of: userName) { _ in
            hasUnsavedChanges = true
        }
        .onChange(of: userEmail) { _ in
            hasUnsavedChanges = true
        }
        .onChange(of: userPhone) { _ in
            hasUnsavedChanges = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            loadSavedUserData()
        }
    }
    
    private func saveChanges() {
        // Save user data to UserDefaults
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(userEmail, forKey: "userEmail")
        UserDefaults.standard.set(userPhone, forKey: "userPhone")
        
        // Save profile image
        if let profileUIImage = profileUIImage {
            if let imageData = profileUIImage.jpegData(compressionQuality: 0.8) {
                UserDefaults.standard.set(imageData, forKey: "profileImageData")
            }
            UserDefaults.standard.set(true, forKey: "hasProfileImage")
        } else {
            UserDefaults.standard.set(false, forKey: "hasProfileImage")
            UserDefaults.standard.removeObject(forKey: "profileImageData")
        }
        
        // Synchronize UserDefaults
        UserDefaults.standard.synchronize()
        
        // Reset unsaved changes flag
        hasUnsavedChanges = false
        
        // Send notification to update profile image in main view
        NotificationCenter.default.post(name: NSNotification.Name("ProfileImageUpdated"), object: nil)
        
        // Dismiss the view
        dismiss()
    }
    
    private func loadSavedUserData() {
        userName = UserDefaults.standard.string(forKey: "userName") ?? "David Roman Lopez"
        userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "screen.mp3@gmail.com"
        userPhone = UserDefaults.standard.string(forKey: "userPhone") ?? "+34 600 123 456"
        
        // Simular carga de foto de perfil
        if let savedImageData = UserDefaults.standard.data(forKey: "profileImageData"),
           let uiImage = UIImage(data: savedImageData) {
            profileImage = Image(uiImage: uiImage)
            profileUIImage = uiImage // Guardar la imagen real
        } else {
            profileImage = nil // No hay foto guardada
            profileUIImage = nil // No hay foto guardada
        }
    }
}

// Vista de Cámara
struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImageCaptured(nil)
            picker.dismiss(animated: true)
        }
    }
}

// Vistas de Navegación (Placeholder)
struct ChangePasswordView: View {
    var body: some View {
        Text("Cambiar Contraseña")
            .navigationTitle("Cambiar Contraseña")
    }
}

struct TwoFactorAuthView: View {
    var body: some View {
        Text("Verificación en Dos Pasos")
            .navigationTitle("Verificación en Dos Pasos")
    }
}

struct AccountPrivacyView: View {
    var body: some View {
        Text("Privacidad de Cuenta")
            .navigationTitle("Privacidad de Cuenta")
    }
}

struct SyncSettingsView: View {
    var body: some View {
        Text("Sincronización")
            .navigationTitle("Sincronización")
    }
}

struct DeviceManagementView: View {
    var body: some View {
        Text("Gestión de Dispositivos")
            .navigationTitle("Gestión de Dispositivos")
    }
}

struct SessionHistoryView: View {
    var body: some View {
        Text("Historial de Sesiones")
            .navigationTitle("Historial de Sesiones")
    }
}

struct AccountActivityView: View {
    var body: some View {
        Text("Actividad de Cuenta")
            .navigationTitle("Actividad de Cuenta")
    }
}

struct DataExportView: View {
    var body: some View {
        Text("Descargar Mis Datos")
            .navigationTitle("Descargar Mis Datos")
    }
}

struct DeleteAccountView: View {
    var body: some View {
        Text("Eliminar Cuenta")
            .navigationTitle("Eliminar Cuenta")
    }
}

#Preview {
    NavigationView {
        UserAccountView()
    }
}
