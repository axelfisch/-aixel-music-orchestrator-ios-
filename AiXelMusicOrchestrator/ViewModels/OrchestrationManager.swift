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
            
            // Step 3: Orchestrate (70%)
            generationProgress = 0.7
            let orchestrationData = try await pythonBridge.orchestrate(voicingData)
            
            // Step 4: Create composition object (90%)
            generationProgress = 0.9
            let composition = try createComposition(from: orchestrationData, parameters: parameters)
            
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
    
    private func createComposition(from data: OrchestrationData, parameters: GenerationParameters) throws -> Composition {
        let measures = data.measures.enumerated().map { index, measureData in
            let chord = Chord(
                symbol: measureData.chordSymbol,
                notes: measureData.notes,
                voicing: Voicing(
                    flute: measureData.voicing.flute,
                    piano: measureData.voicing.piano,
                    violin1: measureData.voicing.violin1,
                    violin2: measureData.voicing.violin2,
                    viola1: measureData.voicing.viola1,
                    viola2: measureData.voicing.viola2,
                    cello: measureData.voicing.cello,
                    bass: measureData.voicing.bass
                )
            )
            
            return Measure(number: index + 1, chord: chord)
        }
        
        let sections = createSections(for: parameters.form)
        
        return Composition(
            title: generateTitle(key: parameters.key, style: parameters.style),
            key: parameters.key,
            form: parameters.form,
            style: parameters.style,
            tempo: parameters.tempo,
            measures: measures,
            sections: sections
        )
    }
    
    private func createSections(for form: String) -> [Section] {
        switch form {
        case "AABA":
            return [
                Section(name: "A1", startMeasure: 0, length: 8),
                Section(name: "A2", startMeasure: 8, length: 8),
                Section(name: "B", startMeasure: 16, length: 8),
                Section(name: "A3", startMeasure: 24, length: 8)
            ]
        case "ABAC":
            return [
                Section(name: "A1", startMeasure: 0, length: 8),
                Section(name: "B", startMeasure: 8, length: 8),
                Section(name: "A2", startMeasure: 16, length: 8),
                Section(name: "C", startMeasure: 24, length: 8)
            ]
        case "16 bars":
            return [
                Section(name: "A", startMeasure: 0, length: 8),
                Section(name: "B", startMeasure: 8, length: 8)
            ]
        case "32 bars":
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

