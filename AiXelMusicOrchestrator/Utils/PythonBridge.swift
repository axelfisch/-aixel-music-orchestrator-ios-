//
//  PythonBridge.swift
//  AiXelMusicOrchestrator
//
//  Created by Manus AI on 30/01/2025.
//

import Foundation

class PythonBridge {
    private let pythonExecutable: String
    private let scriptPath: String
    
    init() {
        // In a real implementation, this would be configured based on the deployment environment
        self.pythonExecutable = "/usr/bin/python3"
        self.scriptPath = Bundle.main.path(forResource: "aixel_orchestrator_core", ofType: "py") ?? ""
    }
    
    // MARK: - Harmonic Generation
    
    func generateHarmonicProgression(_ parameters: GenerationParameters) async throws -> HarmonicData {
        let input = HarmonicGenerationInput(
            key: parameters.key,
            form: parameters.form,
            style: parameters.style,
            tempo: parameters.tempo,
            complexity: parameters.complexity.rawValue
        )
        
        let inputData = try JSONEncoder().encode(input)
        let result = try await executePythonScript(
            function: "generate_harmonic_progression",
            input: inputData
        )
        
        return try JSONDecoder().decode(HarmonicData.self, from: result)
    }
    
    func generateVoicings(_ harmonicData: HarmonicData) async throws -> VoicingData {
        let inputData = try JSONEncoder().encode(harmonicData)
        let result = try await executePythonScript(
            function: "generate_voicings",
            input: inputData
        )
        
        return try JSONDecoder().decode(VoicingData.self, from: result)
    }
    
    func orchestrate(_ voicingData: VoicingData) async throws -> OrchestrationData {
        let inputData = try JSONEncoder().encode(voicingData)
        let result = try await executePythonScript(
            function: "orchestrate",
            input: inputData
        )
        
        return try JSONDecoder().decode(OrchestrationData.self, from: result)
    }
    
    // MARK: - Export Functions
    
    func exportMusicXML(_ composition: Composition) async throws -> Data {
        let inputData = try JSONEncoder().encode(composition)
        let result = try await executePythonScript(
            function: "export_musicxml",
            input: inputData
        )
        
        // The Python script returns base64 encoded XML data
        let response = try JSONDecoder().decode(ExportResponse.self, from: result)
        guard let xmlData = Data(base64Encoded: response.data) else {
            throw PythonBridgeError.invalidExportData
        }
        
        return xmlData
    }
    
    func exportMIDI(_ composition: Composition) async throws -> Data {
        let inputData = try JSONEncoder().encode(composition)
        let result = try await executePythonScript(
            function: "export_midi",
            input: inputData
        )
        
        let response = try JSONDecoder().decode(ExportResponse.self, from: result)
        guard let midiData = Data(base64Encoded: response.data) else {
            throw PythonBridgeError.invalidExportData
        }
        
        return midiData
    }
    
    func exportPDF(_ composition: Composition) async throws -> Data {
        let inputData = try JSONEncoder().encode(composition)
        let result = try await executePythonScript(
            function: "export_pdf",
            input: inputData
        )
        
        let response = try JSONDecoder().decode(ExportResponse.self, from: result)
        guard let pdfData = Data(base64Encoded: response.data) else {
            throw PythonBridgeError.invalidExportData
        }
        
        return pdfData
    }
    
    // MARK: - Python Script Execution
    
    private func executePythonScript(function: String, input: Data) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let result = try self.runPythonProcess(function: function, input: input)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func runPythonProcess(function: String, input: Data) throws -> Data {
        let process = Process()
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        // Configure process
        process.executableURL = URL(fileURLWithPath: pythonExecutable)
        process.arguments = [scriptPath, function]
        process.standardInput = inputPipe
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        // Write input data
        inputPipe.fileHandleForWriting.write(input)
        inputPipe.fileHandleForWriting.closeFile()
        
        // Run process
        try process.run()
        process.waitUntilExit()
        
        // Check for errors
        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw PythonBridgeError.pythonExecutionError(errorString)
        }
        
        // Read output
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        
        if outputData.isEmpty {
            throw PythonBridgeError.noOutput
        }
        
        return outputData
    }
    
    // MARK: - Utility Functions
    
    func validatePythonEnvironment() async throws -> Bool {
        do {
            let testInput = """
            {"test": true}
            """.data(using: .utf8)!
            
            _ = try await executePythonScript(function: "validate_environment", input: testInput)
            return true
        } catch {
            return false
        }
    }
    
    func getAvailableKeys() async throws -> [String] {
        let emptyInput = Data()
        let result = try await executePythonScript(function: "get_available_keys", input: emptyInput)
        let response = try JSONDecoder().decode(KeysResponse.self, from: result)
        return response.keys
    }
    
    func getAvailableForms() async throws -> [String] {
        let emptyInput = Data()
        let result = try await executePythonScript(function: "get_available_forms", input: emptyInput)
        let response = try JSONDecoder().decode(FormsResponse.self, from: result)
        return response.forms
    }
    
    func getAvailableStyles() async throws -> [String] {
        let emptyInput = Data()
        let result = try await executePythonScript(function: "get_available_styles", input: emptyInput)
        let response = try JSONDecoder().decode(StylesResponse.self, from: result)
        return response.styles
    }
}

// MARK: - Data Structures

struct HarmonicGenerationInput: Codable {
    let key: String
    let form: String
    let style: String
    let tempo: Double
    let complexity: String
}

struct HarmonicData: Codable {
    let progression: [HarmonicMeasure]
    let key: String
    let form: String
    let analysis: HarmonicAnalysis
}

struct HarmonicMeasure: Codable {
    let measure: Int
    let chord: String
    let function: String
    let notes: [String]
    let tensions: [String]
}

struct HarmonicAnalysis: Codable {
    let keyCenter: String
    let modulations: [Modulation]
    let cadences: [Cadence]
}

struct Modulation: Codable {
    let fromMeasure: Int
    let toMeasure: Int
    let fromKey: String
    let toKey: String
    let type: String
}

struct Cadence: Codable {
    let measure: Int
    let type: String
    let strength: Double
}

struct VoicingData: Codable {
    let voicings: [VoicingMeasure]
    let orchestration: OrchestrationInfo
}

struct VoicingMeasure: Codable {
    let measure: Int
    let chord: String
    let voicing: InstrumentVoicing
    let dynamics: String
    let articulation: String
}

struct InstrumentVoicing: Codable {
    let flute: String?
    let piano: String?
    let violin1: String?
    let violin2: String?
    let viola1: String?
    let viola2: String?
    let cello: String?
    let bass: String?
}

struct OrchestrationInfo: Codable {
    let texture: String
    let density: String
    let balance: [String: Double]
}

struct ExportResponse: Codable {
    let success: Bool
    let data: String
    let format: String
    let filename: String
}

struct KeysResponse: Codable {
    let keys: [String]
}

struct FormsResponse: Codable {
    let forms: [String]
}

struct StylesResponse: Codable {
    let styles: [String]
}

// MARK: - Error Types

enum PythonBridgeError: Error, LocalizedError {
    case pythonExecutionError(String)
    case invalidExportData
    case noOutput
    case invalidInput
    case scriptNotFound
    
    var errorDescription: String? {
        switch self {
        case .pythonExecutionError(let message):
            return "Python execution error: \(message)"
        case .invalidExportData:
            return "Invalid export data received from Python script"
        case .noOutput:
            return "No output received from Python script"
        case .invalidInput:
            return "Invalid input data for Python script"
        case .scriptNotFound:
            return "Python script not found in bundle"
        }
    }
}

