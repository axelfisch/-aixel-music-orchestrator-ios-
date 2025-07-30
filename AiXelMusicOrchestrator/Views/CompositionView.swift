//
//  CompositionView.swift
//  AiXelMusicOrchestrator
//
//  Created by Manus AI on 30/01/2025.
//

import SwiftUI

struct CompositionView: View {
    @EnvironmentObject var orchestrationManager: OrchestrationManager
    @EnvironmentObject var audioManager: AudioManager
    
    @State private var selectedKey = "C"
    @State private var selectedForm = "AABA"
    @State private var selectedStyle = "Jazz Pop"
    @State private var isGenerating = false
    
    let keys = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
    let forms = ["AABA", "ABAC", "16 bars", "32 bars"]
    let styles = ["Jazz Pop", "Bossa Nova", "ECM Style", "Rubato"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Text("AiXel Music Orchestrator")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Create sophisticated jazz-pop orchestrations in the style of Axel Fisch")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)
                
                // Composition Parameters
                VStack(spacing: 16) {
                    ParameterSelector(
                        title: "Key",
                        selection: $selectedKey,
                        options: keys
                    )
                    
                    ParameterSelector(
                        title: "Form",
                        selection: $selectedForm,
                        options: forms
                    )
                    
                    ParameterSelector(
                        title: "Style",
                        selection: $selectedStyle,
                        options: styles
                    )
                }
                .padding(.horizontal)
                
                // Generate Button
                Button(action: generateComposition) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "music.note.list")
                        }
                        
                        Text(isGenerating ? "Generating..." : "Generate Composition")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(isGenerating)
                .padding(.horizontal)
                
                // Current Composition Display
                if let composition = orchestrationManager.currentComposition {
                    ChordProgressionView(composition: composition)
                        .padding(.horizontal)
                }
                
                // Playback Controls
                if orchestrationManager.currentComposition != nil {
                    PlaybackControlsView()
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.black, .gray.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationBarHidden(true)
        }
    }
    
    private func generateComposition() {
        isGenerating = true
        
        Task {
            await orchestrationManager.generateComposition(
                key: selectedKey,
                form: selectedForm,
                style: selectedStyle
            )
            
            await MainActor.run {
                isGenerating = false
            }
        }
    }
}

struct ParameterSelector: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selection = option
                        }) {
                            Text(option)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selection == option ? .black : .white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(selection == option ? .white : .gray.opacity(0.3))
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    CompositionView()
        .environmentObject(OrchestrationManager())
        .environmentObject(AudioManager.shared)
}

