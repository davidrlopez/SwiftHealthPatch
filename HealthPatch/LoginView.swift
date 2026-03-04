//
//  LoginView.swift
//  HealthPatch
//
//  Created by David Roman Lopez on 8/6/25.
//


import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @Environment(\.colorScheme) var colorScheme
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var viewMode: ViewMode = .login

    @State private var showingGoogleSignIn = false
    @State private var showingAppleSignIn = false
    @FocusState private var focusedField: Field?
    
    enum ViewMode {
        case login, signUp, forgotPassword
    }
    
    enum Field {
        case email, password, confirmPassword
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Logo Section
                        Image(colorScheme == .dark ? "HealthLabsWhite" : "HealthLabsBck")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320, height: 140)
                            .padding(.top, 5)
                        
                        // Dynamic Form Container with smooth transitions
                        VStack(spacing: 20) {
                            // Email Field - Always visible
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
                                    .focused($focusedField, equals: .email)
                            }
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                removal: .opacity.combined(with: .scale(scale: 0.95))
                            ))
                            
                            // Password Field - Always visible
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Contraseña")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                SecureField("Introduce tu contraseña", text: $password)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .textContentType(.password)
                                    .focused($focusedField, equals: .password)
                            }
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                removal: .opacity.combined(with: .scale(scale: 0.95))
                            ))
                            
                            // Confirm Password Field - Only visible in sign up
                            if viewMode == .signUp {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Confirmar contraseña")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    SecureField("Repite tu contraseña", text: $confirmPassword)
                                        .textFieldStyle(CustomTextFieldStyle())
                                        .textContentType(.newPassword)
                                        .focused($focusedField, equals: .confirmPassword)
                                }
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                    removal: .opacity.combined(with: .scale(scale: 0.95))
                                ))
                            }
                            
                            // Info Text - Only visible in forgot password
                            if viewMode == .forgotPassword {
                                Text("Te enviaremos un enlace para restablecer tu contraseña")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 8)
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                        removal: .opacity.combined(with: .scale(scale: 0.95))
                                    ))
                            }
                            
                            // Dynamic Action Buttons
                            dynamicActionButtons
                            
                            // Social Login Buttons (only shown in login mode)
                            if viewMode == .login {
                                socialLoginButtons
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                        removal: .opacity.combined(with: .scale(scale: 0.95))
                                    ))
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 32)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .background(colorScheme == .dark ? Color.black : Color(.systemGray6))
            .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3), value: viewMode)
        }
        .sheet(isPresented: $showingGoogleSignIn) {
            GoogleSignInView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showingAppleSignIn) {
            AppleSignInView()
                .environmentObject(authManager)
        }
    }

    

    
    // MARK: - Navigation Title
    private var navigationTitle: String {
        switch viewMode {
        case .login:
            return "Iniciar Sesión"
        case .signUp:
            return "Crear Cuenta"
        case .forgotPassword:
            return "Recuperar Contraseña"
        }
    }
    
    // MARK: - Dynamic Action Buttons
    private var dynamicActionButtons: some View {
        VStack(spacing: 16) {
            switch viewMode {
            case .login:
                // Forgot Password Button
                HStack {
                    Spacer()
                    Button("¿Olvidaste tu contraseña?") {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            viewMode = .forgotPassword
                            password = ""
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                .padding(.top, -8)
                
                // Login Button
                Button(action: {
                    print("LoginView: Login button pressed")
                    
                    Task {
                        await authManager.signIn(email: email, password: password)
                    }
                }) {
                    HStack {
                        if authManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.right")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        Text("Iniciar sesión")
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
                .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)
                
                // Switch to Sign Up
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        viewMode = .signUp
                        password = ""
                        confirmPassword = ""
                    }
                }) {
                    Text("¿No tienes cuenta? Regístrate")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.top, 8)
                
            case .signUp:
                // Sign Up Button
                Button(action: {
                    print("LoginView: Sign up button pressed")
                    
                    // Aquí iría la lógica de registro
                    // Por ahora solo simulamos
                    Task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        // Simular registro exitoso
                        withAnimation(.easeInOut(duration: 0.4)) {
                            viewMode = .login
                            password = ""
                            confirmPassword = ""
                        }
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
                            gradient: Gradient(colors: [.green, .green.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .disabled(authManager.isLoading || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || password != confirmPassword)
                
                // Switch to Login
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        viewMode = .login
                        password = ""
                        confirmPassword = ""
                    }
                }) {
                    Text("¿Ya tienes cuenta? Inicia sesión")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.top, 8)
                
            case .forgotPassword:
                // Reset Password Button
                Button(action: {
                    print("LoginView: Reset password button pressed")
                    
                    // Aquí iría la lógica de recuperación de contraseña
                    // Por ahora solo simulamos
                    Task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        // Simular envío exitoso
                        withAnimation(.easeInOut(duration: 0.4)) {
                            viewMode = .login
                        }
                    }
                }) {
                    HStack {
                        if authManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "envelope")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        Text("Enviar enlace de recuperación")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.orange, .orange.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .disabled(authManager.isLoading || email.isEmpty)
                
                // Switch to Login
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        viewMode = .login
                    }
                }) {
                    Text("Volver al inicio de sesión")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Social Login Buttons
    private var socialLoginButtons: some View {
        VStack(spacing: 16) {
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.secondary.opacity(0.3))
                
                Text("o")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.secondary.opacity(0.3))
            }
            
            VStack(spacing: 12) {
                Button(action: {
                    showingAppleSignIn = true
                }) {
                    HStack {
                        Image(systemName: "applelogo")
                            .font(.title3)
                            .foregroundColor(.white)
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
                
                Button(action: {
                    showingGoogleSignIn = true
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
}

// MARK: - Google Sign In View
// ✅ IMPLEMENTACIÓN REAL PREPARADA (requiere GoogleSignIn pod)
struct GoogleSignInView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthenticationManager
    @Environment(\.colorScheme) var colorScheme
    @State private var isLoading = true
    @State private var currentStep: SignInStep = .connecting
    @State private var progressValue: CGFloat = 0.0
    
    enum SignInStep: CaseIterable {
        case connecting, authenticating, completing
        
        var title: String {
            switch self {
            case .connecting: return "Conectando con Google"
            case .authenticating: return "Verificando identidad"
            case .completing: return "Completando inicio de sesión"
            }
        }
        
        var description: String {
            switch self {
            case .connecting: return "Estableciendo conexión segura..."
            case .authenticating: return "Validando tu cuenta de Google..."
            case .completing: return "Configurando tu perfil..."
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: colorScheme == .dark ? 
                        [Color(.systemGray6), Color.white.opacity(0.1)] : 
                        [Color.white, Color(.systemGray6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Google Logo with glow effect
                    ZStack {
                        Image(systemName: "globe")
                            .font(.system(size: 80, weight: .medium))
                            .foregroundColor(.blue)
                            .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        // Animated rings
                        ForEach(0..<3) { index in
                            Circle()
                                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                                .frame(width: 120 + CGFloat(index * 40), height: 120 + CGFloat(index * 40))
                                .scaleEffect(isLoading ? 1.2 : 0.8)
                                .opacity(isLoading ? 0.6 : 0)
                                .animation(
                                    .easeInOut(duration: 2)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.3),
                                    value: isLoading
                                )
                        }
                    }
                    
                    // Progress indicator
                    VStack(spacing: 24) {
                        // Step indicator
                        HStack(spacing: 20) {
                            ForEach(SignInStep.allCases, id: \.self) { step in
                                VStack(spacing: 8) {
                                    Circle()
                                        .fill(step == currentStep ? Color.blue : Color.gray.opacity(0.3))
                                        .frame(width: 12, height: 12)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                                                .frame(width: 20, height: 20)
                                        )
                                    
                                    if step == currentStep {
                                        Text(step.title)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                            }
                        }
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 4)
                                    .cornerRadius(2)
                                
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .blue.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * progressValue, height: 4)
                                    .cornerRadius(2)
                                    .animation(.easeInOut(duration: 0.5), value: progressValue)
                            }
                        }
                        .frame(height: 4)
                        
                        // Current step info
                        VStack(spacing: 12) {
                            Text(currentStep.title)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text(currentStep.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer()
                    
                    // Cancel button
                    Button("Cancelar") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 32)
            }
            .navigationTitle("Google")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
        .onAppear {
            startSignInProcess()
        }
    }
    
    private func startSignInProcess() {
        Task {
            // Step 1: Connecting
            await updateProgress(step: .connecting, progress: 0.7)
            
            // Step 2: Authenticating
            await updateProgress(step: .authenticating, progress: 0.7)
            
            // Step 3: Completing
            await updateProgress(step: .completing, progress: 1.0)
            
            // Complete sign in with Google Sign In
            await authManager.signInWithGoogle()
            
            // Check if authentication was successful
            if authManager.isAuthenticated {
                dismiss()
            } else {
                // Show error if authentication failed
                await updateProgress(step: .connecting, progress: 0.0)
            }
        }
    }
    
    private func updateProgress(step: SignInStep, progress: CGFloat) async {
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.8)) {
                currentStep = step
                progressValue = progress
            }
        }
        
        try? await Task.sleep(nanoseconds: 1_500_000_000)
    }
}

#Preview {
    LoginView().environmentObject(AuthenticationManager())
}

// MARK: - Apple Sign In View
// ✅ IMPLEMENTACIÓN REAL PREPARADA (requiere AuthenticationServices)
struct AppleSignInView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthenticationManager
    @Environment(\.colorScheme) var colorScheme
    @State private var isLoading = true
    @State private var currentStep: AppleSignInStep = .connecting
    @State private var progressValue: CGFloat = 0.0
    
    enum AppleSignInStep: CaseIterable {
        case connecting, authenticating, completing
        
        var title: String {
            switch self {
            case .connecting: return "Conectando con Apple"
            case .authenticating: return "Verificando identidad"
            case .completing: return "Completando inicio de sesión"
            }
        }
        
        var description: String {
            switch self {
            case .connecting: return "Estableciendo conexión segura..."
            case .authenticating: return "Validando tu cuenta de Apple..."
            case .completing: return "Configurando tu perfil..."
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: colorScheme == .dark ? 
                        [Color(.systemGray6), Color.white.opacity(0.1)] : 
                        [Color.white, Color(.systemGray6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Apple Logo with glow effect
                    ZStack {
                        Image(systemName: "applelogo")
                            .font(.system(size: 80, weight: .medium))
                            .foregroundColor(.black)
                            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        // Animated rings (similar to Google)
                        ForEach(0..<3) { index in
                            Circle()
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                .frame(width: 120 + CGFloat(index * 40), height: 120 + CGFloat(index * 40))
                                .scaleEffect(isLoading ? 1.2 : 0.8)
                                .opacity(isLoading ? 0.6 : 0)
                                .animation(
                                    .easeInOut(duration: 2)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.3),
                                    value: isLoading
                                )
                        }
                    }
                    
                    // Progress indicator
                    VStack(spacing: 24) {
                        // Step indicator
                        HStack(spacing: 20) {
                            ForEach(AppleSignInStep.allCases, id: \.self) { step in
                                VStack(spacing: 8) {
                                    Circle()
                                        .fill(step == currentStep ? Color(.systemBlue) : Color.gray.opacity(0.3))
                                        .frame(width: 12, height: 12)
                                        .overlay(
                                            Circle()
                                                .stroke(Color(.systemBlue).opacity(0.3), lineWidth: 2)
                                                .frame(width: 20, height: 20)
                                        )
                                    
                                    if step == currentStep {
                                        Text(step.title)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                            }
                        }
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 4)
                                    .cornerRadius(2)
                                
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(.systemBlue), Color(.systemBlue).opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * progressValue, height: 4)
                                    .cornerRadius(2)
                                    .animation(.easeInOut(duration: 0.5), value: progressValue)
                            }
                        }
                        .frame(height: 4)
                        
                        // Current step info
                        VStack(spacing: 12) {
                            Text(currentStep.title)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text(currentStep.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer()
                    
                    // Cancel button
                    Button("Cancelar") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(Color(.systemBlue))
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 32)
            }
            .navigationTitle("Apple")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
        .onAppear {
            startSignInProcess()
        }
    }
    
    private func startSignInProcess() {
        Task {
            // Step 1: Connecting
            await updateProgress(step: .connecting, progress: 0.7)
            
            // Step 2: Authenticating
            await updateProgress(step: .authenticating, progress: 0.7)
            
            // Step 3: Completing
            await updateProgress(step: .completing, progress: 1.0)
            
            // Complete sign in with Apple Sign In
            await authManager.signInWithApple()
            
            // Check if authentication was successful
            if authManager.isAuthenticated {
                // Keep the final state visible for a moment before dismissing
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                dismiss()
            } else {
                // Show error if authentication failed - stay in final state
                // Don't reset progress, just show error message
                print("Apple Sign In failed")
                // Add a delay before dismissing to show the error state
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                dismiss()
            }
        }
    }
    
    private func updateProgress(step: AppleSignInStep, progress: CGFloat) async {
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.8)) {
                currentStep = step
                progressValue = progress
            }
        }
        
        // Only add delay if not the final step
        if step != .completing || progress < 1.0 {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
        }
    }
}
