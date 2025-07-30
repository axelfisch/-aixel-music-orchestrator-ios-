//
//  InstrumentEngine.swift
//  AiXelMusicOrchestrator
//
//  Created by Manus AI on 30/01/2025.
//

import Foundation
import AudioKit
import AVFoundation

class InstrumentEngine: ObservableObject {
    let instrumentType: InstrumentType
    
    // Audio chain components
    private var oscillator: Oscillator!
    private var sampler: AppleSampler!
    private var reverb: Reverb!
    private var mixer: Mixer!
    private var filter: LowPassFilter!
    
    // Playback state
    private var currentComposition: Composition?
    private var currentNotes: [MIDINote] = []
    private var playbackTimer: Timer?
    private var isPlaying: Bool = false
    private var currentPosition: Double = 0
    private var tempo: Double = 120
    
    // Audio parameters
    private var volume: Double = 0.8
    private var reverbMix: Double = 0.3
    private var isMuted: Bool = false
    
    var output: Node {
        return mixer
    }
    
    init(type: InstrumentType) {
        self.instrumentType = type
        setupAudioChain()
        loadInstrumentSamples()
    }
    
    // MARK: - Audio Chain Setup
    
    private func setupAudioChain() {
        // Create oscillator for synthesis
        oscillator = Oscillator()
        
        // Create sampler for realistic instrument sounds
        sampler = AppleSampler()
        
        // Create filter for tone shaping
        filter = LowPassFilter(sampler)
        filter.cutoffFrequency = getFilterCutoff(for: instrumentType)
        filter.resonance = 0.5
        
        // Create reverb
        reverb = Reverb(filter)
        reverb.dryWetMix = AUValue(reverbMix)
        
        // Create mixer to combine sources
        mixer = Mixer()
        mixer.addInput(reverb)
        mixer.volume = AUValue(volume)
        
        // Configure oscillator
        configureOscillator()
    }
    
    private func configureOscillator() {
        switch instrumentType {
        case .flute:
            oscillator.waveform = Table(.sine)
            oscillator.amplitude = 0.3
        case .piano:
            oscillator.waveform = Table(.sawtooth)
            oscillator.amplitude = 0.4
        case .violin1, .violin2:
            oscillator.waveform = Table(.sawtooth)
            oscillator.amplitude = 0.35
        case .viola1, .viola2:
            oscillator.waveform = Table(.sawtooth)
            oscillator.amplitude = 0.4
        case .cello:
            oscillator.waveform = Table(.sawtooth)
            oscillator.amplitude = 0.45
        case .bass:
            oscillator.waveform = Table(.square)
            oscillator.amplitude = 0.5
        }
    }
    
    private func getFilterCutoff(for type: InstrumentType) -> AUValue {
        switch type {
        case .flute: return 4000
        case .piano: return 8000
        case .violin1, .violin2: return 6000
        case .viola1, .viola2: return 4000
        case .cello: return 2000
        case .bass: return 1000
        }
    }
    
    private func loadInstrumentSamples() {
        // Load appropriate samples for each instrument
        Task {
            do {
                let sampleURL = try await getSampleURL(for: instrumentType)
                try await sampler.loadAudioFile(sampleURL)
            } catch {
                print("Failed to load samples for \(instrumentType): \(error)")
                // Fall back to oscillator
            }
        }
    }
    
    private func getSampleURL(for type: InstrumentType) async throws -> URL {
        // In a real implementation, this would load actual instrument samples
        // For now, we'll use the built-in samples or generate synthetic ones
        
        guard let bundlePath = Bundle.main.path(forResource: "Samples", ofType: nil),
              let samplePath = Bundle.main.path(forResource: type.rawValue, ofType: "wav", inDirectory: bundlePath) else {
            throw AudioEngineError.sampleNotFound
        }
        
        return URL(fileURLWithPath: samplePath)
    }
    
    // MARK: - Composition Loading
    
    func loadComposition(_ composition: Composition, instrumentIndex: Int) async {
        currentComposition = composition
        currentNotes = []
        
        // Extract notes for this instrument from the composition
        for (measureIndex, measure) in composition.measures.enumerated() {
            if let note = extractNoteForInstrument(from: measure, instrumentIndex: instrumentIndex) {
                let timing = calculateNoteTiming(measureIndex: measureIndex, composition: composition)
                let midiNote = MIDINote(
                    note: note,
                    startTime: timing.start,
                    duration: timing.duration,
                    velocity: getVelocityForInstrument()
                )
                currentNotes.append(midiNote)
            }
        }
    }
    
    private func extractNoteForInstrument(from measure: Measure, instrumentIndex: Int) -> String? {
        guard let voicing = measure.chord.voicing else {
            // If no specific voicing, distribute chord notes across instruments
            let noteIndex = instrumentIndex % measure.chord.notes.count
            return measure.chord.notes[noteIndex]
        }
        
        // Extract specific note for this instrument from voicing
        switch instrumentIndex {
        case 0: return voicing.flute
        case 1: return voicing.piano
        case 2: return voicing.violin1
        case 3: return voicing.violin2
        case 4: return voicing.viola1
        case 5: return voicing.viola2
        case 6: return voicing.cello
        case 7: return voicing.bass
        default: return nil
        }
    }
    
    private func calculateNoteTiming(measureIndex: Int, composition: Composition) -> (start: Double, duration: Double) {
        let beatsPerMeasure = 4.0
        let beatsPerSecond = composition.tempo / 60.0
        let measureDuration = beatsPerMeasure / beatsPerSecond
        
        let startTime = Double(measureIndex) * measureDuration
        let duration = measureDuration // Full measure duration
        
        return (startTime, duration)
    }
    
    private func getVelocityForInstrument() -> UInt8 {
        switch instrumentType {
        case .flute: return 80
        case .piano: return 90
        case .violin1, .violin2: return 85
        case .viola1, .viola2: return 80
        case .cello: return 85
        case .bass: return 95
        }
    }
    
    // MARK: - Playback Control
    
    func play(from position: Double = 0) {
        guard !currentNotes.isEmpty else { return }
        
        isPlaying = true
        currentPosition = position
        
        // Start playback timer
        startPlaybackTimer()
        
        // Start oscillator if using synthesis
        oscillator.start()
    }
    
    func pause() {
        isPlaying = false
        stopPlaybackTimer()
        stopAllNotes()
    }
    
    func stop() {
        isPlaying = false
        currentPosition = 0
        stopPlaybackTimer()
        stopAllNotes()
        oscillator.stop()
    }
    
    private func startPlaybackTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.updatePlayback()
        }
    }
    
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    private func updatePlayback() {
        guard isPlaying else { return }
        
        currentPosition += 0.01 * (tempo / 120.0)
        
        // Check for notes to play at current position
        for note in currentNotes {
            if note.startTime <= currentPosition && note.startTime + note.duration > currentPosition {
                if !note.isPlaying {
                    playNote(note)
                }
            } else if note.isPlaying && note.startTime + note.duration <= currentPosition {
                stopNote(note)
            }
        }
    }
    
    private func playNote(_ note: MIDINote) {
        guard !isMuted else { return }
        
        let midiNoteNumber = getMIDINoteNumber(from: note.note)
        let frequency = midiNoteToFrequency(midiNoteNumber)
        
        // Play on sampler if available, otherwise use oscillator
        if sampler.isLoaded {
            sampler.play(noteNumber: midiNoteNumber, velocity: note.velocity)
        } else {
            oscillator.frequency = frequency
            if !oscillator.isStarted {
                oscillator.start()
            }
        }
        
        note.isPlaying = true
    }
    
    private func stopNote(_ note: MIDINote) {
        let midiNoteNumber = getMIDINoteNumber(from: note.note)
        
        if sampler.isLoaded {
            sampler.stop(noteNumber: midiNoteNumber)
        }
        
        note.isPlaying = false
    }
    
    private func stopAllNotes() {
        for note in currentNotes {
            if note.isPlaying {
                stopNote(note)
            }
        }
    }
    
    // MARK: - Audio Parameter Control
    
    func setVolume(_ newVolume: Double) {
        volume = newVolume
        mixer.volume = AUValue(isMuted ? 0 : volume)
    }
    
    func setReverb(_ newReverbMix: Double) {
        reverbMix = newReverbMix
        reverb.dryWetMix = AUValue(reverbMix)
    }
    
    func setMuted(_ muted: Bool) {
        isMuted = muted
        mixer.volume = AUValue(muted ? 0 : volume)
    }
    
    func setTempo(_ newTempo: Double) {
        tempo = newTempo
    }
    
    // MARK: - Utility Functions
    
    private func getMIDINoteNumber(from noteName: String) -> UInt8 {
        // Parse note name (e.g., "C4", "F#3", "Bb2") to MIDI note number
        let noteMap: [String: Int] = [
            "C": 0, "C#": 1, "Db": 1,
            "D": 2, "D#": 3, "Eb": 3,
            "E": 4,
            "F": 5, "F#": 6, "Gb": 6,
            "G": 7, "G#": 8, "Ab": 8,
            "A": 9, "A#": 10, "Bb": 10,
            "B": 11
        ]
        
        // Extract note name and octave
        let cleanNote = noteName.replacingOccurrences(of: "-", with: "")
        let noteRegex = try! NSRegularExpression(pattern: "([A-G][#b]?)([0-9])")
        let matches = noteRegex.matches(in: cleanNote, range: NSRange(cleanNote.startIndex..., in: cleanNote))
        
        guard let match = matches.first,
              let noteRange = Range(match.range(at: 1), in: cleanNote),
              let octaveRange = Range(match.range(at: 2), in: cleanNote) else {
            return 60 // Default to middle C
        }
        
        let noteString = String(cleanNote[noteRange])
        let octaveString = String(cleanNote[octaveRange])
        
        guard let noteValue = noteMap[noteString],
              let octave = Int(octaveString) else {
            return 60
        }
        
        return UInt8(noteValue + (octave + 1) * 12)
    }
    
    private func midiNoteToFrequency(_ midiNote: UInt8) -> AUValue {
        return AUValue(440.0 * pow(2.0, (Double(midiNote) - 69.0) / 12.0))
    }
}

// MARK: - Supporting Classes

class MIDINote {
    let note: String
    let startTime: Double
    let duration: Double
    let velocity: UInt8
    var isPlaying: Bool = false
    
    init(note: String, startTime: Double, duration: Double, velocity: UInt8) {
        self.note = note
        self.startTime = startTime
        self.duration = duration
        self.velocity = velocity
    }
}

enum AudioEngineError: Error {
    case sampleNotFound
    case invalidNote
    case engineNotReady
}

