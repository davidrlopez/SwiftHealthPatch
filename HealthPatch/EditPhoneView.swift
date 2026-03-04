import SwiftUI

struct EditPhoneView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var phone: String
    @Binding var hasChanges: Bool
    @State private var tempPhone: String = ""
    @State private var showingSaveAlert = false
    @State private var isValidPhone = true
    
    var body: some View {
        VStack(spacing: 20) {
            // Campo de teléfono
            VStack(alignment: .leading, spacing: 8) {
                Text("Teléfono")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("Introduce tu teléfono", text: $tempPhone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
                    .keyboardType(.phonePad)
                    .onChange(of: tempPhone) { newValue in
                        isValidPhone = isValidPhoneFormat(newValue)
                    }
                
                if !tempPhone.isEmpty && !isValidPhone {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text("Formato de teléfono inválido")
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
                    Text("Tu teléfono se usará para verificación de seguridad")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                    Text("Recibirás códigos de verificación por SMS")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "shield.checkmark")
                        .foregroundColor(.green)
                    Text("Tu número está protegido y no se compartirá")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
        .navigationTitle("Editar Teléfono")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") {
                    if tempPhone != phone {
                        showingSaveAlert = true
                    } else {
                        dismiss()
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Guardar") {
                    savePhone()
                }
                .fontWeight(.semibold)
                .disabled(tempPhone.isEmpty || tempPhone == phone || !isValidPhone)
            }
        }
        .onAppear {
            tempPhone = phone
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
    
    private func savePhone() {
        phone = tempPhone
        hasChanges = true
        print("Teléfono guardado: \(phone)")
        dismiss()
    }
    
    private func isValidPhoneFormat(_ phone: String) -> Bool {
        // Validación básica de teléfono internacional
        let phoneRegex = "^\\+?[1-9]\\d{1,14}$"
        let phonePredicate = NSPredicate(format:"SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
}

#Preview {
    NavigationView {
        EditPhoneView(phone: .constant("+34 600 123 456"), hasChanges: .constant(false))
    }
}
