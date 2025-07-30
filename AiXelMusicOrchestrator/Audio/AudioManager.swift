//
//  AudioManager.swift
//  AiXelMusicOrchestrator
//
//  Created by Manus AI on 30/01/2025.
//

import Foundation
import AudioKit
import AVFoundation
import Combine

@MainActor
class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    // MARK: - Published Properties
    @Published var isPlaying: Bool = false
    @Published var currentPosition: Double = 0
    @Published var totalDuration: Double = 0
    @Published var currentMeasure: Int = 0
    @Published var instrumentVolumes: [Double] = Array(repeating: 0.8, count: 8)
    @Published var instrumentReverbs: [Double] = Array(repeating: 0.3, count: 8)
    @Published var instrumentMutes: [Bool] = Array(repeating: false, count: 8)
    @Published var instrumentSolos: [Bool] = Array(repeating: false, count: 8)
    @Published var masterVolume: Double = 0.8
    @Published var masterReverb: Double = 0.3
    @Published var tempo: Double = 120
    @Published var isLooping: Bool = false
    
    // MARK: - Private Properties
    private var audioEngine: AudioEngine!
    private var instrumentEngines: [InstrumentEngine] = []
    private var masterMixer: Mixer!
    private var masterReverb: Reverb!
    private var currentComposition: Composition?
    private var playbackTimer: Timer?
    private var startTime: Date?
    private var selectedSection: PlaybackSection = .full
    
    private init() {
        setupAudioEngine()
    }
    
    // MARK: - Audio Engine Setup
    
    func setup() {
        do {
            try audioEngine.start()
            NotificationCenter.default.post(name: .audioEngineStateChanged, object: true)
        } catch {
            print("Failed to start audio engine: \(error)")
            NotificationCenter.default.post(name: .audioEngineStateChanged, object: false)
        }
    }
    
    private func setupAudioEngine() {
        audioEngine = AudioEngine()
        
        // Create instrument engines
        instrumentEngines = InstrumentType.allCases.map { type in
            InstrumentEngine(type: type)
        }
        
        // Create master mixer
        masterMixer = Mixer()
        
        // Connect instrument engines to master mixer
        for engine in instrumentEngines {
            masterMixer.addInput(engine.output)
        }
        
        // Create master reverb
        masterReverb = Reverb(masterMixer)
        masterReverb.dryWetMix = AUValue(masterReverb)
        
        // Set audio engine output
        audioEngine.output = masterReverb
        
        // Setup notifications
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .compositionGenerated,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let composition = notification.object as? Composition {
                Task {
                    await self?.loadComposition(composition)
                }
            }
        }
    }
    
    // MARK: - Composition Loading
    
    func loadComposition(_ composition: Composition) async {
        currentComposition = composition
        totalDuration = calculateDuration(composition)
        
        // Prepare audio for each instrument
        for (index, engine) in instrumentEngines.enumerated() {
            await engine.loadComposition(composition, instrumentIndex: index)
        }
    }
    
    private func calculateDuration(_ composition: Composition) -> Double {
        let beatsPerMeasure = 4.0 // Assuming 4/4 time
        let totalBeats = Double(composition.measures.count) * beatsPerMeasure
        let beatsPerSecond = composition.tempo / 60.0
        return totalBeats / beatsPerSecond
    }
    
    // MARK: - Playback Control
    
    func play() {
        guard let composition = currentComposition else { return }
        
        isPlaying = true
        startTime = Date()
        
        // Start all instrument engines
        for engine in instrumentEngines {
            engine.play(from: currentPosition)
        }
        
        // Start playback timer
        startPlaybackTimer()
    }
    
    func pause() {
        isPlaying = false
        
        // Pause all instrument engines
        for engine in instrumentEngines {
            engine.pause()
        }
        
        stopPlaybackTimer()
    }
    
    func stop() {
        isPlaying = false
        currentPosition = 0
        currentMeasure = 0
        
        // Stop all instrument engines
        for engine in instrumentEngines {
            engine.stop()
        }
        
        stopPlaybackTimer()
        
        NotificationCenter.default.post(
            name: .playbackPositionChanged,
            object: currentMeasure
        )
    }
    
    func playSection(_ section: PlaybackSection) {
        selectedSection = section
        
        guard let composition = currentComposition else { return }
        
        let (startMeasure, endMeasure) = getSectionBounds(section, composition: composition)
        
        // Calculate start position in seconds
        let beatsPerMeasure = 4.0
        let beatsPerSecond = tempo / 60.0
        currentPosition = Double(startMeasure) * beatsPerMeasure / beatsPerSecond
        
        play()
    }
    
    private func getSectionBounds(_ section: PlaybackSection, composition: Composition) -> (Int, Int) {
        switch section {
        case .full:
            return (0, composition.measures.count - 1)
        case .A:
            // Find first A section
            if let aSection = composition.sections.first(where: { $0.name.contains("A") }) {
                return (aSection.startMeasure, aSection.endMeasure)
            }
            return (0, 7)
        case .B:
            // Find B section
            if let bSection = composition.sections.first(where: { $0.name.contains("B") }) {
                return (bSection.startMeasure, bSection.endMeasure)
            }
            return (16, 23)
        }
    }
    
    // MARK: - Playback Timer
    
    private func startPlaybackTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task {
                await self?.updatePlaybackPosition()
            }
        }
    }
    
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    private func updatePlaybackPosition() {
        guard let startTime = startTime, isPlaying else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        currentPosition += elapsed * (tempo / 120.0) // Adjust for tempo changes
        self.startTime = Date()
        
        // Calculate current measure
        let beatsPerMeasure = 4.0
        let beatsPerSecond = tempo / 60.0
        let currentBeat = currentPosition * beatsPerSecond
        let newMeasure = Int(currentBeat / beatsPerMeasure)
        
        if newMeasure != currentMeasure {
            currentMeasure = newMeasure
            NotificationCenter.default.post(
                name: .playbackPositionChanged,
                object: currentMeasure
            )
        }
        
        // Check for end of composition or section
        if currentPosition >= totalDuration {
            if isLooping {
                currentPosition = 0
                currentMeasure = 0
                // Continue playing
            } else {
                stop()
            }
        }
    }
    
    // MARK: - Audio Controls
    
    func setInstrumentVolume(_ index: Int, _ volume: Double) {
        guard index < instrumentEngines.count else { return }
        instrumentVolumes[index] = volume
        instrumentEngines[index].setVolume(volume)
    }
    
    func setInstrumentReverb(_ index: Int, _ reverb: Double) {
        guard index < instrumentEngines.count else { return }
        instrumentReverbs[index] = reverb
        instrumentEngines[index].setReverb(reverb)
    }
    
    func setInstrumentMute(_ index: Int, _ isMuted: Bool) {
        guard index < instrumentEngines.count else { return }
        instrumentMutes[index] = isMuted
        instrumentEngines[index].setMuted(isMuted)
    }
    
    func setInstrumentSolo(_ index: Int, _ isSoloed: Bool) {
        guard index < instrumentEngines.count else { return }
        instrumentSolos[index] = isSoloed
        
        // Handle solo logic - mute all others if any are soloed
        let hasSolos = instrumentSolos.contains(true)
        
        for (i, engine) in instrumentEngines.enumerated() {
            if hasSolos {
                engine.setMuted(!instrumentSolos[i])
            } else {
                engine.setMuted(instrumentMutes[i])
            }
        }
    }
    
    func setMasterVolume(_ volume: Double) {
        masterVolume = volume
        masterMixer.volume = AUValue(volume)
    }
    
    func setMasterReverb(_ reverb: Double) {
        masterReverb = reverb
        masterReverb.dryWetMix = AUValue(reverb)
    }
    
    func setTempo(_ newTempo: Double) {
        tempo = newTempo
        
        // Update all instrument engines with new tempo
        for engine in instrumentEngines {
            engine.setTempo(newTempo)
        }
        
        // Recalculate total duration if composition is loaded
        if let composition = currentComposition {
            totalDuration = calculateDuration(composition)
        }
    }
    
    func setLooping(_ looping: Bool) {
        isLooping = looping
    }
    
    // MARK: - Audio Rendering
    
    func renderComposition(_ composition: Composition, progressHandler: @escaping (Double) -> Void) async throws -> Data {
        // This would implement offline audio rendering
        // For now, return empty data as placeholder
        progressHandler(1.0)
        return Data()
    }
    
    // MARK: - Cleanup
    
    deinit {
        audioEngine.stop()
        stopPlaybackTimer()
        NotificationCenter.default.removeObserver(self)
    }
}

