//
//  ForgotPasswordView.swift
//  HealthPatch
//
//  Created by David Roman Lopez on 8/6/25.
//


import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showingSuccess = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 32) {
                        // Logo y título
                        logoSection
                        
                        // Formulario de recuperación
                        recoveryForm
                        
                        // Botones adicionales
                        additionalButtons
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                }
            }
            .navigationTitle("Recuperar Contraseña")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGray6))
        }
    }
    
    private func sendResetEmail() {
        guard !email.isEmpty else {
            errorMessage = "Por favor introduce tu correo electrónico"
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Por favor introduce un correo válido"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Simular envío de email
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            showingSuccess = true
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // MARK: - Logo Section
    private var logoSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "key.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)
            
            VStack(spacing: 8) {
                Text("¿Olvidaste tu contraseña?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("No te preocupes, te enviaremos instrucciones para restablecerla")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 40)
    }
    
    // MARK: - Recovery Form
    private var recoveryForm: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Correo electrónico")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                TextField("nombre@ejemplo.com", text: $email)
                    .textFieldStyle(CustomTextFieldStyle())
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            
            Button(action: sendResetEmail) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Text("Enviar instrucciones")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(email.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(email.isEmpty || isLoading)
        }
    }
    
    // MARK: - Additional Buttons
    private var additionalButtons: some View {
        VStack(spacing: 16) {
            // Botón para volver al login
            Button("Volver al inicio de sesión") {
                dismiss()
            }
            .font(.subheadline)
            .foregroundColor(.blue)
            .padding(.bottom, 32)
        }
    }
    
    // MARK: - Custom Text Field Style
    private struct CustomTextFieldStyle: TextFieldStyle {
        func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Helper Methods
}

#Preview {
    ForgotPasswordView()
}
