//
//  Constants.swift
//  HealthPatch
//
//  Created by David Roman Lopez on 8/6/25.
//

import Foundation
import UIKit

struct Constants {
    struct Timing {
        // Tiempos optimizados para demo fluida pero creíble
        static let appInitializationDelay: TimeInterval = 0.3
        static let bluetoothInitializationDelay: TimeInterval = 0.2
        static let navigationDelay: TimeInterval = 0.1
        static let connectionConfirmationDelay: TimeInterval = 0.3
        
        // Diferenciación mock vs real (ambos rápidos pero diferentes)
        static let mockConnectionDelay: TimeInterval = 0.5        // Más rápido para demo
        static let realDeviceConnectionDelay: TimeInterval = 1.5  // Realista pero fluido
        
        // Escaneo: muy rápido para mejor UX
        static let scanStartDelay: TimeInterval = 0.05           // Casi inmediato
        static let scanTimeout: TimeInterval = 10.0              // Más largo para búsqueda exhaustiva
        
        // UI feedback rápido
        static let errorDisplayDuration: TimeInterval = 2.5
        static let successDisplayDuration: TimeInterval = 1.5
    }
    
    struct Demo {
        // Configuración para dispositivos mock siempre presentes
        static let alwaysShowMockDevices = true
        static let mockDeviceNames = [
            "HealthPatch v2.1",
            "HealthPatch Pro", 
            "TestPatch Alpha"
        ]
    }
    
    struct Bluetooth {
        static let scanOptionAllowDuplicates = true  // Permitir duplicados para mejor detección
        static let maxReconnectionAttempts = 3
        static let connectionTimeout: TimeInterval = 8.0  // Suficiente para demo
        
        // Filtros más permisivos para dispositivos relevantes en demo
        static let relevantDeviceKeywords = [
            "HealthPatch", "Medical", "Health", "Patch", "Monitor",
            "Nordic", "ESP32", "Arduino", "Tile", "Fitbit", "Garmin", "Polar",
            "Mac", "Windows", "Linux", "Android", "iPhone", "iPad", "AirPods"  // Incluir más dispositivos
        ]
    }
    
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let buttonHeight: CGFloat = 50
        static let sectionSpacing: CGFloat = 24
        static let itemSpacing: CGFloat = 16
    }
    
    // MARK: - UserDefaults Keys
    struct UserDefaultsKeys {
        static let registeredDeviceUUID = "registeredDeviceUUID"
        static let authToken = "auth_token"
        static let userData = "user_data"
        static let savedUser = "savedUser"
    }
    
    // MARK: - Error Messages
    struct ErrorMessages {
        static let bluetoothNotInitialized = "Bluetooth no está inicializado"
        static let bluetoothNotAvailable = "Bluetooth no está disponible"
        static let bluetoothPoweredOff = "Bluetooth está desactivado"
        static let bluetoothUnauthorized = "La app no tiene permisos para usar Bluetooth"
        static let bluetoothUnsupported = "Este dispositivo no soporta Bluetooth"
        static let connectionTimeout = "Tiempo de conexión agotado. Intenta de nuevo."
        static let peripheralDisconnected = "Dispositivo desconectado. Verifica la conexión."
        static let connectionFailed = "Fallo en la conexión. Verifica que el dispositivo esté disponible."
    }
}
