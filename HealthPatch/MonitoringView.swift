import SwiftUI
import CoreBluetooth
import Combine

struct MonitoringView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @State private var scanTimer: Timer?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedTab: Tab = .home
    @State private var selectedTimePeriod: TimePeriod = .last24Hours
    @State private var showingDeviceList = false
    @State private var showingDisconnectAlert = false
    @State private var profileImage: Image?
    @State private var deviceName = "HealthPatch"
    @State private var isEditingDeviceName = false
    @State private var tempDeviceName = ""
    
    enum Tab {
        case home, metrics, settings, userAccount
    }
    
    enum TimePeriod {
        case last24Hours, last7Days
    }
    
    // MARK: - Helper Functions for Patch Usage
    private func patchLevel(for dayIndex: Int) -> CGFloat {
        let dayOfWeek = dayIndex
        let isPatchChangeDay = dayOfWeek == 0 || dayOfWeek == 3 // Monday and Thursday
        
        if isPatchChangeDay {
            return 1.0 // New patch starts at 100%
        }
        
        // Calculate hours since last patch change (each day = 24 hours)
        let hoursSinceLastChange: Int
        if dayOfWeek < 3 {
            hoursSinceLastChange = dayOfWeek * 24 // Days since Monday
        } else {
            hoursSinceLastChange = (dayOfWeek - 3) * 24 // Days since Thursday
        }
        
        // Calculate patch level: starts at 100% and decreases linearly over 24 hours
        // Day 1 after change: ~75%, Day 2: ~50%, Day 3: ~25%
        let daysSinceChange = CGFloat(hoursSinceLastChange) / 24.0
        return max(0.05, 1.0 - (daysSinceChange * 0.35)) // Decrease by ~35% per day
    }
    
    private func patchColor(for dayIndex: Int) -> Color {
        let dayOfWeek = dayIndex
        let isPatchChangeDay = dayOfWeek == 0 || dayOfWeek == 3
        let level = patchLevel(for: dayIndex)
        let isLowPatch = level < 0.25
        
        if isPatchChangeDay {
            return .blue
        } else if isLowPatch {
            return .red
        } else {
            return .green
        }
    }
    
    private func isPatchChangeDay(for dayIndex: Int) -> Bool {
        let dayOfWeek = dayIndex
        return dayOfWeek == 0 || dayOfWeek == 3 // Monday and Thursday
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        switch selectedTab {
                        case .home:
                            homeTabContent
                        case .metrics:
                            metricsTabContent
                        case .settings:
                            settingsTabContent
                        case .userAccount:
                            userAccountTabContent
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 24)
                }
                .background(colorScheme == .dark ? Color.black : Color(.secondarySystemBackground))
                
                bottomTabBar
            }
            .background(colorScheme == .dark ? Color.black : Color(.systemBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                setupMonitoring()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                loadProfileImage()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ProfileImageUpdated"))) { _ in
                updateProfileImage()
            }
            .alert("Información", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .alert("Confirmar Desconexión", isPresented: $showingDisconnectAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Desconectar", role: .destructive) {
                    disconnectDevice()
                }
            } message: {
                Text("¿Estás seguro de que quieres desconectar el dispositivo?")
            }
            .background(colorScheme == .dark ? Color.black : Color(.systemBackground))
        }
        .sheet(isPresented: $showingDeviceList) {
            DeviceListView(onDismiss: {
                showingDeviceList = false
            })
        }
    }
    
    // MARK: - Home Tab Content
    private var homeTabContent: some View {
        VStack(spacing: 24) {
            // Animación de AirPods
            airpodsAnimationSection
            
            deviceMetricsSection
        }
    }
    
    // MARK: - AirPods Animation Section
    private var airpodsAnimationSection: some View {
        VStack(spacing: 16) {
            // AirPods individuales y case como en iOS
            HStack(spacing: 32) {
                // Left AirPod
                VStack(spacing: 12) {
                    Group {
                        if colorScheme == .dark {
                            Image("airpodsAd")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
            } else {
                            Image("airpodslight")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
            }
    }
    
                    // Battery indicator - exactamente como en iOS
        HStack(spacing: 6) {
                        Image(systemName: "battery.100")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                        Text("81%")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                // AirPods Case
                VStack(spacing: 12) {
                    Group {
                        if colorScheme == .dark {
                            Image("airpods caseAd")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 110, height: 110)
                        } else {
                            Image("airpods caselight")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 110, height: 110)
                        }
                    }
                    
                    // Battery indicator - exactamente como en iOS
                    HStack(spacing: 6) {
                        Image(systemName: "battery.100")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                        Text("77%")
                            .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    }
                }
            }
            .scaleEffect(1.0)
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: UUID())
            
            // Campo editable de nombre como en iOS
            Button(action: {
                isEditingDeviceName = true
            }) {
            HStack {
                    Text("Nombre")
                    .font(.subheadline)
                        .foregroundColor(.primary)
                
                Spacer()
                    
                    Text(deviceName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
                    .padding()
                .background(colorScheme == .dark ? Color(.systemGray6) : Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .sheet(isPresented: $isEditingDeviceName) {
            deviceNameEditView
        }
    }
    

    
    // MARK: - Device Metrics Section
    private var deviceMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Métricas del Dispositivo")
                .font(.title2)
                .fontWeight(.semibold)
            
            if let connectedDevice = bluetoothManager.connectedDevice {
                VStack(spacing: 20) {
                    activitySummarySection
                    patchUsageHomeSection
                }
            } else {
                Text("Conecta un dispositivo para ver las métricas")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .dark ? Color(.systemGray6) : Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    // MARK: - Patch Usage Home Section
    private var patchUsageHomeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Uso del Parche")
                .font(.headline)
            
            // Current Patch Information
            VStack(alignment: .leading, spacing: 4) {
                Text("Uso del parche hoy")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("18h 32m de 24h disponibles")
                    .font(.title3)
                    .fontWeight(.medium)
            }
            
            // PATCH USAGE Graph
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("BATTERY LEVEL")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("18h 32m")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Graph with bars
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach([100, 75, 50, 25, 0], id: \.self) { percentage in
                                Text("\(percentage)%")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(height: 16)
                            }
                        }
                        .frame(width: 30)
                        
                        ZStack {
                            // Horizontal dashed grid lines like Apple - properly aligned with Y-axis labels
                            VStack(spacing: 0) {
                                ForEach(0..<4, id: \.self) { _ in
                                    DashedLine()
                                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                                        .frame(height: 0.5)
                                    Spacer()
                                        .frame(height: 20)
                                }
                            }
                            
                            // Vertical dashed grid lines like Apple - aligned with X-axis labels
                            HStack(spacing: 0) {
                                // For 24 hours: 4 major grid lines at 00, 06, 12, 18
                                ForEach(0..<4, id: \.self) { index in
                                    DashedLine()
                                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                                        .frame(width: 0.5, height: 100)
                                    
                                    if index < 3 {
                                        Spacer()
                                            .frame(width: 75) // 300 / 4 = 75
                                    }
                                }
                            }
                            
                            // Bars like Apple - properly spaced and aligned
                            HStack(alignment: .bottom, spacing: 4) {
                                ForEach(0..<24, id: \.self) { index in
                                    // Single patch that lasts 24 hours - decreases from 100% to 0%
                                    let patchLevel = max(0.05, 1.0 - (CGFloat(index) / 24.0)) // Linear decrease from 100% to 0%
                                    
                                    // Only one patch change at the beginning of the day
                                    let isPatchChange = index == 0 // New patch starts at 00:00
                                    let isLowPatch = patchLevel < 0.25 // Less than 25% remaining (red)
                                    
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 1)
                                            .fill(isPatchChange ? Color.blue : (isLowPatch ? Color.red : Color.green))
                                            .frame(width: 8, height: 80 * patchLevel)
                                        
                                        // Visual indicator for patch change
                                        if isPatchChange {
                                            Image(systemName: "arrow.up.circle.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 8))
                                                .offset(y: -35)
                                        }
                                    }
                                }
                            }
                            
                            // Dotted lines connecting bars to X-axis (like Apple)
                            HStack(spacing: 4) {
                                ForEach(0..<24, id: \.self) { index in
                                    DashedLine()
                                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 0.5, dash: [1, 1]))
                                        .frame(width: 0.5, height: 20)
                                        .offset(y: 50)
                                }
                            }
                            
                            // Dotted lines connecting bars to X-axis labels (like Apple)
                            HStack(spacing: 4) {
                                ForEach(0..<24, id: \.self) { index in
                                    DashedLine()
                                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 0.5, dash: [1, 1]))
                                        .frame(width: 0.5, height: 20)
                                        .offset(y: 50)
                                }
                            }
                            
                            // Dotted lines connecting bars to X-axis labels (like Apple)
                            HStack(spacing: 4) {
                                ForEach(0..<24, id: \.self) { index in
                                    DashedLine()
                                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 0.5, dash: [1, 1]))
                                        .frame(width: 0.5, height: 20)
                                        .offset(y: 50)
                                }
                            }
                        }
                    }
                    
                    // X-axis labels with time intervals like Apple
                    HStack {
                        Spacer()
                            .frame(width: 30)
                        
                            HStack(spacing: 0) {
                            ForEach(["18", "21", "00", "03", "06", "09", "12", "15"], id: \.self) { time in
                                Text(time)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
            
            // Patch Usage Information
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("El parche se usa durante el día y se retira por la noche")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.orange)
                    Text("Tiempo restante hoy: 5h 28m")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                    Text("Uso alto: Considerar descanso en las próximas horas")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(.systemGray6) : Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Activity Summary Section
    private var activitySummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resumen de Actividad")
                .font(.headline)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tiempo Conectado")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("2h 34m")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Última Actualización")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Ahora")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(colorScheme == .dark ? Color(.systemGray6) : Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Metrics Tab Content
    private var metricsTabContent: some View {
        VStack(spacing: 24) {
            Text("Métricas Detalladas")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Gráfica de Uso del Parche
            patchUsageSection
            
            // Gráfica de Actividad
            activityGraphSection
            
            // Gráfica de Batería
            batterySection
            
            // Estadísticas del Dispositivo
            VStack(alignment: .leading, spacing: 16) {
                Text("Estadísticas del Dispositivo")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    // Device Uptime
                    HStack {
                        Image(systemName: "clock.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Tiempo de Actividad")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("2h 34m")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("98%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color(.systemGray6) : Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Signal Strength
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Fuerza de Señal")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Excelente")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("-45 dBm")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
    }
    
    // MARK: - Patch Usage Section
    private var patchUsageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Time Period Selector
            HStack(spacing: 12) {
                Button("Últimas 24 horas") {
                    selectedTimePeriod = .last24Hours
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(selectedTimePeriod == .last24Hours ? Color.blue : Color(.systemGray5))
                .foregroundColor(selectedTimePeriod == .last24Hours ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Button("Últimos 7 días") {
                    selectedTimePeriod = .last7Days
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(selectedTimePeriod == .last7Days ? Color.blue : Color(.systemGray5))
                .foregroundColor(selectedTimePeriod == .last7Days ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            
            // Current Patch Information
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedTimePeriod == .last24Hours ? "Uso del parche hoy" : "Uso del parche esta semana")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(selectedTimePeriod == .last24Hours ? "18h 32m de 24h disponibles" : "5d 12h de 7d disponibles")
                    .font(.title3)
                    .fontWeight(.medium)
            }
            
            // PATCH USAGE Graph
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("PATCH USAGE")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(selectedTimePeriod == .last24Hours ? "18h 32m" : "5d 12h")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Graph with bars
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach([100, 75, 50, 25, 0], id: \.self) { percentage in
                                Text("\(percentage)%")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(height: 16)
                            }
                        }
                        .frame(width: 30)
                        
                        ZStack {
                            // Horizontal dashed grid lines like Apple - properly aligned with Y-axis labels
                            VStack(spacing: 0) {
                                ForEach(0..<4, id: \.self) { _ in
                                    DashedLine()
                                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                                        .frame(height: 0.5)
                                    Spacer()
                                        .frame(height: 20)
                                }
                            }
                            
                            // Vertical dashed grid lines like Apple - aligned with X-axis labels
                            HStack(spacing: 0) {
                                if selectedTimePeriod == .last24Hours {
                                    // For 24 hours: 4 major grid lines at 00, 06, 12, 18
                                    ForEach(0..<4, id: \.self) { index in
                                        DashedLine()
                                            .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                                            .frame(width: 0.5, height: 100)
                                        
                                        if index < 3 {
                                            Spacer()
                                                .frame(width: 75) // 300 / 4 = 75
                                        }
                                    }
                                } else {
                                    // For 7 days: 7 grid lines - properly aligned with bars
                                    ForEach(0..<7, id: \.self) { index in
                                        DashedLine()
                                            .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                                            .frame(width: 0.5, height: 100)
                                        
                                        if index < 6 {
                                            Spacer()
                                                .frame(width: 42.8) // 300 / 7 ≈ 42.8
                                        }
                                    }
                                }
                            }
                            
                            // Bars like Apple - properly spaced and aligned
                            HStack(alignment: .bottom, spacing: selectedTimePeriod == .last24Hours ? 4 : 8) {
                                if selectedTimePeriod == .last24Hours {
                                    // 24 bars for 24 hours - more spaced out
                                    ForEach(0..<24, id: \.self) { index in
                                        // Single patch that lasts 24 hours - decreases from 100% to 0%
                                        let patchLevel = max(0.05, 1.0 - (CGFloat(index) / 24.0)) // Linear decrease from 100% to 0%
                                        
                                        // Only one patch change at the beginning of the day
                                        let isPatchChange = index == 0 // New patch starts at 00:00
                                        let isLowPatch = patchLevel < 0.25 // Less than 25% remaining (red)
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 1)
                                                .fill(isPatchChange ? Color.blue : (isLowPatch ? Color.red : Color.green))
                                                .frame(width: 8, height: 80 * patchLevel)
                                            
                                            // Visual indicator for patch change
                                            if isPatchChange {
                                                Image(systemName: "arrow.up.circle.fill")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 8))
                                                    .offset(y: -35)
                                            }
                                        }
                                    }
                                } else {
                                    // 7 bars for 7 days - properly aligned with grid
                                    ForEach(0..<7, id: \.self) { index in
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 1)
                                                .fill(patchColor(for: index))
                                                .frame(width: 35, height: 80 * patchLevel(for: index))
                                            
                                            if isPatchChangeDay(for: index) {
                                                Image(systemName: "arrow.up.circle.fill")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 12))
                                                    .offset(y: -35)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // X-axis labels like Apple
                        HStack {
                            Spacer()
                                .frame(width: 30)
                            
                                HStack(spacing: 0) {
                            if selectedTimePeriod == .last24Hours {
                                ForEach(["00", "06", "12", "18"], id: \.self) { time in
                                    Text(time)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity)
                                }
                            } else {
                                    ForEach(["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"], id: \.self) { day in
                                        Text(day)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                }
            }
            
            // Patch Usage Information
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("El parche se usa durante el día y se retira por la noche")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.orange)
                    Text("Tiempo restante hoy: 5h 28m")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                    Text("Uso alto: Considerar descanso en las próximas horas")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    // MARK: - Activity Graph Section
    private var activityGraphSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ACTIVIDAD")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach([60, 45, 30, 15, 0], id: \.self) { minutes in
                                Text("\(minutes)m")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                .frame(height: 15)
                        }
                    }
                    .frame(width: 30)
                    
                    ZStack {
                        // Horizontal dashed grid lines like Apple - properly aligned with Y-axis labels
                        VStack(spacing: 0) {
                            ForEach(0..<4, id: \.self) { _ in
                                DashedLine()
                                    .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                                    .frame(height: 0.5)
                                Spacer()
                                    .frame(height: 15)
                            }
                        }
                        
                        // Vertical dashed grid lines like Apple - aligned with X-axis labels
                        HStack(spacing: 0) {
                            if selectedTimePeriod == .last24Hours {
                                // For 24 hours: 4 major grid lines at 00, 06, 12, 18
                                ForEach(0..<4, id: \.self) { index in
                                    DashedLine()
                                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                                        .frame(width: 0.5, height: 60)
                                    
                                    if index < 3 {
                                        Spacer()
                                            .frame(width: 75) // 300 / 4 = 75
                                    }
                                }
                            } else {
                                // For 7 days: 7 grid lines - properly aligned
                                ForEach(0..<7, id: \.self) { index in
                                    DashedLine()
                                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                                        .frame(width: 0.5, height: 60)
                                    
                                    if index < 6 {
                                        Spacer()
                                            .frame(width: 42.8) // 300 / 7 ≈ 42.8
                                    }
                                }
                            }
                        }
                        
                        // Activity bars like Apple - properly spaced and aligned
                        HStack(alignment: .bottom, spacing: selectedTimePeriod == .last24Hours ? 4 : 8) {
                            if selectedTimePeriod == .last24Hours {
                                // 24 bars for 24 hours - more spaced out
                                ForEach(0..<24, id: \.self) { index in
                                let screenOnHeight = CGFloat.random(in: 0.1...0.8)
                                let screenOffHeight = CGFloat.random(in: 0.1...0.4)
                                
                                VStack(spacing: 0) {
                                    Rectangle()
                                        .fill(Color.blue.opacity(0.3))
                                            .frame(width: 8, height: 60 * screenOffHeight)
                                    
                                    Rectangle()
                                        .fill(Color.blue)
                                            .frame(width: 8, height: 60 * screenOnHeight)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 1))
                                }
                            } else {
                                // 7 bars for 7 days - properly aligned with grid
                                ForEach(0..<7, id: \.self) { index in
                                    let screenOnHeight = CGFloat.random(in: 0.1...0.8)
                                    let screenOffHeight = CGFloat.random(in: 0.1...0.4)
                                    
                                    VStack(spacing: 0) {
                                        Rectangle()
                                            .fill(Color.blue.opacity(0.3))
                                            .frame(width: 35, height: 60 * screenOffHeight)
                                        
                                        Rectangle()
                                            .fill(Color.blue)
                                            .frame(width: 35, height: 60 * screenOnHeight)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 1))
                                }
                            }
                        }
                        
                        // Dotted lines connecting bars to X-axis (like Apple)
                        HStack(spacing: selectedTimePeriod == .last24Hours ? 4 : 8) {
                            if selectedTimePeriod == .last24Hours {
                                // 24 dotted lines for 24 hours
                                ForEach(0..<24, id: \.self) { index in
                                    DashedLine()
                                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                                        .frame(width: 1, height: 30)
                                }
                            } else {
                                // 7 dotted lines for 7 days
                                ForEach(0..<7, id: \.self) { index in
                                    DashedLine()
                                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                                        .frame(width: 1, height: 30)
                                }
                            }
                        }
                    }
                    .frame(height: 80)
                    
                    Spacer()
                }
                
                // X-axis time labels like Apple
                    HStack {
                        Spacer()
                            .frame(width: 30)
                        
                            HStack(spacing: 0) {
                        if selectedTimePeriod == .last24Hours {
                            ForEach(["00", "06", "12", "18"], id: \.self) { time in
                                Text(time)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                            }
                        } else {
                                ForEach(["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"], id: \.self) { day in
                                    Text(day)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
            
            // Activity Summary
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pantalla Encendida")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("3h 57m")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pantalla Apagada")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("1h 50m")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Battery Section
    private var batterySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("BATERÍA")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach([100, 75, 50, 25, 0], id: \.self) { percentage in
                            Text("\(percentage)%")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(height: 16)
                        }
                    }
                    .frame(width: 30)
                    
                    ZStack {
                        // Horizontal dashed grid lines like Apple - properly aligned with Y-axis labels
                        VStack(spacing: 0) {
                            ForEach(0..<4, id: \.self) { _ in
                                DashedLine()
                                    .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                                    .frame(height: 0.5)
                                Spacer()
                                    .frame(height: 20)
                            }
                        }
                        
                        // Vertical dashed grid lines like Apple - aligned with X-axis labels
                        HStack(spacing: 0) {
                            if selectedTimePeriod == .last24Hours {
                                // For 24 hours: 4 major grid lines at 00, 06, 12, 18
                                ForEach(0..<4, id: \.self) { index in
                                    DashedLine()
                                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                                        .frame(width: 0.5, height: 100)
                                    
                                    if index < 3 {
                                        Spacer()
                                            .frame(width: 75) // 300 / 4 = 75
                                    }
                                }
                            } else {
                                // For 7 days: 7 grid lines - properly aligned
                                ForEach(0..<7, id: \.self) { index in
                                    DashedLine()
                                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                                        .frame(width: 0.5, height: 100)
                                    
                                    if index < 6 {
                                        Spacer()
                                            .frame(width: 42.8) // 300 / 7 ≈ 42.8
                                    }
                                }
                            }
                        }
                        
                        // Battery bars like Apple - properly spaced and aligned
                        HStack(alignment: .bottom, spacing: selectedTimePeriod == .last24Hours ? 4 : 8) {
                                                            if selectedTimePeriod == .last24Hours {
                                    // 24 bars for 24 hours - more spaced out
                                    ForEach(0..<24, id: \.self) { index in
                                        let batteryLevel = CGFloat.random(in: 0.1...1.0)
                                        let batteryPercentage = batteryLevel * 100
                                        
                                        RoundedRectangle(cornerRadius: 1)
                                            .fill(batteryPercentage < 20 ? Color.red : Color.green)
                                            .frame(width: 8, height: 80 * batteryLevel)
                                    }
                                } else {
                                    // 7 bars for 7 days - properly aligned with grid
                                    ForEach(0..<7, id: \.self) { index in
                                        let batteryLevel = CGFloat.random(in: 0.1...1.0)
                                        let batteryPercentage = batteryLevel * 100
                                        
                                        RoundedRectangle(cornerRadius: 1)
                                            .fill(batteryPercentage < 20 ? Color.red : Color.green)
                                            .frame(width: 35, height: 80 * batteryLevel)
                                    }
                                }
                        }
                        
                        // Dotted lines connecting bars to X-axis (like Apple)
                        HStack(spacing: selectedTimePeriod == .last24Hours ? 4 : 8) {
                            if selectedTimePeriod == .last24Hours {
                                // 24 dotted lines for 24 hours
                                ForEach(0..<24, id: \.self) { index in
                                    DashedLine()
                                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                                        .frame(width: 1, height: 40)
                                }
                            } else {
                                // 7 dotted lines for 7 days
                                ForEach(0..<7, id: \.self) { index in
                                    DashedLine()
                                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                                        .frame(width: 1, height: 40)
                                }
                            }
                        }
                        .frame(height: 80)
                    }
                    .frame(height: 100)
                    
                    Spacer()
                }
                
                // X-axis labels like Apple
                    HStack {
                        Spacer()
                            .frame(width: 30)
                        
                            HStack(spacing: 0) {
                        if selectedTimePeriod == .last24Hours {
                            ForEach(["00", "06", "12", "18"], id: \.self) { time in
                                Text(time)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                            }
                        } else {
                                ForEach(["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"], id: \.self) { day in
                                    Text(day)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
            
            // Battery Summary
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Nivel Actual")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("85%")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tiempo Restante")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("6h 23m")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Settings Tab Content
    private var settingsTabContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Title
                Text("Ajustes")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)
                
                // Account Section
                VStack(spacing: 0) {
                    NavigationLink(destination: UserAccountView()) {
                        HStack(spacing: 12) {
                            if let profileImage = profileImage {
                                profileImage
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.blue)
                                    .frame(width: 60, height: 60)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("David Roman Lopez")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text("Cuenta Apple, iCloud y más")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity)
                .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Connectivity Section
                VStack(spacing: 0) {
                    NavigationLink(destination: BluetoothSettingsView().environmentObject(bluetoothManager)) {
                        HStack(spacing: 12) {
                            Image(systemName: "dot.radiowaves.left.and.right")
                                .font(.title2)
                                .foregroundColor(bluetoothManager.connectedDevice != nil ? .green : .orange)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Bluetooth")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Text(bluetoothManager.connectedDevice != nil ? "Conectado al parche" : "No conectado")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    Divider()
                        .padding(.leading, 50)
                    
                    NavigationLink(destination: ConnectionDetailsView().environmentObject(bluetoothManager)) {
                        HStack(spacing: 12) {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(.title2)
                                .foregroundColor(bluetoothManager.connectedDevice != nil ? .green : .red)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Conexión del Parche")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Text(bluetoothManager.connectedDevice != nil ? "Excelente (-45 dBm)" : "Sin conexión")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    Divider()
                        .padding(.leading, 50)
                    
                    NavigationLink(destination: LocationInfoView().environmentObject(bluetoothManager)) {
                        HStack(spacing: 12) {
                            Image(systemName: "location.fill")
                                .font(.title2)
                                .foregroundColor(bluetoothManager.connectedDevice != nil ? .green : .secondary)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Ubicación del Parche")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Text(bluetoothManager.connectedDevice != nil ? "Cerca del dispositivo" : "No disponible")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity)
                .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Device Settings Section
                VStack(spacing: 0) {
                    NavigationLink(destination: NotificationSettingsView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "bell")
                                .font(.title2)
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Notificaciones")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Text("Activadas")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    Divider()
                        .padding(.leading, 50)
                    
                    NavigationLink(destination: PrivacySettingsView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "shield")
                                .font(.title2)
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Privacidad y Seguridad")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Text("Configurado")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    Divider()
                        .padding(.leading, 50)
                    
                    NavigationLink(destination: AdvancedSettingsView().environmentObject(bluetoothManager)) {
                        HStack(spacing: 12) {
                            Image(systemName: "gear")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Configuración Avanzada")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Text("Personalizar parche")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity)
                .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // App Information Section
                VStack(spacing: 0) {
                    NavigationLink(destination: AppInfoView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Acerca de HealthPatch")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Text("Versión 2.0.1")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    Divider()
                        .padding(.leading, 50)
                    
                    NavigationLink(destination: HelpSupportView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "questionmark.circle")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Ayuda y Soporte")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Text("Documentación y contacto")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity)
                .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 24)
        }
        .background(colorScheme == .dark ? Color.black : Color(.secondarySystemBackground))
    }
    
    // MARK: - User Account Tab Content
    private var userAccountTabContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Account Section
                VStack(spacing: 0) {
                    // Profile Header
                    HStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .frame(width: 60, height: 60)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("David Roman Lopez")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("david@example.com")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    
                    Divider()
                        .padding(.leading, 72)
                    
                    // Apple ID
                    HStack(spacing: 12) {
                        Image(systemName: "applelogo")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .frame(width: 24)
                        
                        Text("Apple ID")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("david@example.com")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    Divider()
                        .padding(.leading, 50)
                    
                    // iCloud
                    HStack(spacing: 12) {
                        Image(systemName: "icloud")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("iCloud")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("david@example.com")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    Divider()
                        .padding(.leading, 50)
                    
                    // Media & Purchases
                    HStack(spacing: 12) {
                        Image(systemName: "music.note")
                            .font(.title2)
                            .foregroundColor(.red)
                            .frame(width: 24)
                        
                        Text("Media y Compras")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("david@example.com")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Family Sharing
                VStack(spacing: 0) {
                    NavigationLink(destination: FamilySharingView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.2")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Compartir en Familia")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Find My
                VStack(spacing: 0) {
                    NavigationLink(destination: FindMyView().environmentObject(bluetoothManager)) {
                        HStack(spacing: 12) {
                            Image(systemName: "location")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Buscar")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 24)
        }
        .background(Color(.secondarySystemBackground))
    }
    
    // MARK: - Bottom Tab Bar
    private var bottomTabBar: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "Inicio",
                icon: "house.fill",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }
            
            TabButton(          
                title: "Métricas",
                icon: "chart.bar.fill",
                isSelected: selectedTab == .metrics
            ) {
                selectedTab = .metrics
            }
            
            TabButton(
                title: "Ajustes",
                icon: "gear",
                isSelected: selectedTab == .settings
            ) {
                selectedTab = .settings
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(colorScheme == .dark ? Color(.systemGray6) : Color(.secondarySystemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .top
        )
    }
    
    private func TabButton(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .blue : .secondary)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper Methods
    private func setupMonitoring() {
        bluetoothManager.loadRegisteredDevice()
        loadProfileImage()
    }
    
    private func loadProfileImage() {
        if let savedImageData = UserDefaults.standard.data(forKey: "profileImageData"),
           let uiImage = UIImage(data: savedImageData) {
            profileImage = Image(uiImage: uiImage)
        } else {
            profileImage = nil
        }
    }
    
    private func updateProfileImage() {
        loadProfileImage()
    }
    
    private func disconnectDevice() {
        bluetoothManager.disconnect()
    }
    
    // MARK: - Device Name Edit View
    private var deviceNameEditView: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "airpods")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Cambiar Nombre del Dispositivo")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("El nuevo nombre se mostrará en todos los dispositivos conectados a tu cuenta")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Text Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nombre del Dispositivo")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    TextField("Nombre del dispositivo", text: $tempDeviceName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title3)
                        .padding()
                        .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button("Cambiar Nombre") {
                        if !tempDeviceName.isEmpty {
                            deviceName = tempDeviceName
                            isEditingDeviceName = false
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(tempDeviceName.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(12)
                    .disabled(tempDeviceName.isEmpty)
                    
                    Button("Cancelar") {
                        isEditingDeviceName = false
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("Editar Nombre")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        isEditingDeviceName = false
                    }
                }
            }
            .background(colorScheme == .dark ? Color.black : Color(.systemBackground))
            .onAppear {
                tempDeviceName = deviceName
            }
        }
    }
}

// MARK: - Dashed Line Shape for Apple-style charts
struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}

#Preview {
    MonitoringView()
        .environmentObject(BluetoothManager())
}


