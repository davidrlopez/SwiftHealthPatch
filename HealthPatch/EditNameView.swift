import SwiftUI

struct EditNameView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var name: String
    @Binding var hasChanges: Bool
    @State private var tempName: String = ""
    @State private var showingSaveAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Campo de nombre
            VStack(alignment: .leading, spacing: 8) {
                Text("Nombre")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("Introduce tu nombre", text: $tempName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
            }
            .padding(.horizontal)
            
            // Información adicional
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("Tu nombre será visible para otros usuarios")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                    Text("Puedes cambiarlo en cualquier momento")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
        .navigationTitle("Editar Nombre")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") {
                    if tempName != name {
                        showingSaveAlert = true
                    } else {
                        dismiss()
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Guardar") {
                    saveName()
                }
                .fontWeight(.semibold)
                .disabled(tempName.isEmpty || tempName == name)
            }
        }
        .onAppear {
            tempName = name
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
    
    private func saveName() {
        name = tempName
        hasChanges = true
        print("Nombre guardado: \(name)")
        dismiss()
    }
}

#Preview {
    NavigationView {
        EditNameView(name: .constant("David Roman Lopez"), hasChanges: .constant(false))
    }
}
