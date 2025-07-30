//
//  ContentView.swift
//  AiXelMusicOrchestrator
//
//  Created by Manus AI on 30/01/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var orchestrationManager: OrchestrationManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CompositionView()
                .tabItem {
                    Image(systemName: "music.note")
                    Text("Compose")
                }
                .tag(0)
            
            MixerView()
                .tabItem {
                    Image(systemName: "slider.horizontal.3")
                    Text("Mixer")
                }
                .tag(1)
            
            ExportView()
                .tabItem {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .environmentObject(AudioManager.shared)
        .environmentObject(OrchestrationManager())
}

