//  SignUpView.swift
//  HealthPatch
//  Created by David Roman Lopez on 8/6/25.

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password, confirmPassword
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 32) {
                        // Logo y título
                        logoSection
                        
                        // Formulario de registro
                        signUpForm
                        
                        // Botones adicionales
                        additionalButtons
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                }
            }
            .navigationTitle("Crear Cuenta")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGray6))
        }
    }
    
    // MARK: - Logo Section
    private var logoSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)
            
            VStack(spacing: 8) {
                Text("Crear Cuenta")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Únete a HealthPatch")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 40)
    }
    
    // MARK: - Sign Up Form
    private var signUpForm: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                // Campo email
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
                
                // Campo contraseña
                VStack(alignment: .leading, spacing: 6) {
                    Text("Contraseña")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    SecureField("Introduce tu contraseña", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.password)
                }
                
                // Campo confirmar contraseña
                VStack(alignment: .leading, spacing: 6) {
                    Text("Confirmar contraseña")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    SecureField("Confirma tu contraseña", text: $confirmPassword)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.password)
                }
            }
            
            // Botón de registro
            Button(action: {
                print("SignUpView: Sign up button pressed")
                
                if password == confirmPassword {
                    Task {
                        await authManager.signIn(email: email, password: password)
                    }
                } else {
                    // Mostrar error de contraseñas no coinciden
                    print("SignUpView: Passwords don't match")
                }
            }) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "person.badge.plus")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    Text("Crear cuenta")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .disabled(authManager.isLoading || email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
        }
    }
    
    // MARK: - Additional Buttons
    private var additionalButtons: some View {
        VStack(spacing: 16) {
            // Botón para cambiar a login
            Button(action: {
                dismiss()
            }) {
                Text("¿Ya tienes cuenta? Inicia sesión")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            // Sign in with Apple
            Button(action: {
                // Action for Apple Sign In
            }) {
                HStack {
                    Image(systemName: "applelogo")
                        .font(.title3)
                    Text("Continuar con Apple")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.black)
                .cornerRadius(12)
            }
            
            // Sign in with Google
            Button(action: {
                // Action for Google Sign In
            }) {
                HStack {
                    Image(systemName: "g.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                    Text("Continuar con Google")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(12)
            }
        }
        .padding(.top, 20)
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
    SignUpView()
}
