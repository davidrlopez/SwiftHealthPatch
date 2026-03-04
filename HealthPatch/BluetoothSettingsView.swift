import SwiftUI
import CoreBluetooth

struct BluetoothSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @State private var showingDeviceList = false
    @State private var hasUnsavedChanges = false
    @State private var showingSaveAlert = false
    
    // Configuración de Bluetooth
    @State private var isBluetoothEnabled = true
    @State private var allowBackgroundScanning = true
    @State private var showAllDevices = true
    @State private var autoConnect = false
    @State private var scanTimeout: Double = 10.0
    @State private var connectionTimeout: Double = 30.0
    @State private var allowDuplicates = true
    
    var body: some View {
        List {
            // Estado de Bluetooth
            Section("Estado de Bluetooth") {
                HStack {
                    Image(systemName: bluetoothManager.bluetoothState == .poweredOn ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(bluetoothManager.bluetoothState == .poweredOn ? .green : .red)
                    
                    VStack(alignment: .leading) {
                        Text("Bluetooth")
                            .font(.headline)
                        Text(bluetoothStateDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if bluetoothManager.bluetoothState == .poweredOff {
                        Button("Activar") {
                            // Mostrar alerta para activar Bluetooth
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            
            // Dispositivo Conectado
            if let connectedDevice = bluetoothManager.connectedDevice {
                Section("Dispositivo Conectado") {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading) {
                            Text(connectedDevice.name ?? "Dispositivo desconocido")
                                .font(.headline)
                            Text("ID: \(connectedDevice.identifier.uuidString.prefix(8))...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Desconectar") {
                            bluetoothManager.disconnect()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                }
            }
            
            // Opciones de Escaneo
            Section("Opciones de Escaneo") {
                HStack {
                    Text("Tiempo de escaneo")
                    Spacer()
                    Text("\(Int(scanTimeout))s")
                        .foregroundColor(.secondary)
                }
                
                Slider(value: $scanTimeout, in: 5...30, step: 1)
                    .onChange(of: scanTimeout) { _ in
                        hasUnsavedChanges = true
                    }
                
                HStack {
                    Text("Permitir duplicados")
                    Spacer()
                    Toggle("", isOn: $allowDuplicates)
                        .labelsHidden()
                        .tint(.green)
                        .onChange(of: allowDuplicates) { _ in
                            hasUnsavedChanges = true
                        }
                }
                
                Button("Buscar Dispositivos") {
                    showingDeviceList = true
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            
            // Dispositivos Descubiertos
            if !bluetoothManager.discoveredDevices.isEmpty {
                Section("Dispositivos Descubiertos (\(bluetoothManager.discoveredDevices.count))") {
                    ForEach(bluetoothManager.discoveredDevices.prefix(5), id: \.id) { device in
                        HStack {
                            Image(systemName: deviceIcon(for: device))
                                .foregroundColor(deviceColor(for: device))
                            
                            VStack(alignment: .leading) {
                                Text(device.name ?? "Dispositivo BLE")
                                    .font(.subheadline)
                                Text("RSSI: \(device.rssi) dBm")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if device.isConnected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    if bluetoothManager.discoveredDevices.count > 5 {
                        Button("Ver todos (\(bluetoothManager.discoveredDevices.count))") {
                            showingDeviceList = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            
            // Configuración Avanzada
            Section("Configuración Avanzada") {
                NavigationLink("Opciones de Escaneo") {
                    ScanOptionsView()
                }
                
                NavigationLink("Gestión de Dispositivos") {
                    DeviceManagementView()
                }
                
                NavigationLink("Logs de Bluetooth") {
                    BluetoothLogsView()
                }
            }
        }
        .navigationTitle("Configuración Bluetooth")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") {
                    if hasUnsavedChanges {
                        showingSaveAlert = true
                    } else {
                        dismiss()
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Guardar") {
                    saveBluetoothSettings()
                }
                .fontWeight(.semibold)
                .disabled(!hasUnsavedChanges)
            }
        }
        .alert("Cambios sin Guardar", isPresented: $showingSaveAlert) {
            Button("Descartar Cambios", role: .destructive) {
                dismiss()
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Tienes cambios sin guardar en la configuración de Bluetooth. ¿Estás seguro de que quieres salir?")
        }
        .sheet(isPresented: $showingDeviceList) {
            DeviceListView()
                .environmentObject(bluetoothManager)
        }
    }
    
    private var bluetoothStateDescription: String {
        switch bluetoothManager.bluetoothState {
        case .poweredOn:
            return "Activado y funcionando"
        case .poweredOff:
            return "Desactivado"
        case .unauthorized:
            return "Sin permisos"
        case .unsupported:
            return "No soportado"
        case .unknown:
            return "Estado desconocido"
        default:
            return "Inicializando..."
        }
    }
    
    private func deviceIcon(for device: AnyPeripheral) -> String {
        if case .mock = device.base {
            return "cross.circle.fill"
        } else {
            return "dot.radiowaves.left.and.right"
        }
    }
    
    private func deviceColor(for device: AnyPeripheral) -> Color {
        if case .mock = device.base {
            return .orange
        } else {
            return .blue
        }
    }
    
    private func saveBluetoothSettings() {
        // Aquí se guardarían los cambios en el sistema
        print("Guardando configuración de Bluetooth...")
        print("Bluetooth activado: \(isBluetoothEnabled)")
        print("Escaneo en segundo plano: \(allowBackgroundScanning)")
        print("Mostrar todos los dispositivos: \(showAllDevices)")
        print("Conexión automática: \(autoConnect)")
        print("Tiempo de escaneo: \(scanTimeout)s")
        print("Permitir duplicados: \(allowDuplicates)")
        
        hasUnsavedChanges = false
        dismiss()
    }
}

#Preview {
    BluetoothSettingsView()
        .environmentObject(BluetoothManager())
}
