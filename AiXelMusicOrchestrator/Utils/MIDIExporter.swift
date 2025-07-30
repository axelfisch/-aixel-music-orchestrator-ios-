//
//  MIDIExporter.swift
//  AiXelMusicOrchestrator
//
//  Created by Manus AI on 30/01/2025.
//

import Foundation
import MIDIKit

class MIDIExporter {
    
    static func exportComposition(_ composition: Composition) throws -> Data {
        // Create MIDI file
        let midiFile = MIDIFile()
        
        // Set up file format
        midiFile.format = .multiTrack
        midiFile.ticksPerQuarter = 480
        
        // Create tracks for each instrument
        let instrumentTypes = InstrumentType.allCases
        
        for (index, instrumentType) in instrumentTypes.enumerated() {
            let track = MIDITrack()
            track.name = instrumentType.displayName
            
            // Set instrument program change
            let programChange = MIDIEvent.programChange(
                program: UInt7(instrumentType.midiProgram),
                channel: UInt4(index)
            )
            track.events.append(MIDIEvent.timeStamped(
                delta: .ticks(0),
                event: programChange
            ))
            
            // Add notes for this instrument
            try addNotesToTrack(
                track: track,
                composition: composition,
                instrumentIndex: index,
                channel: UInt4(index)
            )
            
            midiFile.tracks.append(track)
        }
        
        // Export to data
        return try midiFile.rawData()
    }
    
    private static func addNotesToTrack(
        track: MIDITrack,
        composition: Composition,
        instrumentIndex: Int,
        channel: UInt4
    ) throws {
        let beatsPerMeasure = 4.0
        let ticksPerBeat = 480.0
        let ticksPerMeasure = Int(beatsPerMeasure * ticksPerBeat)
        
        for (measureIndex, measure) in composition.measures.enumerated() {
            guard let note = extractNoteForInstrument(
                from: measure,
                instrumentIndex: instrumentIndex
            ) else { continue }
            
            let midiNoteNumber = try getMIDINoteNumber(from: note)
            let velocity = getVelocityForInstrument(instrumentIndex)
            
            let startTick = measureIndex * ticksPerMeasure
            let duration = ticksPerMeasure // Full measure duration
            
            // Note On
            let noteOnEvent = MIDIEvent.noteOn(
                note: UInt7(midiNoteNumber),
                velocity: UInt7(velocity),
                channel: channel
            )
            track.events.append(MIDIEvent.timeStamped(
                delta: .ticks(UInt32(startTick)),
                event: noteOnEvent
            ))
            
            // Note Off
            let noteOffEvent = MIDIEvent.noteOff(
                note: UInt7(midiNoteNumber),
                velocity: UInt7(0),
                channel: channel
            )
            track.events.append(MIDIEvent.timeStamped(
                delta: .ticks(UInt32(duration)),
                event: noteOffEvent
            ))
        }
    }
    
    private static func extractNoteForInstrument(
        from measure: Measure,
        instrumentIndex: Int
    ) -> String? {
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
    
    private static func getMIDINoteNumber(from noteName: String) throws -> UInt8 {
        let noteMap: [String: Int] = [
            "C": 0, "C#": 1, "Db": 1,
            "D": 2, "D#": 3, "Eb": 3,
            "E": 4,
            "F": 5, "F#": 6, "Gb": 6,
            "G": 7, "G#": 8, "Ab": 8,
            "A": 9, "A#": 10, "Bb": 10,
            "B": 11
        ]
        
        // Parse note name and octave
        let cleanNote = noteName.replacingOccurrences(of: "-", with: "")
        let noteRegex = try NSRegularExpression(pattern: "([A-G][#b]?)([0-9])")
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
    
    private static func getVelocityForInstrument(_ instrumentIndex: Int) -> UInt8 {
        let velocities: [UInt8] = [80, 90, 85, 80, 80, 75, 85, 95]
        return velocities[instrumentIndex % velocities.count]
    }
}

// MARK: - MIDI File Structure

struct MIDIFile {
    var format: MIDIFormat = .multiTrack
    var ticksPerQuarter: UInt16 = 480
    var tracks: [MIDITrack] = []
    
    func rawData() throws -> Data {
        var data = Data()
        
        // Header chunk
        data.append("MThd".data(using: .ascii)!)
        data.append(UInt32(6).bigEndianData) // Header length
        data.append(format.rawValue.bigEndianData)
        data.append(UInt16(tracks.count).bigEndianData)
        data.append(ticksPerQuarter.bigEndianData)
        
        // Track chunks
        for track in tracks {
            let trackData = try track.rawData()
            data.append("MTrk".data(using: .ascii)!)
            data.append(UInt32(trackData.count).bigEndianData)
            data.append(trackData)
        }
        
        return data
    }
}

struct MIDITrack {
    var name: String = ""
    var events: [MIDIEvent.TimeStamped] = []
    
    func rawData() throws -> Data {
        var data = Data()
        
        // Track name event
        if !name.isEmpty {
            let nameData = name.data(using: .utf8)!
            data.append(0x00) // Delta time
            data.append(0xFF) // Meta event
            data.append(0x03) // Track name
            data.append(UInt8(nameData.count)) // Length
            data.append(nameData)
        }
        
        // Add all events
        for event in events {
            data.append(try event.rawData())
        }
        
        // End of track
        data.append(0x00) // Delta time
        data.append(0xFF) // Meta event
        data.append(0x2F) // End of track
        data.append(0x00) // Length
        
        return data
    }
}

enum MIDIFormat: UInt16 {
    case singleTrack = 0
    case multiTrack = 1
    case multiSong = 2
}

// MARK: - Extensions

extension UInt16 {
    var bigEndianData: Data {
        return Data([UInt8(self >> 8), UInt8(self & 0xFF)])
    }
}

extension UInt32 {
    var bigEndianData: Data {
        return Data([
            UInt8(self >> 24),
            UInt8((self >> 16) & 0xFF),
            UInt8((self >> 8) & 0xFF),
            UInt8(self & 0xFF)
        ])
    }
}

extension MIDIEvent.TimeStamped {
    func rawData() throws -> Data {
        var data = Data()
        
        // Add delta time (variable length quantity)
        switch delta {
        case .ticks(let ticks):
            data.append(try encodeVariableLengthQuantity(ticks))
        }
        
        // Add event data
        data.append(try event.rawData())
        
        return data
    }
    
    private func encodeVariableLengthQuantity(_ value: UInt32) throws -> Data {
        var result = Data()
        var val = value
        
        result.insert(UInt8(val & 0x7F), at: 0)
        val >>= 7
        
        while val > 0 {
            result.insert(UInt8((val & 0x7F) | 0x80), at: 0)
            val >>= 7
        }
        
        return result
    }
}

extension MIDIEvent {
    func rawData() throws -> Data {
        var data = Data()
        
        switch self {
        case .noteOn(let note, let velocity, let channel):
            data.append(0x90 | UInt8(channel))
            data.append(UInt8(note))
            data.append(UInt8(velocity))
            
        case .noteOff(let note, let velocity, let channel):
            data.append(0x80 | UInt8(channel))
            data.append(UInt8(note))
            data.append(UInt8(velocity))
            
        case .programChange(let program, let channel):
            data.append(0xC0 | UInt8(channel))
            data.append(UInt8(program))
            
        default:
            // Handle other MIDI events as needed
            break
        }
        
        return data
    }
}

