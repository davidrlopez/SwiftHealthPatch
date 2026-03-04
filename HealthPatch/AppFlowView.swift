import SwiftUI
import CoreBluetooth
import Combine

struct LaunchView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack {
                ProgressView()
                Text("Launching...")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct PermissionView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "lock.slash")
                    .resizable()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.red)
                Text("Bluetooth Permission Denied")
                    .font(.title2).bold()
                Text("Please grant Bluetooth permissions to continue.")
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

// Temporary views above are used to resolve missing symbol errors. Replace with real UI later.

struct AppFlowView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @EnvironmentObject var authManager: AuthenticationManager

    @State private var currentStep: Step = .launch
    @State private var hasInitialized = false
    @State private var navigationLocked = false
    @State private var lastConnectedDeviceId: UUID?

    enum Step: Equatable {
        case launch, permission, login, bluetooth, main, debug, emergency
    }

    var body: some View {
        
        Group {
            switch currentStep {
            case .launch:
                LaunchView()
                    .transition(.opacity)
                
            case .permission:
                PermissionView()
                    .transition(.move(edge: .trailing))
                
            case .login:
                LoginView()
                    .environmentObject(authManager)
                    .transition(.move(edge: .trailing))
                
            case .bluetooth:
                DeviceListView(onDismiss: {
                    // Volver al paso de login
                    self.navigateToStep(.login)
                })
                    .environmentObject(bluetoothManager)
                    .environmentObject(authManager)
                    .transition(.move(edge: .trailing))

            case .main:
                MonitoringView()
                    .environmentObject(bluetoothManager)
                    .environmentObject(authManager)
                    .transition(.move(edge: .trailing))
                    
            case .debug:
                DebugView()
                    .environmentObject(bluetoothManager)
                    .transition(.move(edge: .trailing))
                    
            case .emergency:
                EmergencyView(onRestart: {
                    // Reiniciar la app de forma segura
                    DispatchQueue.main.async {
                        self.currentStep = .launch
                        self.hasInitialized = false
                        self.navigationLocked = false
                        self.lastConnectedDeviceId = nil
                        self.setupInitialFlow()
                    }
                })
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
        .onAppear {
            setupInitialFlow()
        }
        .onReceive(bluetoothManager.$isInitialized.removeDuplicates()) { initialized in
            if initialized && currentStep == .launch && !navigationLocked {
                print("AppFlowView: BluetoothManager initialized, evaluating flow...")
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Timing.appInitializationDelay) {
                    self.evaluateFlow()
                }
            }
        }
        .onReceive(bluetoothManager.$bluetoothState.removeDuplicates()) { state in
            handleBluetoothStateChange(state)
        }
        .onReceive(bluetoothManager.$connectedDevice.removeDuplicates()) { device in
            handleConnectedDeviceChange(device)
        }
        .onReceive(authManager.$currentUser.removeDuplicates()) { user in
            handleUserAuthChange(user)
        }
        .onReceive(authManager.$isAuthenticated.removeDuplicates()) { isAuthenticated in
            print("AppFlowView: isAuthenticated changed to: \(isAuthenticated)")
            if isAuthenticated && currentStep == .login {
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Timing.navigationDelay) {
                    self.evaluateFlow()
                }
            }
        }
        .alert("Permisos de Bluetooth", isPresented: $bluetoothManager.showPermissionAlert) {
            Button("Ir a Configuración") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Esta aplicación necesita acceso a Bluetooth para funcionar. Por favor, habilita los permisos en Configuración.")
        }
    }

    // MARK: - Helper Methods
    
    // MARK: - Public Methods
    
    func forceFlowReevaluation() {
        print("AppFlowView: Force flow re-evaluation requested")
        navigationLocked = false
        evaluateFlow()
    }
    
    // MARK: - Setup and Navigation Logic
    
    private func setupInitialFlow() {
        guard !hasInitialized else { return }
        hasInitialized = true
        
        print("AppFlowView: Setting up initial flow")
        
        // Reducir el delay inicial para mejor respuesta
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Timing.appInitializationDelay) {
            self.evaluateFlow()
        }
    }
    
    private func evaluateFlow() {
        guard !navigationLocked else {
            print("AppFlowView: Navigation is locked, skipping evaluation")
            return
        }
        
        print("AppFlowView: Evaluating flow - Current step: \(currentStep)")
        print("AppFlowView: Auth state - isAuthenticated: \(authManager.isAuthenticated), currentUser: \(authManager.currentUser?.email ?? "nil")")
        print("AppFlowView: Bluetooth state - connectedDevice: \(bluetoothManager.connectedDevice?.name ?? "nil"), isDeviceRegistered: \(bluetoothManager.isDeviceRegistered)")
        
        // Check permissions first
        if bluetoothManager.isPermissionDenied {
            print("AppFlowView: Bluetooth permission denied")
            navigateToStep(.permission)
            return
        }
        
        // Check if BluetoothManager is ready
        guard bluetoothManager.isInitialized else {
            print("AppFlowView: BluetoothManager not yet initialized")
            return
        }
        
        // Check authentication - usar isAuthenticated en lugar de currentUser
        guard authManager.isAuthenticated, let _ = authManager.currentUser else {
            print("AppFlowView: No authenticated user - isAuthenticated: \(authManager.isAuthenticated)")
            navigateToStep(.login)
            return
        }
        
        print("AppFlowView: User is authenticated, checking device status...")
        
        // Check device connection status
        if let connectedDevice = bluetoothManager.connectedDevice {
            print("AppFlowView: Device is connected: \(connectedDevice.name ?? "Unknown")")
            navigateToStep(.main)
        } else {
            print("AppFlowView: No device connected, showing Bluetooth view")
            navigateToStep(.bluetooth)
        }
    }
    
    func navigateToStep(_ step: Step) {
        guard currentStep != step else { 
            print("AppFlowView: Already at step \(step), skipping navigation")
            return 
        }
        
        print("AppFlowView: Navigating from \(currentStep) to \(step)")
        print("AppFlowView: Current state - connectedDevice: \(bluetoothManager.connectedDevice?.name ?? "nil"), isDeviceRegistered: \(bluetoothManager.isDeviceRegistered)")
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = step
        }
    }
    
    // MARK: - Navigation Logic
    
    private func navigateToNextStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            switch currentStep {
            case .launch:
                // Launch is the initial step, handled by evaluateFlow
                break
            case .permission:
                // Permission is handled by Bluetooth state changes
                break
            case .login:
                if authManager.isAuthenticated {
                    currentStep = .bluetooth
                }
            case .bluetooth:
                if bluetoothManager.connectedDevice != nil {
                    currentStep = .main
                }
            case .main:
                // Main is the final step
                break
            case .debug:
                // Debug is a special case, no automatic navigation
                break
            case .emergency:
                // Emergency is a special case, no automatic navigation
                break
            }
        }
    }
    
    private func handleAuthenticationSuccess() {
        print("AppFlowView: Authentication successful, navigating to Bluetooth")
        
        // Delay optimizado para demo fluida
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Timing.navigationDelay) {
            navigateToNextStep()
        }
    }
    
    private func handleDeviceConnection() {
        print("AppFlowView: Device connected, navigating to Main")
        
        // Delay optimizado para demo fluida
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Timing.connectionConfirmationDelay) {
            navigateToNextStep()
        }
    }
    
    // MARK: - Event Handlers
    
    private func handleDeviceConnection(_ device: AnyPeripheral) {
        print("AppFlowView: Device connection callback received for \(device.name ?? "Unknown")")
        print("AppFlowView: Current step: \(currentStep), Target: main")
        
        // Navegación inmediata a MonitoringView
        DispatchQueue.main.async {
            print("AppFlowView: Navigating immediately to main view")
            self.navigateToStep(.main)
        }
    }
    
    private func handleBluetoothStateChange(_ state: CBManagerState) {
        guard !navigationLocked else { return }
        
        switch state {
        case .unauthorized:
            if currentStep != .permission {
                print("AppFlowView: Bluetooth unauthorized, showing permission view")
                navigateToStep(.permission)
            }
        case .poweredOn:
            if currentStep == .permission {
                print("AppFlowView: Bluetooth powered on, re-evaluating flow")
                // Reducir el delay para mejor respuesta
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Timing.navigationDelay) {
                    self.evaluateFlow()
                }
            }
        default:
            break
        }
    }
    
    private func handleConnectedDeviceChange(_ device: AnyPeripheral?) {
        guard !navigationLocked else { return }
        
        if let device = device {
            // Device connected
            if lastConnectedDeviceId != device.identifier {
                print("AppFlowView: New device connected: \(device.name ?? "Unknown")")
                lastConnectedDeviceId = device.identifier
                
                // Solo navegar a main si no estamos ya ahí
                if currentStep != .main {
                    navigateToStep(.main)
                }
            }
        } else {
            // Device disconnected
            print("AppFlowView: Device disconnected")
            lastConnectedDeviceId = nil
            
            // Si estamos en main y se desconecta, quedarnos ahí
            // La gestión de reconexión se hará desde MonitoringView
            print("AppFlowView: Staying in main view for device management")
        }
    }
    
    private func handleUserAuthChange(_ user: User?) {
        guard !navigationLocked else { return }
        
        print("AppFlowView: Auth change detected - user: \(user?.email ?? "nil"), isAuthenticated: \(authManager.isAuthenticated)")
        
        if let _ = user, authManager.isAuthenticated {
            // User logged in
            if currentStep == .login {
                print("AppFlowView: User authenticated, re-evaluating flow")
                // Reducir el delay para mejor respuesta
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Timing.navigationDelay) {
                    self.evaluateFlow()
                }
            }
        } else {
            // User logged out
            if currentStep != .login {
                print("AppFlowView: User logged out, showing login")
                navigateToStep(.login)
            }
        }
    }
}
