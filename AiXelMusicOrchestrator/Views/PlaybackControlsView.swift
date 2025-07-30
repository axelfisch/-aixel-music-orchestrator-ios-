//
//  PlaybackControlsView.swift
//  AiXelMusicOrchestrator
//
//  Created by Manus AI on 30/01/2025.
//

import SwiftUI

struct PlaybackControlsView: View {
    @EnvironmentObject var audioManager: AudioManager
    @State private var tempo: Double = 120
    @State private var isLooping: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Transport Controls
            HStack(spacing: 24) {
                // Stop Button
                Button(action: {
                    audioManager.stop()
                }) {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.gray.opacity(0.3))
                        )
                }
                
                // Play/Pause Button
                Button(action: {
                    if audioManager.isPlaying {
                        audioManager.pause()
                    } else {
                        audioManager.play()
                    }
                }) {
                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                // Loop Button
                Button(action: {
                    isLooping.toggle()
                    audioManager.setLooping(isLooping)
                }) {
                    Image(systemName: "repeat")
                        .font(.title2)
                        .foregroundColor(isLooping ? .blue : .white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(isLooping ? .white.opacity(0.2) : .gray.opacity(0.3))
                        )
                }
            }
            
            // Progress Bar
            if audioManager.isPlaying || audioManager.currentPosition > 0 {
                VStack(spacing: 8) {
                    HStack {
                        Text(formatTime(audioManager.currentPosition))
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text(formatTime(audioManager.totalDuration))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    ProgressView(value: audioManager.currentPosition, total: audioManager.totalDuration)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(y: 2)
                }
            }
            
            // Tempo Control
            VStack(spacing: 8) {
                Text("Tempo: \(Int(tempo)) BPM")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Slider(value: $tempo, in: 60...200, step: 1)
                    .accentColor(.blue)
                    .onChange(of: tempo) { newValue in
                        audioManager.setTempo(newValue)
                    }
            }
            
            // Section Controls
            HStack(spacing: 16) {
                Button("Play A Section") {
                    audioManager.playSection(.A)
                }
                .buttonStyle(SectionButtonStyle())
                
                Button("Play B Section") {
                    audioManager.playSection(.B)
                }
                .buttonStyle(SectionButtonStyle())
                
                Button("Play Full") {
                    audioManager.playSection(.full)
                }
                .buttonStyle(SectionButtonStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.gray.opacity(0.2))
        )
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

struct SectionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.blue.opacity(configuration.isPressed ? 0.8 : 0.6))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    PlaybackControlsView()
        .environmentObject(AudioManager.shared)
        .background(.black)
}

