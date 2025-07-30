//
//  SettingsView.swift
//  AiXelMusicOrchestrator
//
//  Created by Manus AI on 30/01/2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("audioQuality") private var audioQuality: AudioQuality = .high
    @AppStorage("defaultKey") private var defaultKey: String = "C"
    @AppStorage("defaultForm") private var defaultForm: String = "AABA"
    @AppStorage("enableHaptics") private var enableHaptics: Bool = true
    @AppStorage("enableCloudSync") private var enableCloudSync: Bool = false
    @State private var showingAbout = false
    
    enum AudioQuality: String, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case ultra = "Ultra"
        
        var description: String {
            switch self {
            case .low: return "Optimized for battery life"
            case .medium: return "Balanced quality and performance"
            case .high: return "High quality audio"
            case .ultra: return "Maximum quality (requires more processing)"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                // Audio Settings
                Section("Audio Settings") {
                    HStack {
                        Image(systemName: "speaker.wave.3")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Audio Quality")
                                .foregroundColor(.white)
                            Text(audioQuality.description)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Picker("Audio Quality", selection: $audioQuality) {
                            ForEach(AudioQuality.allCases, id: \.self) { quality in
                                Text(quality.rawValue).tag(quality)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    HStack {
                        Image(systemName: "waveform")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Enable Haptic Feedback")
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Toggle("", isOn: $enableHaptics)
                    }
                }
                
                // Composition Defaults
                Section("Composition Defaults") {
                    HStack {
                        Image(systemName: "music.note")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        Text("Default Key")
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Picker("Default Key", selection: $defaultKey) {
                            ForEach(["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"], id: \.self) { key in
                                Text(key).tag(key)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    HStack {
                        Image(systemName: "music.note.list")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        Text("Default Form")
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Picker("Default Form", selection: $defaultForm) {
                            ForEach(["AABA", "ABAC", "16 bars", "32 bars"], id: \.self) { form in
                                Text(form).tag(form)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // Data & Privacy
                Section("Data & Privacy") {
                    HStack {
                        Image(systemName: "icloud")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("iCloud Sync")
                                .foregroundColor(.white)
                            Text("Sync compositions across devices")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $enableCloudSync)
                    }
                    
                    Button(action: clearCache) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            Text("Clear Cache")
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
                
                // About
                Section("About") {
                    Button(action: { showingAbout = true }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("About AiXel Music Orchestrator")
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    
                    Button(action: openSupport) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Support & Feedback")
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "number")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        
                        Text("Version")
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .background(.black)
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
    
    private func clearCache() {
        // Implement cache clearing logic
        let alert = UIAlertController(
            title: "Clear Cache",
            message: "This will clear all cached audio and composition data. Continue?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            // Clear cache implementation
        })
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
    
    private func openSupport() {
        if let url = URL(string: "mailto:support@aixelmusic.com") {
            UIApplication.shared.open(url)
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // App Icon and Title
                VStack(spacing: 16) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("AiXel Music Orchestrator")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Description
                VStack(alignment: .leading, spacing: 16) {
                    Text("About")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("AiXel Music Orchestrator brings the sophisticated harmonic style of Axel Fisch to your fingertips. Create professional jazz-pop orchestrations with intelligent chord progressions, rich voicings, and beautiful orchestral arrangements.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                    
                    Text("Features:")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        FeatureRow(text: "Intelligent AABA composition generation")
                        FeatureRow(text: "8-voice orchestral arrangements")
                        FeatureRow(text: "Professional audio processing with AudioKit")
                        FeatureRow(text: "Export to MusicXML, MIDI, and audio formats")
                        FeatureRow(text: "Individual instrument mixing controls")
                        FeatureRow(text: "Axel Fisch harmonic style encoding")
                    }
                }
                
                Spacer()
                
                // Credits
                VStack(spacing: 8) {
                    Text("Created by Manus AI")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("Based on the musical style of Axel Fisch")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("© 2025 AiXel Music Technologies")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(.black)
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct FeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
                .padding(.top, 2)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    SettingsView()
}

