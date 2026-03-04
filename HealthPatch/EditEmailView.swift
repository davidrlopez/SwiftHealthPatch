import SwiftUI

struct EditEmailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var email: String
    @Binding var hasChanges: Bool
    @State private var tempEmail: String = ""
    @State private var showingSaveAlert = false
    @State private var isValidEmail = true
    
    var body: some View {
        VStack(spacing: 20) {
            // Campo de email
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("Introduce tu email", text: $tempEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .onChange(of: tempEmail) { newValue in
                        isValidEmail = isValidEmailFormat(newValue)
                    }
                
                if !tempEmail.isEmpty && !isValidEmail {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text("Formato de email inválido")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(.horizontal)
            
            // Información adicional
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("Tu email se usará para notificaciones importantes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                    Text("Recibirás confirmaciones de cambios de cuenta")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
        .navigationTitle("Editar Email")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") {
                    if tempEmail != email {
                        showingSaveAlert = true
                    } else {
                        dismiss()
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Guardar") {
                    saveEmail()
                }
                .fontWeight(.semibold)
                .disabled(tempEmail.isEmpty || tempEmail == email || !isValidEmail)
            }
        }
        .onAppear {
            tempEmail = email
        }
        .alert("Cambios sin Guardar", isPresented: $showingSaveAlert) {
            Button("Descartar Cambios", role: .destructive) {
                dismiss()
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Tienes cambios sin guardar. ¿Estás seguro de que quieres salir?")
        }
    }
    
    private func saveEmail() {
        email = tempEmail
        hasChanges = true
        print("Email guardado: \(email)")
        dismiss()
    }
    
    private func isValidEmailFormat(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    NavigationView {
        EditEmailView(email: .constant("screen.mp3@gmail.com"), hasChanges: .constant(false))
    }
}
