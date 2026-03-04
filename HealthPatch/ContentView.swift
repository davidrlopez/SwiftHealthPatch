//
//  ContentView.swift
//  HealthPatch
//
//  Created by David Roman Lopez on 8/6/25.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @EnvironmentObject private var bluetoothManager: BluetoothManager
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var showingSettings = false

    var body: some View {
        // ContentView ahora es solo un wrapper simple
        // La funcionalidad principal está en AppFlowView
        VStack {
            Text("HealthPatch")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Esta vista ha sido simplificada")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("La funcionalidad principal está en AppFlowView")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    ContentView()
        .environmentObject(BluetoothManager())
        .environmentObject(AuthenticationManager())
}


