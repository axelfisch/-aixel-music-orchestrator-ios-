//
//  MusicalModels.swift
//  AiXelMusicOrchestrator
//
//  Created by Manus AI on 30/01/2025.
//

import Foundation

// MARK: - Core Musical Structures

struct Composition: Identifiable, Codable {
    let id = UUID()
    let title: String
    let key: String
    let form: String
    let style: String
    let tempo: Double
    let measures: [Measure]
    let sections: [Section]
    let createdAt: Date
    
    init(title: String = "Untitled", key: String, form: String, style: String, tempo: Double = 120, measures: [Measure], sections: [Section]) {
        self.title = title
        self.key = key
        self.form = form
        self.style = style
        self.tempo = tempo
        self.measures = measures
        self.sections = sections
        self.createdAt = Date()
    }
    
    static let sample = Composition(
        title: "Sample Jazz Waltz",
        key: "Eb",
        form: "AABA",
        style: "Jazz Pop",
        tempo: 120,
        measures: [
            Measure(number: 1, chord: Chord(symbol: "Ebadd9/G", notes: ["G2", "Bb3", "Eb4", "F4"])),
            Measure(number: 2, chord: Chord(symbol: "Bb/Ab", notes: ["Ab2", "D4", "F4", "Bb4"])),
            Measure(number: 3, chord: Chord(symbol: "C-add9", notes: ["C3", "Eb4", "G4", "D5"])),
            Measure(number: 4, chord: Chord(symbol: "Absus2", notes: ["Ab2", "Bb3", "Eb4", "Ab4"]))
        ],
        sections: [
            Section(name: "A1", startMeasure: 0, length: 8),
            Section(name: "A2", startMeasure: 8, length: 8),
            Section(name: "B", startMeasure: 16, length: 8),
            Section(name: "A3", startMeasure: 24, length: 8)
        ]
    )
}

struct Measure: Identifiable, Codable {
    let id = UUID()
    let number: Int
    let chord: Chord
    let duration: Double
    
    init(number: Int, chord: Chord, duration: Double = 4.0) {
        self.number = number
        self.chord = chord
        self.duration = duration
    }
}

struct Chord: Identifiable, Codable {
    let id = UUID()
    let symbol: String
    let notes: [String]
    let voicing: Voicing?
    
    init(symbol: String, notes: [String], voicing: Voicing? = nil) {
        self.symbol = symbol
        self.notes = notes
        self.voicing = voicing
    }
}

struct Voicing: Codable {
    let flute: String?
    let piano: String?
    let violin1: String?
    let violin2: String?
    let viola1: String?
    let viola2: String?
    let cello: String?
    let bass: String?
    
    init(flute: String? = nil, piano: String? = nil, violin1: String? = nil, violin2: String? = nil,
         viola1: String? = nil, viola2: String? = nil, cello: String? = nil, bass: String? = nil) {
        self.flute = flute
        self.piano = piano
        self.violin1 = violin1
        self.violin2 = violin2
        self.viola1 = viola1
        self.viola2 = viola2
        self.cello = cello
        self.bass = bass
    }
}

struct Section: Identifiable, Codable {
    let id = UUID()
    let name: String
    let startMeasure: Int
    let length: Int
    
    var endMeasure: Int {
        return startMeasure + length - 1
    }
}

// MARK: - Audio Models

struct InstrumentSettings: Identifiable, Codable {
    let id = UUID()
    let name: String
    let type: InstrumentType
    var volume: Double
    var reverb: Double
    var isMuted: Bool
    var isSoloed: Bool
    
    init(name: String, type: InstrumentType, volume: Double = 0.8, reverb: Double = 0.3, isMuted: Bool = false, isSoloed: Bool = false) {
        self.name = name
        self.type = type
        self.volume = volume
        self.reverb = reverb
        self.isMuted = isMuted
        self.isSoloed = isSoloed
    }
}

enum InstrumentType: String, Codable, CaseIterable {
    case flute = "flute"
    case piano = "piano"
    case violin1 = "violin1"
    case violin2 = "violin2"
    case viola1 = "viola1"
    case viola2 = "viola2"
    case cello = "cello"
    case bass = "bass"
    
    var displayName: String {
        switch self {
        case .flute: return "Flute"
        case .piano: return "Piano"
        case .violin1: return "Violin I"
        case .violin2: return "Violin II"
        case .viola1: return "Viola I"
        case .viola2: return "Viola II"
        case .cello: return "Cello"
        case .bass: return "Bass"
        }
    }
    
    var midiProgram: Int {
        switch self {
        case .flute: return 73
        case .piano: return 0
        case .violin1, .violin2: return 40
        case .viola1, .viola2: return 41
        case .cello: return 42
        case .bass: return 43
        }
    }
}

// MARK: - Generation Parameters

struct GenerationParameters: Codable {
    let key: String
    let form: String
    let style: String
    let tempo: Double
    let complexity: ComplexityLevel
    let voicingStyle: VoicingStyle
    
    init(key: String, form: String, style: String, tempo: Double = 120, 
         complexity: ComplexityLevel = .medium, voicingStyle: VoicingStyle = .axelFisch) {
        self.key = key
        self.form = form
        self.style = style
        self.tempo = tempo
        self.complexity = complexity
        self.voicingStyle = voicingStyle
    }
}

enum ComplexityLevel: String, Codable, CaseIterable {
    case simple = "Simple"
    case medium = "Medium"
    case complex = "Complex"
    case advanced = "Advanced"
}

enum VoicingStyle: String, Codable, CaseIterable {
    case axelFisch = "Axel Fisch"
    case traditional = "Traditional"
    case modern = "Modern"
    case minimal = "Minimal"
}

// MARK: - Playback Models

enum PlaybackSection: String, CaseIterable {
    case full = "Full"
    case A = "A Section"
    case B = "B Section"
}

struct PlaybackState: Codable {
    var isPlaying: Bool = false
    var currentPosition: Double = 0
    var totalDuration: Double = 0
    var currentMeasure: Int = 0
    var isLooping: Bool = false
    var selectedSection: PlaybackSection = .full
    var tempo: Double = 120
}

// MARK: - Export Models

enum ExportFormat: String, Codable, CaseIterable {
    case musicXML = "musicxml"
    case midi = "midi"
    case audio = "audio"
    case pdf = "pdf"
    
    var fileExtension: String {
        switch self {
        case .musicXML: return "musicxml"
        case .midi: return "mid"
        case .audio: return "wav"
        case .pdf: return "pdf"
        }
    }
    
    var mimeType: String {
        switch self {
        case .musicXML: return "application/vnd.recordare.musicxml+xml"
        case .midi: return "audio/midi"
        case .audio: return "audio/wav"
        case .pdf: return "application/pdf"
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let playbackPositionChanged = Notification.Name("playbackPositionChanged")
    static let compositionGenerated = Notification.Name("compositionGenerated")
    static let audioEngineStateChanged = Notification.Name("audioEngineStateChanged")
}

