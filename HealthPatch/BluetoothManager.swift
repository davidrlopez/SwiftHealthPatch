import Foundation
import CoreBluetooth
import Combine

protocol PeripheralInfo {
    var name: String? { get }
    var identifier: UUID { get }
}

// MARK: - PeripheralInfo Protocol
struct AnyPeripheral: PeripheralInfo, Identifiable, Equatable {
    let base: Base
    let name: String?
    let identifier: UUID
    var id: UUID { identifier }
    
    // Propiedades adicionales para compatibilidad con el nuevo sistema
    var rssi: Int {
        switch base {
        case .mock(let mock):
            return mock.rssi
        case .cb(let peripheral):
            return -50 // Valor por defecto para dispositivos reales
        }
    }
    
    var batteryLevel: Double? {
        switch base {
        case .mock(let mock):
            return mock.batteryLevel
        case .cb(let peripheral):
            return nil // Para dispositivos reales, esto se obtendría de los servicios
        }
    }
    
    var isConnected: Bool {
        switch base {
        case .mock(let mock):
            return mock.isConnected
        case .cb(let peripheral):
            return peripheral.state == .connected
        }
    }
    
    var deviceType: MockPeripheral.DeviceType? {
        switch base {
        case .mock(let mock):
            return mock.deviceType
        case .cb(let peripheral):
            return inferDeviceType(from: peripheral.name)
        }
    }
    
    var sortPriority: Int {
        switch base {
        case .mock:
            return 0 // Mock devices first
        case .cb:
            return 1 // Real devices second
        }
    }

    init(_ cb: CBPeripheral) {
        self.base = .cb(cb)
        self.name = cb.name
        self.identifier = cb.identifier
    }

    init(_ mock: MockPeripheral) {
        self.base = .mock(mock)
        self.name = mock.name
        self.identifier = mock.id
    }
    
    // Factory methods para compatibilidad
    static func mock(_ mock: MockPeripheral) -> AnyPeripheral {
        return AnyPeripheral(mock)
    }
    
    static func cb(_ peripheral: CBPeripheral) -> AnyPeripheral {
        return AnyPeripheral(peripheral)
    }

    enum Base {
        case cb(CBPeripheral)
        case mock(MockPeripheral)
    }
    
    // MARK: - Helper Methods
    
    private func inferDeviceType(from name: String?) -> MockPeripheral.DeviceType? {
        guard let name = name?.lowercased() else { return nil }
        
        if name.contains("patch") || name.contains("medical") || name.contains("health") {
            return .medicalPatch
        } else if name.contains("fitbit") || name.contains("garmin") || name.contains("polar") {
            return .fitnessTracker
        } else if name.contains("sensor") || name.contains("nordic") || name.contains("esp32") {
            return .sensorDevice
        } else if name.contains("monitor") || name.contains("tracker") {
            return .healthMonitor
        }
        
        return nil
    }

    static func ==(lhs: AnyPeripheral, rhs: AnyPeripheral) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}


// MARK: - Bluetooth Manager
class BluetoothManager: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var discoveredDevices: [AnyPeripheral] = []
    @Published var connectedDevice: AnyPeripheral?
    @Published var registeredDevices: [AnyPeripheral] = []
    @Published var errorMessage: String?
    @Published var bluetoothState: CBManagerState = .unknown
    @Published var isDeviceRegistered: Bool = false
    @Published var isInitialized: Bool = false
    @Published var showPermissionAlert = false

    private var centralManager: CBCentralManager?
    private var scanTimer: Timer?
    private var connectionAttempts: [String: Int] = [:]

    override init() {
        super.init()
        print("BluetoothManager: Initializing...")

        // Reducir el delay de inicialización para mejor respuesta
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.centralManager = CBCentralManager(delegate: self, queue: nil)

            if let _ = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.registeredDeviceUUID) {
                self.isDeviceRegistered = true
                print("BluetoothManager: Device is registered")
            }

            self.isInitialized = true
            print("BluetoothManager: Initialization complete")
        }
    }
    
    // MARK: - Permission Management
    var isPermissionDenied: Bool {
        return bluetoothState == .unauthorized
    }
    
    func requestBluetoothPermission() {
        print("BluetoothManager: Requesting Bluetooth permission...")
        // El permiso se solicita automáticamente cuando se crea el CBCentralManager
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - Scanning Methods
    
    func startScanning() {
        guard let centralManager = centralManager else {
            print("BluetoothManager: Central manager not initialized")
            return
        }
        
        guard centralManager.state == .poweredOn else {
            print("BluetoothManager: Cannot start scanning - Bluetooth not powered on")
            return
        }
        
        guard !isScanning else {
            print("BluetoothManager: Already scanning")
            return
        }
        
        print("BluetoothManager: Starting aggressive scan...")
        isScanning = true
        
        // Añadir dispositivos mock inmediatamente para mejor UX
        if Constants.Demo.alwaysShowMockDevices {
            addMockDevices()
        }
        
        // Limpiar dispositivos anteriores para búsqueda fresca
        discoveredDevices.removeAll { device in
            if case .cb = device.base {
                return true
            }
            return false
        }
        
        print("BluetoothManager: Cleared previous real devices. Starting fresh scan...")
        
        // Escaneo inmediato y agresivo
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Opciones de escaneo más agresivas para detectar MÁS dispositivos
            let scanOptions: [String: Any] = [
                CBCentralManagerScanOptionAllowDuplicatesKey: true,  // Permitir duplicados para mejor detección
                CBCentralManagerScanOptionSolicitedServiceUUIDsKey: []
            ]
            
            // Escanear sin restricciones de servicios para encontrar TODOS los dispositivos
            centralManager.scanForPeripherals(
                withServices: nil,  // Sin filtros de servicios
                options: scanOptions
            )
            
            print("BluetoothManager: Aggressive scan started - looking for ALL devices")
            
            // Timeout de escaneo más largo para búsqueda exhaustiva
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                if self.isScanning {
                    print("BluetoothManager: Extended scan timeout reached")
                    self.stopScanning()
                    
                    // Mostrar resumen final de dispositivos descubiertos
                    self.showScanSummary()
                }
            }
        }
    }
    
    func stopScanning() {
        guard let centralManager = centralManager else { return }
        guard isScanning else { return }
        
        print("BluetoothManager: Stopping scan...")
        centralManager.stopScan()
        isScanning = false
    }
    
    func addMockDevice() {
        let mock = MockPeripheral(
            name: "HealthPatch",
            batteryLevel: 0.85,
            rssi: -45,
            deviceType: .medicalPatch,
            firmwareVersion: "2.1.0"
        )
        discoveredDevices.append(AnyPeripheral(mock))
        print("BluetoothManager: Added mock HealthPatch device. Total devices: \(discoveredDevices.count)")
        
        // Notificar cambio de estado inmediatamente
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func addMockDevices() {
        // Limpiar dispositivos mock existentes
        discoveredDevices.removeAll { device in
            if case .mock = device.base {
                return true
            }
            return false
        }
        
        // Añadir solo 1 dispositivo mock para mejor performance
        let mockDevice = MockPeripheral.demoDevices.first!
        let anyPeripheral = AnyPeripheral(mockDevice)
        discoveredDevices.append(anyPeripheral)
        print("BluetoothManager: Added mock device: \(mockDevice.name)")
        
        print("BluetoothManager: Added 1 mock device. Total devices: \(discoveredDevices.count)")
        
        // Notificar cambio de estado inmediatamente
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }

    // MARK: - Connection Methods
    
    func connect(to peripheral: CBPeripheral) {
        guard let centralManager = centralManager else {
            print("BluetoothManager: Central manager not initialized")
            return
        }
        
        print("BluetoothManager: Connecting to \(peripheral.name ?? "Unknown")")
        
        // Verificar si ya está conectado
        if let connectedDevice = connectedDevice,
           connectedDevice.identifier == peripheral.identifier {
            print("BluetoothManager: Already connected to this device")
            return
        }
        
        // Verificar intentos de reconexión
        if connectionAttempts[peripheral.identifier.uuidString] ?? 0 >= Constants.Bluetooth.maxReconnectionAttempts {
            print("BluetoothManager: Max reconnection attempts reached for \(peripheral.name ?? "Unknown")")
            return
        }
        
        // Incrementar intentos de conexión
        connectionAttempts[peripheral.identifier.uuidString] = (connectionAttempts[peripheral.identifier.uuidString] ?? 0) + 1
        
        // Intentar conexión
        centralManager.connect(peripheral, options: nil)
        
        // Timeout de conexión
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Bluetooth.connectionTimeout) {
            if self.connectedDevice?.identifier != peripheral.identifier {
                print("BluetoothManager: Connection timeout for \(peripheral.name ?? "Unknown")")
                centralManager.cancelPeripheralConnection(peripheral)
            }
        }
    }

    func connectToMockDevice(_ mock: MockPeripheral) {
        print("BluetoothManager: Connecting to mock device: \(mock.name)")
        stopScanning()
        
        // Conexión inmediata para mejor UX
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let anyPeripheralMock = AnyPeripheral(mock)
            self.connectedDevice = anyPeripheralMock
            self.markDeviceAsRegistered(anyPeripheralMock)
            print("BluetoothManager: Mock device connected successfully")
            
            // Notificar cambio de estado inmediatamente
            self.objectWillChange.send()
        }
    }

    func disconnect() {
        print("BluetoothManager: Disconnected from \(connectedDevice?.name ?? "Unknown")")
        connectedDevice = nil
    }

    func connectToPeripheral(_ device: AnyPeripheral) {
        stopScanning()
        switch device.base {
        case .mock(let mock):
            connectToMockDevice(mock)
        case .cb(let peripheral):
            connect(to: peripheral)
        }
    }

    // MARK: - Device registration
    func markDeviceAsRegistered(_ peripheral: AnyPeripheral) {
        let wrapped = peripheral
        if !registeredDevices.contains(where: { $0.identifier == wrapped.identifier }) {
            registeredDevices.append(wrapped)
        }
        UserDefaults.standard.set(peripheral.identifier.uuidString, forKey: Constants.UserDefaultsKeys.registeredDeviceUUID)
        isDeviceRegistered = true
    }

    func forgetDevice() {
        isDeviceRegistered = false
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.registeredDeviceUUID)
        print("BluetoothManager: Device registration forgotten")
    }

    func reconnectToSavedDevice() {
        guard let savedUUIDString = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.registeredDeviceUUID),
              let savedUUID = UUID(uuidString: savedUUIDString),
              let device = discoveredDevices.first(where: { $0.identifier == savedUUID })
        else { return }

        connectToPeripheral(device)
    }

    func loadRegisteredDevice() {
        guard let uuidString = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.registeredDeviceUUID),
              let uuid = UUID(uuidString: uuidString)
        else { return }

        if let device = discoveredDevices.first(where: { $0.identifier == uuid }) {
            connectedDevice = device
            isDeviceRegistered = true
        } else {
            let mock = MockPeripheral(
                name: "Registered Device",
                batteryLevel: 0.90,
                rssi: -50,
                deviceType: .medicalPatch,
                firmwareVersion: "2.0.0"
            )
            connectedDevice = AnyPeripheral(mock)
            isDeviceRegistered = true
        }
    }

    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Error Handling
    private func handleError(_ error: Error, context: String) {
        let errorMessage: String
        switch error {
        case let cbError as CBError:
            switch cbError.code {
            case .connectionTimeout:
                errorMessage = Constants.ErrorMessages.connectionTimeout
            case .peripheralDisconnected:
                errorMessage = Constants.ErrorMessages.peripheralDisconnected
            case .connectionFailed:
                errorMessage = Constants.ErrorMessages.connectionFailed
            default:
                errorMessage = "Error de Bluetooth: \(cbError.localizedDescription)"
            }
        default:
            errorMessage = "Error inesperado: \(error.localizedDescription)"
        }
        
        DispatchQueue.main.async {
            self.errorMessage = "\(context): \(errorMessage)"
        }
    }
    
    private func showError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
        }
    }

    // MARK: - Scan Summary
    private func showScanSummary() {
        let realDevices = discoveredDevices.filter { device in
            if case .cb = device.base {
                return true
            }
            return false
        }
        
        let namedDevices = realDevices.filter { $0.name != nil }
        let unnamedDevices = realDevices.filter { $0.name == nil }
        
        print("BluetoothManager: === SCAN SUMMARY ===")
        print("BluetoothManager: Total real devices discovered: \(realDevices.count)")
        print("BluetoothManager: Named devices: \(namedDevices.count)")
        print("BluetoothManager: Unnamed devices: \(unnamedDevices.count)")
        
        if !namedDevices.isEmpty {
            print("BluetoothManager: Named devices:")
            for device in namedDevices {
                print("  - \(device.name ?? "Unknown")")
            }
        }
        
        if !unnamedDevices.isEmpty {
            print("BluetoothManager: Unnamed devices:")
            for device in unnamedDevices {
                let shortId = device.identifier.uuidString.prefix(8)
                print("  - BLE Device \(shortId)...")
            }
        }
        
        print("BluetoothManager: ======================")
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = central.state
        switch central.state {
        case .poweredOff:
            errorMessage = Constants.ErrorMessages.bluetoothPoweredOff
            isScanning = false
        case .unauthorized:
            errorMessage = Constants.ErrorMessages.bluetoothUnauthorized
            showPermissionAlert = true
        case .unsupported:
            errorMessage = Constants.ErrorMessages.bluetoothUnsupported
        case .poweredOn:
            errorMessage = nil
            print("BluetoothManager: Bluetooth is ready")
        default:
            break
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("BluetoothManager: Discovered real device: \(peripheral.name ?? "Unknown") - RSSI: \(RSSI)")
        print("BluetoothManager: Advertisement data keys: \(advertisementData.keys)")
        
        // Mostrar información adicional de los datos de anuncio
        if let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] {
            print("BluetoothManager: Manufacturer data found: \(manufacturerData)")
        }
        if let serviceData = advertisementData["kCBAdvDataServiceData"] {
            print("BluetoothManager: Service data found: \(serviceData)")
        }
        if let services = advertisementData["kCBAdvDataServiceUUIDs"] {
            print("BluetoothManager: Services found: \(services)")
        }
        
        // Verificar si el dispositivo ya está en la lista
        let existingDevice = discoveredDevices.first { device in
            if case .cb(let cb) = device.base {
                // Para dispositivos sin nombre, usar solo el identificador
                // Para dispositivos con nombre, usar nombre + identificador
                if peripheral.name == nil {
                    return cb.identifier == peripheral.identifier
                } else {
                    return cb.identifier == peripheral.identifier && cb.name == peripheral.name
                }
            }
            return false
        }
        
        if existingDevice == nil {
            // MOSTRAR prácticamente todos los dispositivos que tengan algún tipo de datos
            // Ser muy permisivo para detectar más dispositivos Bluetooth reales
            let hasName = peripheral.name != nil && peripheral.name!.count > 0
            let hasManufacturerData = advertisementData["kCBAdvDataManufacturerData"] != nil
            let hasServiceData = advertisementData["kCBAdvDataServiceData"] != nil
            let hasServices = advertisementData["kCBAdvDataServiceUUIDs"] != nil
            let hasTxPower = advertisementData["kCBAdvDataTxPowerLevel"] != nil
            let hasTimestamp = advertisementData["kCBAdvDataTimestamp"] != nil
            let hasConnectable = advertisementData["kCBAdvDataIsConnectable"] != nil
            let hasPHY = advertisementData["kCBAdvDataRxPrimaryPHY"] != nil || advertisementData["kCBAdvDataRxSecondaryPHY"] != nil
            
            // Mostrar si tiene CUALQUIER tipo de datos de anuncio
            // Esto incluirá prácticamente todos los dispositivos Bluetooth reales
            // Incluso los que solo tienen datos básicos de conectividad
            let shouldShowDevice = hasName || hasManufacturerData || hasServiceData || hasServices || hasTxPower || hasTimestamp || hasConnectable || hasPHY
            
            // Log detallado de los datos disponibles
            print("BluetoothManager: Device data analysis for \(peripheral.identifier.uuidString.prefix(8))...:")
            print("  - Has name: \(hasName)")
            print("  - Has manufacturer data: \(hasManufacturerData)")
            print("  - Has service data: \(hasServiceData)")
            print("  - Has services: \(hasServices)")
            print("  - Has TX power: \(hasTxPower)")
            print("  - Has timestamp: \(hasTimestamp)")
            print("  - Has connectable: \(hasConnectable)")
            print("  - Has PHY: \(hasPHY)")
            print("  - Should show: \(shouldShowDevice)")
            
            // Comentario adicional sobre por qué se incluye o excluye
            if shouldShowDevice {
                let reason = hasName ? "Has name" : 
                            hasManufacturerData ? "Has manufacturer data" :
                            hasServiceData ? "Has service data" :
                            hasServices ? "Has services" :
                            hasTxPower ? "Has TX power" :
                            hasTimestamp ? "Has timestamp" :
                            hasConnectable ? "Has connectable info" :
                            hasPHY ? "Has PHY info" : "Unknown reason"
                print("BluetoothManager: Including device because: \(reason)")
            } else {
                print("BluetoothManager: Excluding device - no relevant data found")
            }
            
            if shouldShowDevice {
                let newDevice = AnyPeripheral(peripheral)
                discoveredDevices.append(newDevice)
                
                let deviceDescription: String
                if hasName {
                    deviceDescription = peripheral.name!
                } else {
                    // Crear un nombre descriptivo para dispositivos sin nombre
                    let shortId = peripheral.identifier.uuidString.prefix(8)
                    if hasManufacturerData {
                        deviceDescription = "Dispositivo BLE (Fabricante) - \(shortId)"
                    } else if hasServiceData {
                        deviceDescription = "Dispositivo BLE (Servicios) - \(shortId)"
                    } else if hasServices {
                        deviceDescription = "Dispositivo BLE (UUIDs) - \(shortId)"
                    } else if hasTxPower {
                        deviceDescription = "Dispositivo BLE (Potencia) - \(shortId)"
                    } else {
                        deviceDescription = "Dispositivo BLE - \(shortId)"
                    }
                }
                
                print("BluetoothManager: Added real device: \(deviceDescription). Total devices: \(discoveredDevices.count)")
                
                // Mostrar estadísticas de dispositivos
                let namedDevices = discoveredDevices.filter { device in
                    if case .cb = device.base {
                        return device.name != nil
                    }
                    return false
                }.count
                
                let unnamedDevices = discoveredDevices.filter { device in
                    if case .cb = device.base {
                        return device.name == nil
                    }
                    return false
                }.count
                
                print("BluetoothManager: Device stats - Named: \(namedDevices), Unnamed: \(unnamedDevices), Total: \(discoveredDevices.count)")
                
                // Notificar cambio de estado inmediatamente
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            } else {
                print("BluetoothManager: Skipping device - no relevant data found")
            }
        } else {
            print("BluetoothManager: Device already in list: \(peripheral.name ?? "Unknown")")
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedDevice = AnyPeripheral(peripheral)
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        print("BluetoothManager: Connected to CBPeripheral \(peripheral.name ?? "Unknown")")
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            handleError(error, context: "Conexión fallida")
        } else {
            showError("No se pudo conectar al dispositivo")
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if connectedDevice?.identifier == peripheral.identifier {
            connectedDevice = nil
        }
        if let error = error {
            handleError(error, context: "Desconexión")
        }
    }
}

// MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.properties.contains(.read) { peripheral.readValue(for: characteristic) }
            if characteristic.properties.contains(.notify) { peripheral.setNotifyValue(true, for: characteristic) }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            print("Datos recibidos: \(data)")
        }
    }
}
