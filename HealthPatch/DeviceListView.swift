import SwiftUI
import CoreBluetooth
import Combine

struct DeviceListView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var bluetoothManager: BluetoothManager
    
    @State private var connectionStatus = ""
    @State private var showingConnectionAlert = false
    
    // Callback para navegar de vuelta
    var onDismiss: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Conectar Dispositivo")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Selecciona tu parche HealthPatch o dispositivo compatible")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // Device List Section
                    VStack(spacing: 0) {
                        if bluetoothManager.isScanning {
                            // Scanning State
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                
                                Text("Buscando dispositivos...")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Asegúrate de que tu parche esté encendido y cerca")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 24)
                        } else if displayDevices.isEmpty {
                            // No Devices Found
                            VStack(spacing: 16) {
                                Image(systemName: "wifi.slash")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary)
                                
                                Text("No se encontraron dispositivos")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Asegúrate de que tu parche esté encendido y cerca del dispositivo")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button("Buscar de nuevo") {
                                    bluetoothManager.startScanning()
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(colorScheme == .dark ? Color(.systemGray6) : Color(.tertiarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 24)
                        } else {
                            // Device List
                            LazyVStack(spacing: 0) {
                                ForEach(displayDevices, id: \.id) { device in
                                    VStack(spacing: 0) {
                                        DeviceRow(device: device) {
                                            connectToDevice(device)
                                        }
                                        
                                        if device.id != displayDevices.last?.id {
                                            Divider()
                                                .padding(.leading, 50)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .background(colorScheme == .dark ? Color(.systemGray6) : Color(.tertiarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 24)
                        }
                    }
                    
                    // Control Buttons
                    HStack(spacing: 16) {
                        Button("Cancelar") {
                            // Volver al paso anterior (login)
                            onDismiss?()
                        }
                        .buttonStyle(.bordered)
                        
                        Button(bluetoothManager.isScanning ? "Detener" : "Buscar") {
                            if bluetoothManager.isScanning {
                                bluetoothManager.stopScanning()
                            } else {
                                bluetoothManager.startScanning()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Conectar Dispositivo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        // Volver al paso anterior (login)
                        onDismiss?()
                    }
                }
            }
            .background(colorScheme == .dark ? Color.black : Color(.secondarySystemBackground))
            .onAppear {
                bluetoothManager.startScanning()
            }
            .onDisappear {
                bluetoothManager.stopScanning()
            }
            .alert("Estado de Conexión", isPresented: $showingConnectionAlert) {
                Button("OK") { }
            } message: {
                Text(connectionStatus)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var displayDevices: [AnyPeripheral] {
        var devices: [AnyPeripheral] = []
        
        // 1. Añadir dispositivos mock (siempre presentes)
        if Constants.Demo.alwaysShowMockDevices {
            devices.append(contentsOf: MockPeripheral.demoDevices.map { AnyPeripheral.mock($0) })
        }
        
        // 2. Añadir TODOS los dispositivos reales descubiertos (sin filtros restrictivos)
        let allRealDevices = bluetoothManager.discoveredDevices.filter { device in
            if case .cb(let cbPeripheral) = device.base {
                // Mostrar dispositivos con nombres O con datos técnicos relevantes
                // Ser más permisivo para mostrar más dispositivos
                return true  // Mostrar TODOS los dispositivos reales
            }
            return false
        }
        devices.append(contentsOf: allRealDevices)
        
        // 3. Ordenar por relevancia (mock primero, luego por señal)
        return devices.sorted { device1, device2 in
            // Mock devices primero
            if device1.sortPriority != device2.sortPriority {
                return device1.sortPriority < device2.sortPriority
            }
            
            // Entre dispositivos del mismo tipo, ordenar por señal
            return device1.rssi > device2.rssi
        }
    }
    
    // MARK: - Helper Methods
    
    private func connectToDevice(_ device: AnyPeripheral) {
        print("Connecting to: \(device.name ?? "Unknown")")
        
        // Usar el método unificado de BluetoothManager
        bluetoothManager.connectToPeripheral(device)
        
        // Mostrar estado de conexión
        connectionStatus = "Conectando a \(device.name ?? "Unknown")..."
        showingConnectionAlert = true
        
        // Navegar al paso principal después de un breve delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showingConnectionAlert = false
            // La navegación se manejará automáticamente por AppFlowView
        }
    }
    
    // MARK: - Device Row View
    struct DeviceRow: View {
        let device: AnyPeripheral
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 12) {
                    // Icono diferenciado
                    deviceIcon(for: device)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(device.name ?? "Dispositivo BLE")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        // Mostrar información adicional para dispositivos sin nombres
                        if device.name == nil {
                            Text("ID: \(device.identifier.uuidString.prefix(8))...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            // Mostrar tipo de dispositivo BLE
                            Text("Dispositivo Bluetooth Low Energy")
                                .font(.caption2)
                                .foregroundColor(.purple)
                        } else {
                            // Mostrar ID para dispositivos con nombre también
                            Text("ID: \(device.identifier.uuidString.prefix(8))...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 16) {
                            // Tipo de dispositivo
                            deviceTypeLabel(for: device)
                            
                            // Información técnica relevante
                            if let batteryLevel = device.batteryLevel {
                                batteryIndicator(level: batteryLevel)
                            }
                            
                            signalStrengthIndicator(rssi: device.rssi)
                        }
                    }
                    
                    Spacer()
                    
                    connectionStateIndicator(for: device)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        
        // MARK: - UI Components
        
        private func deviceIcon(for device: AnyPeripheral) -> some View {
            Image(systemName: iconName(for: device))
                .font(.title2)
                .foregroundColor(iconColor(for: device))
                .frame(width: 30)
        }
        
        private func iconName(for device: AnyPeripheral) -> String {
            switch device.base {
            case .mock:
                return "cross.circle.fill"  // Icono médico para mock
            case .cb:
                if device.name == nil {
                    return "dot.radiowaves.left.and.right.circle"  // Icono BLE genérico para dispositivos sin nombre
                } else if let name = device.name?.lowercased() {
                    // Iconos más específicos basados en el nombre
                    if name.contains("mac") || name.contains("macbook") {
                        return "desktopcomputer"
                    } else if name.contains("iphone") {
                        return "iphone"
                    } else if name.contains("ipad") {
                        return "ipad"
                    } else if name.contains("airpods") || name.contains("airpod") {
                        return "airpods"
                    } else if name.contains("watch") || name.contains("applewatch") {
                        return "applewatch"
                    } else if name.contains("patch") || name.contains("medical") || name.contains("health") {
                        return "cross.circle.fill"
                    } else {
                        return "dot.radiowaves.left.and.right"
                    }
                } else {
                    return "dot.radiowaves.left.and.right"
                }
            }
        }
        
        private func iconColor(for device: AnyPeripheral) -> Color {
            switch device.base {
            case .mock:
                return .orange
            case .cb:
                if device.name == nil {
                    return .purple  // Color diferente para dispositivos sin nombre
                } else if let name = device.name?.lowercased() {
                    // Colores más específicos basados en el tipo
                    if name.contains("mac") || name.contains("macbook") {
                        return .blue
                    } else if name.contains("iphone") {
                        return .blue
                    } else if name.contains("ipad") {
                        return .blue
                    } else if name.contains("airpods") || name.contains("airpod") {
                        return .blue
                    } else if name.contains("watch") || name.contains("applewatch") {
                        return .blue
                    } else if name.contains("patch") || name.contains("medical") || name.contains("health") {
                        return .green
                    } else {
                        return .blue
                    }
                } else {
                    return .blue
                }
            }
        }
        
        private func deviceTypeLabel(for device: AnyPeripheral) -> some View {
            let (text, color) = deviceTypeInfo(for: device)
            
            return Text(text)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(color.opacity(0.2))
                .foregroundColor(color)
                .clipShape(Capsule())
        }
        
        private func deviceTypeInfo(for device: AnyPeripheral) -> (String, Color) {
            switch device.base {
            case .mock:
                return ("Demo", .orange)
            case .cb:
                if device.name == nil {
                    return ("BLE Genérico", .purple)  // Etiqueta diferente para dispositivos sin nombre
                } else if let name = device.name?.lowercased() {
                    // Etiquetas más específicas basadas en el nombre
                    if name.contains("mac") || name.contains("macbook") {
                        return ("Mac", .blue)
                    } else if name.contains("iphone") {
                        return ("iPhone", .blue)
                    } else if name.contains("ipad") {
                        return ("iPad", .blue)
                    } else if name.contains("airpods") || name.contains("airpod") {
                        return ("AirPods", .blue)
                    } else if name.contains("watch") || name.contains("applewatch") {
                        return ("Apple Watch", .blue)
                    } else if name.contains("patch") || name.contains("medical") || name.contains("health") {
                        return ("Dispositivo Médico", .green)
                    } else {
                        return ("BLE", .blue)
                    }
                } else {
                    return ("BLE", .blue)
                }
            }
        }
        
        private func batteryIndicator(level: Double) -> some View {
            HStack(spacing: 4) {
                Image(systemName: "battery.100")
                    .font(.caption)
                    .foregroundColor(batteryColor(for: level))
                
                Text("\(Int(level * 100))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        
        private func batteryColor(for level: Double) -> Color {
            if level > 0.7 { return .green }
            else if level > 0.3 { return .orange }
            else { return .red }
        }
        
        private func signalStrengthIndicator(rssi: Int) -> some View {
            HStack(spacing: 4) {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.caption)
                    .foregroundColor(signalColor(for: rssi))
                
                Text("\(rssi) dBm")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        
        private func signalColor(for rssi: Int) -> Color {
            if rssi > -50 { return .green }
            else if rssi > -70 { return .orange }
            else { return .red }
        }
        
        private func connectionStateIndicator(for device: AnyPeripheral) -> some View {
            if device.isConnected {
                return Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            } else {
                return Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    DeviceListView(onDismiss: {})
        .environmentObject(BluetoothManager())
}
