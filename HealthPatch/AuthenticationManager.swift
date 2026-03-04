//
//  AuthenticationManager.swift
//  HealthPatch
//
//  Created by David Roman Lopez on 8/6/25.
//


import Foundation
import Combine
import SwiftUI
import AuthenticationServices

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: User?
    
    // Manager para autenticación social
    private let googleSignInManager = GoogleSignInManager()
    private let appleSignInManager = AppleSignInManager()
    
    private let userDefaults = UserDefaults.standard
    private let authTokenKey = Constants.UserDefaultsKeys.authToken
    private let userDataKey = Constants.UserDefaultsKeys.userData
    
    init() {
        print("AuthenticationManager: Initializing...")
        
        // Limpiar datos de autenticación para forzar el login
        print("AuthenticationManager: Clearing authentication data for testing...")
        userDefaults.removeObject(forKey: authTokenKey)
        userDefaults.removeObject(forKey: userDataKey)
        
        checkAuthenticationStatus()
        print("AuthenticationManager: Initialization complete")
    }
    
    func checkAuthenticationStatus() {
        print("AuthenticationManager: Checking authentication status...")
        // Verificar si hay un token guardado
        if let _ = userDefaults.string(forKey: authTokenKey),
           let userData = userDefaults.data(forKey: userDataKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            
            currentUser = user
            isAuthenticated = true
            print("AuthenticationManager: User is authenticated: \(user.email)")
        } else {
            currentUser = nil
            isAuthenticated = false
            print("AuthenticationManager: No authenticated user found")
        }
    }
    
    func signIn(email: String, password: String) async {
        print("AuthenticationManager: signIn called with email: \(email)")
        
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor completa todos los campos"
            print("AuthenticationManager: Empty email or password")
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Por favor introduce un correo válido"
            print("AuthenticationManager: Invalid email format")
            return
        }
        
        isLoading = true
        errorMessage = nil
        print("AuthenticationManager: Starting authentication process...")
        
        do {
            // Simular delay de red
            try await Task.sleep(nanoseconds: 1_500_000_000)
            
            // Aquí harías la llamada real a tu API
            let success = await authenticateUser(email: email, password: password)
            print("AuthenticationManager: Authentication result: \(success)")
            
            if success {
                let user = User(
                    id: UUID().uuidString,
                    email: email,
                    name: extractNameFromEmail(email),
                    avatarURL: nil
                )
                
                currentUser = user
                saveAuthenticationData(user: user, token: "mock_token_\(Date().timeIntervalSince1970)")
                isAuthenticated = true
                print("AuthenticationManager: Login successful, user: \(user.email)")
            } else {
                errorMessage = "Credenciales incorrectas"
                print("AuthenticationManager: Login failed")
            }
        } catch {
            errorMessage = "Error de conexión. Intenta de nuevo."
            print("AuthenticationManager: Login error: \(error)")
        }
        
        isLoading = false
        print("AuthenticationManager: Login process completed")
    }
    
    func signInWithApple(user: User) {
        currentUser = user
        saveAuthenticationData(user: user, token: "apple_token_\(Date().timeIntervalSince1970)")
        isAuthenticated = true
        print("AuthenticationManager: Apple Sign In successful for user: \(user.email)")
    }
    
    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = await appleSignInManager.signInWithApple()
            
            if result.success, let user = result.user {
                currentUser = user
                saveAuthenticationData(user: user, token: "apple_token_\(Date().timeIntervalSince1970)")
                isAuthenticated = true
                
                print("AuthenticationManager: Apple Sign In successful for user: \(user.email)")
            } else {
                errorMessage = result.error ?? "Error desconocido al conectar con Apple"
                print("AuthenticationManager: Apple Sign In failed with error: \(result.error ?? "Unknown")")
            }
            
        } catch {
            errorMessage = "Error al conectar con Apple: \(error.localizedDescription)"
            print("AuthenticationManager: Apple Sign In failed with error: \(error)")
        }
        
        isLoading = false
    }
    
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Usar el manager de Google Sign In
            let result = await googleSignInManager.signInWithGoogle()
            
            if result.success, let user = result.user {
                currentUser = user
                saveAuthenticationData(user: user, token: "google_token_\(Date().timeIntervalSince1970)")
                isAuthenticated = true
                
                print("AuthenticationManager: Google Sign In successful for user: \(user.email)")
            } else {
                errorMessage = result.error ?? "Error desconocido al conectar con Google"
                print("AuthenticationManager: Google Sign In failed with error: \(result.error ?? "Unknown")")
            }
            
        } catch {
            errorMessage = "Error al conectar con Google: \(error.localizedDescription)"
            print("AuthenticationManager: Google Sign In failed with error: \(error)")
        }
        
        isLoading = false
    }
    private func saveUser() {
        guard let user = currentUser else { return }
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: Constants.UserDefaultsKeys.savedUser)
        }
    }
    
    func signOut() {
        isAuthenticated = false
        currentUser = nil
        userDefaults.removeObject(forKey: authTokenKey)
        userDefaults.removeObject(forKey: userDataKey)
        print("AuthenticationManager: User signed out")
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func updateUser(_ user: User) {
        self.currentUser = user
        self.isAuthenticated = true
        saveUser()
        print("AuthenticationManager: User updated: \(user.email)")
    }
    
    // MARK: - Private Methods
    
    private func authenticateUser(email: String, password: String) async -> Bool {
        // Simulación de autenticación
        // En una app real, harías una llamada HTTP a tu servidor
        
        // Para pruebas, aceptar cualquier email válido con cualquier contraseña
        print("AuthenticationManager: Attempting login with email: \(email)")
        
        // Simular que siempre es exitoso si el email es válido
        return isValidEmail(email) && !password.isEmpty
    }
    
    func saveAuthenticationData(user: User, token: String) {
        userDefaults.set(token, forKey: authTokenKey)
        
        if let userData = try? JSONEncoder().encode(user) {
            userDefaults.set(userData, forKey: userDataKey)
            print("AuthenticationManager: Authentication data saved successfully")
        } else {
            print("AuthenticationManager: Failed to save user data")
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func extractNameFromEmail(_ email: String) -> String {
        let username = email.components(separatedBy: "@").first ?? ""
        return username.capitalized
    }
}

struct User: Codable, Equatable {
    let id: String
    var email: String
    var name: String
    var avatarURL: String?
    var profileImageURL: String?
}
