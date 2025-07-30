//
//  MusicXMLExporter.swift
//  AiXelMusicOrchestrator
//
//  Created by Manus AI on 30/01/2025.
//

import Foundation

class MusicXMLExporter {
    
    static func exportComposition(_ composition: Composition) throws -> Data {
        let xmlContent = generateMusicXMLContent(composition)
        
        guard let xmlData = xmlContent.data(using: .utf8) else {
            throw MusicXMLExportError.encodingFailed
        }
        
        return xmlData
    }
    
    private static func generateMusicXMLContent(_ composition: Composition) -> String {
        var xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE score-partwise PUBLIC "-//Recordare//DTD MusicXML 3.1 Partwise//EN" "http://www.musicxml.org/dtds/partwise.dtd">
        <score-partwise version="3.1">
          <work>
            <work-title>\(composition.title.xmlEscaped)</work-title>
          </work>
          <identification>
            <creator type="composer">AiXel Music Orchestrator</creator>
            <creator type="software">AiXel Music Orchestrator v1.0</creator>
            <encoding>
              <software>AiXel Music Orchestrator</software>
              <encoding-date>\(ISO8601DateFormatter().string(from: Date()))</encoding-date>
            </encoding>
          </identification>
          <defaults>
            <scaling>
              <millimeters>7.2319</millimeters>
              <tenths>40</tenths>
            </scaling>
            <page-layout>
              <page-height>1545</page-height>
              <page-width>1194</page-width>
              <page-margins type="both">
                <left-margin>70</left-margin>
                <right-margin>70</right-margin>
                <top-margin>70</top-margin>
                <bottom-margin>70</bottom-margin>
              </page-margins>
            </page-layout>
          </defaults>
        
        """
        
        // Add part list
        xml += generatePartList()
        
        // Add parts
        xml += generateParts(composition)
        
        xml += "</score-partwise>\n"
        
        return xml
    }
    
    private static func generatePartList() -> String {
        var partList = "  <part-list>\n"
        
        let instruments = InstrumentType.allCases
        for (index, instrument) in instruments.enumerated() {
            let partId = "P\(index + 1)"
            partList += """
              <score-part id="\(partId)">
                <part-name>\(instrument.displayName)</part-name>
                <part-abbreviation>\(getPartAbbreviation(instrument))</part-abbreviation>
                <score-instrument id="\(partId)-I1">
                  <instrument-name>\(instrument.displayName)</instrument-name>
                  <instrument-abbreviation>\(getPartAbbreviation(instrument))</instrument-abbreviation>
                </score-instrument>
                <midi-device id="\(partId)-I1" port="1"></midi-device>
                <midi-instrument id="\(partId)-I1">
                  <midi-channel>\(index + 1)</midi-channel>
                  <midi-program>\(instrument.midiProgram + 1)</midi-program>
                  <volume>78.7402</volume>
                  <pan>0</pan>
                </midi-instrument>
              </score-part>
            
            """
        }
        
        partList += "  </part-list>\n"
        return partList
    }
    
    private static func generateParts(_ composition: Composition) -> String {
        var parts = ""
        
        let instruments = InstrumentType.allCases
        for (index, instrument) in instruments.enumerated() {
            let partId = "P\(index + 1)"
            parts += generatePart(composition, partId: partId, instrumentIndex: index)
        }
        
        return parts
    }
    
    private static func generatePart(_ composition: Composition, partId: String, instrumentIndex: Int) -> String {
        var part = "  <part id=\"\(partId)\">\n"
        
        for (measureIndex, measure) in composition.measures.enumerated() {
            part += generateMeasure(
                measure,
                measureNumber: measureIndex + 1,
                instrumentIndex: instrumentIndex,
                isFirstMeasure: measureIndex == 0,
                composition: composition
            )
        }
        
        part += "  </part>\n"
        return part
    }
    
    private static func generateMeasure(
        _ measure: Measure,
        measureNumber: Int,
        instrumentIndex: Int,
        isFirstMeasure: Bool,
        composition: Composition
    ) -> String {
        var measureXML = "    <measure number=\"\(measureNumber)\">\n"
        
        // Add attributes for first measure
        if isFirstMeasure {
            measureXML += generateAttributes(composition)
        }
        
        // Extract note for this instrument
        if let noteName = extractNoteForInstrument(from: measure, instrumentIndex: instrumentIndex) {
            measureXML += generateNote(noteName, duration: 4) // Whole note duration
        } else {
            // Add rest if no note
            measureXML += generateRest(duration: 4)
        }
        
        measureXML += "    </measure>\n"
        return measureXML
    }
    
    private static func generateAttributes(_ composition: Composition) -> String {
        let keyFifths = getKeyFifths(composition.key)
        
        return """
              <attributes>
                <divisions>1</divisions>
                <key>
                  <fifths>\(keyFifths)</fifths>
                </key>
                <time>
                  <beats>4</beats>
                  <beat-type>4</beat-type>
                </time>
                <clef>
                  <sign>G</sign>
                  <line>2</line>
                </clef>
              </attributes>
        
        """
    }
    
    private static func generateNote(_ noteName: String, duration: Int) -> String {
        let (step, alter, octave) = parseNoteName(noteName)
        
        var noteXML = """
              <note>
                <pitch>
                  <step>\(step)</step>
        
        """
        
        if alter != 0 {
            noteXML += "          <alter>\(alter)</alter>\n"
        }
        
        noteXML += """
                  <octave>\(octave)</octave>
                </pitch>
                <duration>\(duration)</duration>
                <type>whole</type>
              </note>
        
        """
        
        return noteXML
    }
    
    private static func generateRest(duration: Int) -> String {
        return """
              <note>
                <rest/>
                <duration>\(duration)</duration>
                <type>whole</type>
              </note>
        
        """
    }
    
    private static func extractNoteForInstrument(from measure: Measure, instrumentIndex: Int) -> String? {
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
    
    private static func parseNoteName(_ noteName: String) -> (step: String, alter: Int, octave: Int) {
        let cleanNote = noteName.replacingOccurrences(of: "-", with: "")
        
        // Extract step (note letter)
        let step = String(cleanNote.prefix(1))
        
        // Extract alter (sharp/flat)
        var alter = 0
        var octaveStartIndex = cleanNote.index(after: cleanNote.startIndex)
        
        if cleanNote.count > 1 {
            let secondChar = cleanNote[cleanNote.index(after: cleanNote.startIndex)]
            if secondChar == "#" {
                alter = 1
                octaveStartIndex = cleanNote.index(octaveStartIndex, offsetBy: 1)
            } else if secondChar == "b" {
                alter = -1
                octaveStartIndex = cleanNote.index(octaveStartIndex, offsetBy: 1)
            }
        }
        
        // Extract octave
        let octaveString = String(cleanNote[octaveStartIndex...])
        let octave = Int(octaveString.filter { $0.isNumber }) ?? 4
        
        return (step, alter, octave)
    }
    
    private static func getKeyFifths(_ key: String) -> Int {
        let keyMap: [String: Int] = [
            "C": 0, "G": 1, "D": 2, "A": 3, "E": 4, "B": 5, "F#": 6, "C#": 7,
            "F": -1, "Bb": -2, "Eb": -3, "Ab": -4, "Db": -5, "Gb": -6, "Cb": -7
        ]
        
        return keyMap[key] ?? 0
    }
    
    private static func getPartAbbreviation(_ instrument: InstrumentType) -> String {
        switch instrument {
        case .flute: return "Fl."
        case .piano: return "Pno."
        case .violin1: return "Vln. I"
        case .violin2: return "Vln. II"
        case .viola1: return "Vla. I"
        case .viola2: return "Vla. II"
        case .cello: return "Vc."
        case .bass: return "Cb."
        }
    }
}

// MARK: - Error Types

enum MusicXMLExportError: Error, LocalizedError {
    case encodingFailed
    case invalidNoteFormat
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode MusicXML content to UTF-8"
        case .invalidNoteFormat:
            return "Invalid note format in composition"
        }
    }
}

// MARK: - String Extension

extension String {
    var xmlEscaped: String {
        return self
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}

