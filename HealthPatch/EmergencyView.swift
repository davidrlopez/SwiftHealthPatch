import SwiftUI

struct EmergencyView: View {
    @Environment(\.dismiss) private var dismiss
    var onRestart: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 32) {
                        // Icono de emergencia
                        emergencyIcon
                        
                        // Mensaje de emergencia
                        emergencyMessage
                        
                        // Botones de acción
                        actionButtons
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                }
            }
            .navigationTitle("Modo de Emergencia")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGray6))
        }
    }
    
    // MARK: - Emergency Icon
    private var emergencyIcon: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            Text("⚠️")
                .font(.system(size: 60))
        }
        .padding(.top, 40)
    }
    
    // MARK: - Emergency Message
    private var emergencyMessage: some View {
        VStack(spacing: 16) {
            Text("App en Modo de Emergencia")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("La aplicación se está ejecutando en modo de emergencia debido a un problema de inicialización.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Información del Sistema:")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "iphone")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        Text("iOS: \(UIDevice.current.systemVersion)")
                    }
                    
                    HStack {
                        Image(systemName: "gear")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        Text("Dispositivo: \(UIDevice.current.model)")
                    }
                    
                    HStack {
                        Image(systemName: "memorychip")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        Text("Memoria disponible: \(ProcessInfo.processInfo.physicalMemory / 1024 / 1024) MB")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button("Reiniciar App") {
                onRestart?()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .font(.headline)
            
            Button("Cerrar") {
                dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .font(.headline)
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Helper Methods
} 