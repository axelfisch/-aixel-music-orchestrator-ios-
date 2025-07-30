//
//  AiXelMusicOrchestratorApp.swift
//  AiXelMusicOrchestrator
//
//  Created by Manus AI on 30/01/2025.
//

import SwiftUI
import AudioKit

@main
struct AiXelMusicOrchestratorApp: App {
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var orchestrationManager = OrchestrationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioManager)
                .environmentObject(orchestrationManager)
                .onAppear {
                    setupAudio()
                }
                .onDisappear {
                    audioManager.stop()
                }
        }
    }
    
    private func setupAudio() {
        audioManager.setup()
    }
}

