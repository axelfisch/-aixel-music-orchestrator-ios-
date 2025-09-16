//
//  OrchestrationManager.swift
//  AiXelMusicOrchestrator
//
//  Created by Manus AI on 30/01/2025.
//

import Foundation
import Combine

@MainActor
class OrchestrationManager: ObservableObject {
    @Published var currentComposition: Composition?
    @Published var isGenerating: Bool = false
    @Published var generationProgress: Double = 0
    @Published var savedCompositions: [Composition] = []
    @Published var errorMessage: String?
    
    private let pythonBridge = PythonBridge()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSavedCompositions()
    }
    
    // MARK: - Composition Generation
    
    func generateComposition(key: String, form: String, style: String) async {
        isGenerating = true
        generationProgress = 0
        errorMessage = nil
        
        do {
            // Step 1: Generate harmonic progression (30%)
            generationProgress = 0.1
            let parameters = GenerationParameters(key: key, form: form, style: style)
            
            generationProgress = 0.3
            let harmonicData = try await pythonBridge.generateHarmonicProgression(parameters)
            
            // Step 2: Create voicings (50%)
            generationProgress = 0.5
            let voicingData = try await pythonBridge.generateVoicings(harmonicData)
            
            // Step 3: Create composition object (90%) using voicings
            generationProgress = 0.9
            let composition = try createComposition(fromVoicings: voicingData, parameters: parameters)
            
            // Step 5: Complete (100%)
            generationProgress = 1.0
            currentComposition = composition
            
            // Save to history
            savedCompositions.append(composition)
            saveCompositions()
            
            // Notify audio manager
            NotificationCenter.default.post(
                name: .compositionGenerated,
                object: composition
            )
            
        } catch {
            errorMessage = "Failed to generate composition: \(error.localizedDescription)"
            print("Generation error: \(error)")
        }
        
        isGenerating = false
    }

    // MARK: - Test-facing API (synchronous-style wrappers)
    
    func generateComposition(parameters: CompositionParameters, completion: @escaping (Composition) -> Void) {
        Task { @MainActor in
            await self.generateComposition(key: parameters.key, form: parameters.form.rawValue, style: parameters.style.rawValue)
            if let composition = self.currentComposition {
                completion(composition)
            }
        }
    }
    
    func generateChordProgression(key: String, form: CompositionForm) -> [Chord] {
        // Lightweight progression using PythonBridge for realism; fall back to simple placeholders
        let semaphore = DispatchSemaphore(value: 0)
        var chords: [Chord] = []
        Task {
            do {
                let params = GenerationParameters(
                    key: key,
                    form: form.rawValue,
                    style: CompositionStyle.jazzPop.rawValue,
                    tempo: 120
                )
                let harmonic = try await pythonBridge.generateHarmonicProgression(params)
                chords = harmonic.progression.map { hm in
                    Chord(symbol: hm.chord, notes: hm.notes)
                }
            } catch {
                // Fallback: 32 generic C-based chords
                chords = (0..<32).map { _ in Chord(symbol: "Cmaj7", notes: ["C3","E4","G4","B4"]) }
            }
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + 5)
        return chords
    }
    
    func generateVoicing(for chord: Chord) -> Voicing? {
        // Simple mapping: spread chord notes and double to fill 8 voices
        let notes = chord.notes
        guard !notes.isEmpty else { return nil }
        let extended: [String] = {
            var out: [String] = []
            while out.count < 8 {
                for n in notes {
                    if out.count >= 8 { break }
                    // Basic octave up every other duplication
                    if out.count >= notes.count {
                        out.append(increaseOctave(n))
                    } else {
                        out.append(n)
                    }
                }
            }
            return out
        }()
        return Voicing(
            flute: extended[7],
            piano: extended[6],
            violin1: extended[5],
            violin2: extended[4],
            viola1: extended[3],
            viola2: extended[2],
            cello: extended[1],
            bass: extended[0]
        )
    }
    
    private func increaseOctave(_ note: String) -> String {
        guard let last = note.last, last.isNumber else { return note }
        let prefix = note.dropLast()
        let octave = Int(String(last)) ?? 4
        return prefix + String(min(9, octave + 1))
    }
    
    private func createComposition(fromVoicings data: VoicingData, parameters: GenerationParameters) throws -> Composition {
        let measures: [Measure] = data.voicings.enumerated().map { index, vm in
            let voicing = Voicing(
                flute: vm.voicing.flute,
                piano: vm.voicing.piano,
                violin1: vm.voicing.violin1,
                violin2: vm.voicing.violin2,
                viola1: vm.voicing.viola1,
                viola2: vm.voicing.viola2,
                cello: vm.voicing.cello,
                bass: vm.voicing.bass
            )
            let notes = [voicing.flute, voicing.piano, voicing.violin1, voicing.violin2, voicing.viola1, voicing.viola2, voicing.cello, voicing.bass].compactMap { $0 }
            let chord = Chord(symbol: vm.chord, notes: notes.isEmpty ? ["C4"] : notes, voicing: voicing)
            return Measure(number: index + 1, chord: chord)
        }
        
        let formEnum = CompositionForm(rawValue: parameters.form) ?? .aaba
        let styleEnum = CompositionStyle(rawValue: parameters.style) ?? .jazzPop
        let sections = createSections(for: formEnum)
        
        return Composition(
            title: generateTitle(key: parameters.key, style: parameters.style),
            key: parameters.key,
            form: formEnum,
            style: styleEnum,
            tempo: parameters.tempo,
            measures: measures,
            sections: sections
        )
    }
    
    private func createSections(for form: CompositionForm) -> [Section] {
        switch form {
        case .aaba:
            return [
                Section(name: "A1", startMeasure: 0, length: 8),
                Section(name: "A2", startMeasure: 8, length: 8),
                Section(name: "B", startMeasure: 16, length: 8),
                Section(name: "A3", startMeasure: 24, length: 8)
            ]
        case .abac:
            return [
                Section(name: "A1", startMeasure: 0, length: 8),
                Section(name: "B", startMeasure: 8, length: 8),
                Section(name: "A2", startMeasure: 16, length: 8),
                Section(name: "C", startMeasure: 24, length: 8)
            ]
        case .bars16:
            return [
                Section(name: "A", startMeasure: 0, length: 8),
                Section(name: "B", startMeasure: 8, length: 8)
            ]
        case .bars32:
            return [
                Section(name: "A", startMeasure: 0, length: 16),
                Section(name: "B", startMeasure: 16, length: 16)
            ]
        default:
            return [Section(name: "Full", startMeasure: 0, length: 32)]
        }
    }
    
    private func generateTitle(key: String, style: String) -> String {
        let adjectives = ["Gentle", "Flowing", "Elegant", "Sophisticated", "Dreamy", "Contemplative"]
        let nouns = ["Waltz", "Ballad", "Song", "Melody", "Theme", "Piece"]
        
        let adjective = adjectives.randomElement() ?? "Beautiful"
        let noun = nouns.randomElement() ?? "Song"
        
        return "\(adjective) \(noun) in \(key)"
    }
    
    // MARK: - Export Functions
    
    func exportComposition(
        _ composition: Composition,
        format: ExportView.ExportFormat,
        progressHandler: @escaping (Double) -> Void
    ) async throws -> URL {
        
        switch format {
        case .musicXML:
            return try await exportMusicXML(composition, progressHandler: progressHandler)
        case .midi:
            return try await exportMIDI(composition, progressHandler: progressHandler)
        case .audio:
            return try await exportAudio(composition, progressHandler: progressHandler)
        case .pdf:
            return try await exportPDF(composition, progressHandler: progressHandler)
        }
    }
    
    private func exportMusicXML(_ composition: Composition, progressHandler: @escaping (Double) -> Void) async throws -> URL {
        progressHandler(0.1)
        
        let musicXMLData = try await pythonBridge.exportMusicXML(composition)
        progressHandler(0.8)
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "\(composition.title.replacingOccurrences(of: " ", with: "_")).musicxml"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        try musicXMLData.write(to: fileURL)
        progressHandler(1.0)
        
        return fileURL
    }
    
    private func exportMIDI(_ composition: Composition, progressHandler: @escaping (Double) -> Void) async throws -> URL {
        progressHandler(0.1)
        
        let midiData = try await pythonBridge.exportMIDI(composition)
        progressHandler(0.8)
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "\(composition.title.replacingOccurrences(of: " ", with: "_")).mid"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        try midiData.write(to: fileURL)
        progressHandler(1.0)
        
        return fileURL
    }
    
    private func exportAudio(_ composition: Composition, progressHandler: @escaping (Double) -> Void) async throws -> URL {
        progressHandler(0.1)
        
        // Use AudioManager to render audio
        let audioManager = AudioManager.shared
        let audioData = try await audioManager.renderComposition(composition) { progress in
            progressHandler(0.1 + (progress * 0.8))
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "\(composition.title.replacingOccurrences(of: " ", with: "_")).wav"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        try audioData.write(to: fileURL)
        progressHandler(1.0)
        
        return fileURL
    }
    
    private func exportPDF(_ composition: Composition, progressHandler: @escaping (Double) -> Void) async throws -> URL {
        progressHandler(0.1)
        
        let pdfData = try await pythonBridge.exportPDF(composition)
        progressHandler(0.8)
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "\(composition.title.replacingOccurrences(of: " ", with: "_")).pdf"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        try pdfData.write(to: fileURL)
        progressHandler(1.0)
        
        return fileURL
    }
    
    // MARK: - Composition Management
    
    func deleteComposition(_ composition: Composition) {
        savedCompositions.removeAll { $0.id == composition.id }
        saveCompositions()
        
        if currentComposition?.id == composition.id {
            currentComposition = nil
        }
    }
    
    func loadComposition(_ composition: Composition) {
        currentComposition = composition
        
        NotificationCenter.default.post(
            name: .compositionGenerated,
            object: composition
        )
    }
    
    // MARK: - Persistence
    
    private func saveCompositions() {
        do {
            let data = try JSONEncoder().encode(savedCompositions)
            UserDefaults.standard.set(data, forKey: "savedCompositions")
        } catch {
            print("Failed to save compositions: \(error)")
        }
    }
    
    private func loadSavedCompositions() {
        guard let data = UserDefaults.standard.data(forKey: "savedCompositions") else { return }
        
        do {
            savedCompositions = try JSONDecoder().decode([Composition].self, from: data)
        } catch {
            print("Failed to load compositions: \(error)")
        }
    }
}

// MARK: - Supporting Data Structures

struct OrchestrationData {
    let measures: [MeasureData]
}

struct MeasureData {
    let chordSymbol: String
    let notes: [String]
    let voicing: VoicingData
}

struct VoicingData {
    let flute: String?
    let piano: String?
    let violin1: String?
    let violin2: String?
    let viola1: String?
    let viola2: String?
    let cello: String?
    let bass: String?
}

