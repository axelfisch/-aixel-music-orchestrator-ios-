//
//  MixerView.swift
//  AiXelMusicOrchestrator
//
//  Created by Manus AI on 30/01/2025.
//

import SwiftUI

struct MixerView: View {
    @EnvironmentObject var audioManager: AudioManager
    @State private var masterVolume: Double = 0.8
    @State private var masterReverb: Double = 0.3
    
    let instruments = [
        InstrumentInfo(name: "Flute", icon: "wind.snow", color: .cyan),
        InstrumentInfo(name: "Piano", icon: "pianokeys", color: .white),
        InstrumentInfo(name: "Violin I", icon: "music.note", color: .orange),
        InstrumentInfo(name: "Violin II", icon: "music.note", color: .yellow),
        InstrumentInfo(name: "Viola I", icon: "music.note", color: .green),
        InstrumentInfo(name: "Viola II", icon: "music.note", color: .mint),
        InstrumentInfo(name: "Cello", icon: "music.note", color: .purple),
        InstrumentInfo(name: "Bass", icon: "music.note", color: .red)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack {
                    Text("Orchestra Mixer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Control individual instrument levels and effects")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top)
                .padding(.bottom, 20)
                
                // Master Controls
                MasterControlsView(
                    masterVolume: $masterVolume,
                    masterReverb: $masterReverb
                )
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                // Individual Instrument Controls
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(Array(instruments.enumerated()), id: \.offset) { index, instrument in
                            InstrumentControlView(
                                instrument: instrument,
                                volume: Binding(
                                    get: { audioManager.instrumentVolumes[index] },
                                    set: { audioManager.setInstrumentVolume(index, $0) }
                                ),
                                reverb: Binding(
                                    get: { audioManager.instrumentReverbs[index] },
                                    set: { audioManager.setInstrumentReverb(index, $0) }
                                ),
                                isMuted: Binding(
                                    get: { audioManager.instrumentMutes[index] },
                                    set: { audioManager.setInstrumentMute(index, $0) }
                                ),
                                isSoloed: Binding(
                                    get: { audioManager.instrumentSolos[index] },
                                    set: { audioManager.setInstrumentSolo(index, $0) }
                                )
                            )
                        }
                    }
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
        .onChange(of: masterVolume) { newValue in
            audioManager.setMasterVolume(newValue)
        }
        .onChange(of: masterReverb) { newValue in
            audioManager.setMasterReverb(newValue)
        }
    }
}

struct MasterControlsView: View {
    @Binding var masterVolume: Double
    @Binding var masterReverb: Double
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Master Controls")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                VStack {
                    Text("Master Volume")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    CustomSlider(
                        value: $masterVolume,
                        range: 0...1,
                        color: .blue
                    )
                    .frame(height: 100)
                    
                    Text("\(Int(masterVolume * 100))%")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                VStack {
                    Text("Master Reverb")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    CustomSlider(
                        value: $masterReverb,
                        range: 0...1,
                        color: .purple
                    )
                    .frame(height: 100)
                    
                    Text("\(Int(masterReverb * 100))%")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.gray.opacity(0.2))
        )
    }
}

struct InstrumentControlView: View {
    let instrument: InstrumentInfo
    @Binding var volume: Double
    @Binding var reverb: Double
    @Binding var isMuted: Bool
    @Binding var isSoloed: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Instrument Header
            HStack {
                Image(systemName: instrument.icon)
                    .foregroundColor(instrument.color)
                    .font(.title2)
                
                Text(instrument.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
            }
            
            // Volume Control
            VStack(spacing: 4) {
                Text("Volume")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                CustomSlider(
                    value: $volume,
                    range: 0...1,
                    color: instrument.color
                )
                .frame(height: 60)
                
                Text("\(Int(volume * 100))%")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
            
            // Reverb Control
            VStack(spacing: 4) {
                Text("Reverb")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                CustomSlider(
                    value: $reverb,
                    range: 0...1,
                    color: .purple
                )
                .frame(height: 60)
                
                Text("\(Int(reverb * 100))%")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
            
            // Mute/Solo Buttons
            HStack(spacing: 8) {
                Button(action: { isMuted.toggle() }) {
                    Text("M")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(isMuted ? .black : .white)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(isMuted ? .red : .gray.opacity(0.3))
                        )
                }
                
                Button(action: { isSoloed.toggle() }) {
                    Text("S")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(isSoloed ? .black : .white)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(isSoloed ? .yellow : .gray.opacity(0.3))
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.gray.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(instrument.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                ZStack(alignment: .bottom) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.gray.opacity(0.3))
                        .frame(width: 8)
                    
                    // Fill track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: 8, height: geometry.size.height * CGFloat(value))
                }
                .frame(maxHeight: .infinity)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            let newValue = 1.0 - Double(gesture.location.y / geometry.size.height)
                            value = max(range.lowerBound, min(range.upperBound, newValue))
                        }
                )
            }
        }
    }
}

struct InstrumentInfo {
    let name: String
    let icon: String
    let color: Color
}

#Preview {
    MixerView()
        .environmentObject(AudioManager.shared)
}

