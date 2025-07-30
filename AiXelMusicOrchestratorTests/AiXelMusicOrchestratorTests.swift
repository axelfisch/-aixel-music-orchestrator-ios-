//
//  AiXelMusicOrchestratorTests.swift
//  AiXelMusicOrchestratorTests
//
//  Created by Manus AI on 30/01/2025.
//

import XCTest
@testable import AiXelMusicOrchestrator

final class AiXelMusicOrchestratorTests: XCTestCase {
    
    var orchestrationManager: OrchestrationManager!
    var audioManager: AudioManager!
    
    override func setUpWithError() throws {
        orchestrationManager = OrchestrationManager()
        audioManager = AudioManager()
    }
    
    override func tearDownWithError() throws {
        orchestrationManager = nil
        audioManager = nil
    }
    
    // MARK: - Composition Generation Tests
    
    func testCompositionGeneration() throws {
        // Given
        let parameters = CompositionParameters(
            key: "C",
            form: .aaba,
            style: .jazzPop,
            tempo: 120
        )
        
        // When
        let expectation = self.expectation(description: "Composition generated")
        var generatedComposition: Composition?
        
        orchestrationManager.generateComposition(parameters: parameters) { composition in
            generatedComposition = composition
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10.0)
        
        // Then
        XCTAssertNotNil(generatedComposition)
        XCTAssertEqual(generatedComposition?.key, "C")
        XCTAssertEqual(generatedComposition?.form, .aaba)
        XCTAssertGreaterThan(generatedComposition?.measures.count ?? 0, 0)
    }
    
    func testChordProgressionGeneration() throws {
        // Given
        let key = "Eb"
        let form = CompositionForm.aaba
        
        // When
        let chordProgression = orchestrationManager.generateChordProgression(key: key, form: form)
        
        // Then
        XCTAssertFalse(chordProgression.isEmpty)
        XCTAssertEqual(chordProgression.count, 32) // AABA form should have 32 measures
        
        // Verify chord quality
        for chord in chordProgression {
            XCTAssertFalse(chord.symbol.isEmpty)
            XCTAssertFalse(chord.notes.isEmpty)
        }
    }
    
    func testVoicingGeneration() throws {
        // Given
        let chord = Chord(symbol: "Cmaj7", notes: ["C", "E", "G", "B"])
        
        // When
        let voicing = orchestrationManager.generateVoicing(for: chord)
        
        // Then
        XCTAssertNotNil(voicing)
        XCTAssertNotNil(voicing?.flute)
        XCTAssertNotNil(voicing?.piano)
        XCTAssertNotNil(voicing?.violin1)
        XCTAssertNotNil(voicing?.violin2)
        XCTAssertNotNil(voicing?.viola1)
        XCTAssertNotNil(voicing?.viola2)
        XCTAssertNotNil(voicing?.cello)
        XCTAssertNotNil(voicing?.bass)
    }
    
    // MARK: - Audio Engine Tests
    
    func testAudioManagerInitialization() throws {
        // When
        let result = audioManager.initializeAudioEngine()
        
        // Then
        XCTAssertTrue(result)
        XCTAssertTrue(audioManager.isEngineRunning)
    }
    
    func testInstrumentEngineCreation() throws {
        // Given
        let instrumentType = InstrumentType.piano
        
        // When
        let instrumentEngine = audioManager.createInstrumentEngine(for: instrumentType)
        
        // Then
        XCTAssertNotNil(instrumentEngine)
        XCTAssertEqual(instrumentEngine?.instrumentType, instrumentType)
    }
    
    func testPlaybackControls() throws {
        // Given
        let composition = createTestComposition()
        audioManager.loadComposition(composition)
        
        // When - Test play
        audioManager.play()
        XCTAssertTrue(audioManager.isPlaying)
        
        // When - Test pause
        audioManager.pause()
        XCTAssertFalse(audioManager.isPlaying)
        
        // When - Test stop
        audioManager.stop()
        XCTAssertFalse(audioManager.isPlaying)
        XCTAssertEqual(audioManager.currentPosition, 0.0)
    }
    
    // MARK: - Export Tests
    
    func testMIDIExport() throws {
        // Given
        let composition = createTestComposition()
        
        // When
        let midiData = try MIDIExporter.exportComposition(composition)
        
        // Then
        XCTAssertGreaterThan(midiData.count, 0)
        
        // Verify MIDI header
        let headerString = String(data: midiData.prefix(4), encoding: .ascii)
        XCTAssertEqual(headerString, "MThd")
    }
    
    func testMusicXMLExport() throws {
        // Given
        let composition = createTestComposition()
        
        // When
        let xmlData = try MusicXMLExporter.exportComposition(composition)
        
        // Then
        XCTAssertGreaterThan(xmlData.count, 0)
        
        // Verify XML structure
        let xmlString = String(data: xmlData, encoding: .utf8)
        XCTAssertNotNil(xmlString)
        XCTAssertTrue(xmlString!.contains("<?xml version=\"1.0\""))
        XCTAssertTrue(xmlString!.contains("<score-partwise"))
    }
    
    // MARK: - Performance Tests
    
    func testCompositionGenerationPerformance() throws {
        let parameters = CompositionParameters(
            key: "C",
            form: .aaba,
            style: .jazzPop,
            tempo: 120
        )
        
        measure {
            let expectation = self.expectation(description: "Performance test")
            orchestrationManager.generateComposition(parameters: parameters) { _ in
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func testAudioEnginePerformance() throws {
        let composition = createTestComposition()
        
        measure {
            audioManager.loadComposition(composition)
            audioManager.play()
            Thread.sleep(forTimeInterval: 0.1) // Brief playback
            audioManager.stop()
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestComposition() -> Composition {
        let chord1 = Chord(symbol: "Cmaj7", notes: ["C", "E", "G", "B"])
        let chord2 = Chord(symbol: "Dmin7", notes: ["D", "F", "A", "C"])
        let chord3 = Chord(symbol: "G7", notes: ["G", "B", "D", "F"])
        
        let measures = [
            Measure(chord: chord1, duration: 4.0),
            Measure(chord: chord2, duration: 4.0),
            Measure(chord: chord3, duration: 4.0),
            Measure(chord: chord1, duration: 4.0)
        ]
        
        return Composition(
            title: "Test Composition",
            key: "C",
            form: .aaba,
            style: .jazzPop,
            tempo: 120,
            measures: measures
        )
    }
}

// MARK: - Integration Tests

final class AiXelMusicOrchestratorIntegrationTests: XCTestCase {
    
    func testFullWorkflow() throws {
        // Given
        let orchestrationManager = OrchestrationManager()
        let audioManager = AudioManager()
        
        let parameters = CompositionParameters(
            key: "Eb",
            form: .aaba,
            style: .jazzPop,
            tempo: 110
        )
        
        // When - Generate composition
        let compositionExpectation = expectation(description: "Composition generated")
        var composition: Composition?
        
        orchestrationManager.generateComposition(parameters: parameters) { result in
            composition = result
            compositionExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10.0)
        
        // Then - Load and play composition
        XCTAssertNotNil(composition)
        
        let initResult = audioManager.initializeAudioEngine()
        XCTAssertTrue(initResult)
        
        audioManager.loadComposition(composition!)
        audioManager.play()
        
        XCTAssertTrue(audioManager.isPlaying)
        
        // Test export functionality
        let midiData = try MIDIExporter.exportComposition(composition!)
        let xmlData = try MusicXMLExporter.exportComposition(composition!)
        
        XCTAssertGreaterThan(midiData.count, 0)
        XCTAssertGreaterThan(xmlData.count, 0)
        
        // Cleanup
        audioManager.stop()
    }
    
    func testMixerControls() throws {
        // Given
        let audioManager = AudioManager()
        let composition = createTestComposition()
        
        audioManager.initializeAudioEngine()
        audioManager.loadComposition(composition)
        
        // When - Test volume controls
        for instrumentType in InstrumentType.allCases {
            audioManager.setVolume(0.5, for: instrumentType)
            let volume = audioManager.getVolume(for: instrumentType)
            XCTAssertEqual(volume, 0.5, accuracy: 0.01)
        }
        
        // When - Test reverb controls
        for instrumentType in InstrumentType.allCases {
            audioManager.setReverb(0.3, for: instrumentType)
            let reverb = audioManager.getReverb(for: instrumentType)
            XCTAssertEqual(reverb, 0.3, accuracy: 0.01)
        }
        
        // When - Test mute controls
        audioManager.setMuted(true, for: .piano)
        XCTAssertTrue(audioManager.isMuted(.piano))
        
        audioManager.setMuted(false, for: .piano)
        XCTAssertFalse(audioManager.isMuted(.piano))
    }
    
    private func createTestComposition() -> Composition {
        let chord1 = Chord(symbol: "Ebmaj9", notes: ["Eb", "G", "Bb", "D", "F"])
        let chord2 = Chord(symbol: "Bb/Ab", notes: ["Ab", "Bb", "D", "F"])
        let chord3 = Chord(symbol: "Cmin7", notes: ["C", "Eb", "G", "Bb"])
        let chord4 = Chord(symbol: "Absus2", notes: ["Ab", "Bb", "Eb"])
        
        let measures = [
            Measure(chord: chord1, duration: 4.0),
            Measure(chord: chord2, duration: 4.0),
            Measure(chord: chord3, duration: 4.0),
            Measure(chord: chord4, duration: 4.0)
        ]
        
        return Composition(
            title: "Integration Test Composition",
            key: "Eb",
            form: .aaba,
            style: .jazzPop,
            tempo: 110,
            measures: measures
        )
    }
}

