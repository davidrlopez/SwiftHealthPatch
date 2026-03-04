import Foundation
import AuthenticationServices
import SwiftUI
import Combine

@MainActor
class AppleSignInManager: NSObject, ObservableObject {
    @Published var isAuthenticating = false
    @Published var errorMessage: String?
    
    func signInWithApple() async -> (success: Bool, user: User?, error: String?) {
        print("AppleSignInManager: Starting Apple Sign In process")
        isAuthenticating = true
        errorMessage = nil
        
        // Simular Apple Sign In exitoso para desarrollo
        print("AppleSignInManager: Simulating successful Apple Sign In for development")
        
        // Simular delay de autenticación
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Crear usuario simulado
        let user = User(
            id: "apple_user_\(UUID().uuidString)",
            email: "user.apple@privaterelay.appleid.com",
            name: "Usuario Apple",
            avatarURL: nil
        )
        
        print("AppleSignInManager: Created simulated user: \(user.email)")
        isAuthenticating = false
        return (true, user, nil)
        
        // Código original comentado para desarrollo
        /*
        do {
            // Crear solicitud de autorización
            print("AppleSignInManager: Creating authorization request")
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            // Crear controlador de autorización
            print("AppleSignInManager: Creating authorization controller")
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            
            // Ejecutar solicitud de autorización
            print("AppleSignInManager: Performing authorization request")
            let result = try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation
                authorizationController.performRequests()
            }
            
            print("AppleSignInManager: Authorization completed, processing result")
            
            // Procesar resultado
            if let appleIDCredential = result as? ASAuthorizationAppleIDCredential {
                print("AppleSignInManager: Successfully received Apple ID credential")
                let user = User(
                    id: appleIDCredential.user,
                    email: appleIDCredential.email ?? "user@privaterelay.appleid.com",
                    name: formatFullName(appleIDCredential.fullName),
                    avatarURL: nil
                )
                
                print("AppleSignInManager: Created user: \(user.email)")
                isAuthenticating = false
                return (true, user, nil)
            } else {
                print("AppleSignInManager: Invalid credential type received")
                throw NSError(domain: "AppleSignIn", code: 1, userInfo: [NSLocalizedDescriptionKey: "Credenciales inválidas"])
            }
            
        } catch {
            print("AppleSignInManager: Error during sign in: \(error)")
            isAuthenticating = false
            errorMessage = error.localizedDescription
            return (false, nil, error.localizedDescription)
        }
        */
    }
    
    private var continuation: CheckedContinuation<ASAuthorization, Error>?
    
    private func formatFullName(_ personNameComponents: PersonNameComponents?) -> String {
        guard let components = personNameComponents else { return "Usuario Apple" }
        
        var nameParts: [String] = []
        
        if let givenName = components.givenName {
            nameParts.append(givenName)
        }
        
        if let familyName = components.familyName {
            nameParts.append(familyName)
        }
        
        return nameParts.isEmpty ? "Usuario Apple" : nameParts.joined(separator: " ")
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleSignInManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation?.resume(returning: authorization)
        continuation = nil
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("AppleSignInManager: Authorization failed with error: \(error)")
        
        // Check if it's a user cancellation
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                print("AppleSignInManager: User canceled authentication")
                errorMessage = "Autenticación cancelada por el usuario"
            case .failed:
                print("AppleSignInManager: Authentication failed")
                errorMessage = "Error de autenticación con Apple"
            case .invalidResponse:
                print("AppleSignInManager: Invalid response")
                errorMessage = "Respuesta inválida de Apple"
            case .notHandled:
                print("AppleSignInManager: Not handled")
                errorMessage = "Error no manejado"
            case .unknown:
                print("AppleSignInManager: Unknown error")
                errorMessage = "Error desconocido"
            @unknown default:
                print("AppleSignInManager: Unknown default error")
                errorMessage = "Error desconocido"
            }
        } else {
            errorMessage = error.localizedDescription
        }
        
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleSignInManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first else {
            print("AppleSignInManager: No key window found, using first available window")
            return UIApplication.shared.windows.first ?? UIWindow()
        }
        print("AppleSignInManager: Using window for presentation: \(window)")
        return window
    }
}
