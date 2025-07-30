#!/usr/bin/env python3
"""
AiXel Music Orchestrator Core
Python orchestration engine implementing Axel Fisch's harmonic style
Created by Manus AI on 30/01/2025
"""

import json
import sys
import base64
import random
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass, asdict
from enum import Enum

# MARK: - Core Data Structures

@dataclass
class ChordInfo:
    symbol: str
    notes: List[str]
    function: str
    tensions: List[str]

@dataclass
class VoicingInfo:
    flute: Optional[str] = None
    piano: Optional[str] = None
    violin1: Optional[str] = None
    violin2: Optional[str] = None
    viola1: Optional[str] = None
    viola2: Optional[str] = None
    cello: Optional[str] = None
    bass: Optional[str] = None

@dataclass
class MeasureData:
    measure: int
    chord: ChordInfo
    voicing: VoicingInfo
    dynamics: str = "mf"
    articulation: str = "legato"

# MARK: - Axel Fisch Harmonic Dictionary

AXEL_FISCH_CHORDS = {
    "major_extensions": [
        "add9", "maj7", "maj9", "maj7(11+)", "6/9", "sus2", "sus4"
    ],
    "minor_extensions": [
        "min9", "min7", "min(7+)", "min6", "min(add9)", "min7(b5)"
    ],
    "dominant_extensions": [
        "7", "9", "13", "7(9+5+)", "7(b5)", "13(b9)", "7sus4", "7(ALT)"
    ],
    "diminished": [
        "dim7", "min7(b5)", "dim(add9)"
    ]
}

CHORD_VOICINGS = {
    # Major chords
    "Cmaj7": ["C3", "E4", "G4", "B4"],
    "Cmaj9": ["C3", "E4", "G4", "B4", "D5"],
    "Cadd9": ["C3", "E4", "G4", "D5"],
    "Cmaj7(11+)": ["C3", "E4", "F#4", "B4"],
    "C6/9": ["C3", "E4", "A4", "D5"],
    "Csus2": ["C3", "D4", "G4"],
    "Csus4": ["C3", "F4", "G4"],
    
    # Minor chords
    "Cmin7": ["C3", "Eb4", "G4", "Bb4"],
    "Cmin9": ["C3", "Eb4", "G4", "Bb4", "D5"],
    "Cmin(7+)": ["C3", "Eb4", "G4", "B4"],
    "Cmin6": ["C3", "Eb4", "G4", "A4"],
    "Cmin(add9)": ["C3", "Eb4", "G4", "D5"],
    "Cmin7(b5)": ["C3", "Eb4", "Gb4", "Bb4"],
    
    # Dominant chords
    "C7": ["C3", "E4", "G4", "Bb4"],
    "C9": ["C3", "E4", "G4", "Bb4", "D5"],
    "C13": ["C3", "E4", "G4", "Bb4", "A5"],
    "C7(9+5+)": ["C3", "E4", "G#4", "Bb4", "D#5"],
    "C7(b5)": ["C3", "E4", "Gb4", "Bb4"],
    "C13(b9)": ["C3", "E4", "G4", "Bb4", "Db5", "A5"],
    "C7sus4": ["C3", "F4", "G4", "Bb4"],
    "C7(ALT)": ["C3", "E4", "Gb4", "Bb4", "Db5"],
    
    # Diminished chords
    "Cdim7": ["C3", "Eb4", "Gb4", "A4"],
    "Cdim(add9)": ["C3", "Eb4", "Gb4", "D5"]
}

SCALE_CHORD_RELATIONSHIPS = {
    "C_major": {
        "I": ["Cmaj7", "Cmaj9", "C6/9"],
        "ii": ["Dmin7", "Dmin9", "Dmin13"],
        "iii": ["Emin7", "Esus(b9)"],
        "IV": ["Fmaj7", "Fmaj7(11+)"],
        "V": ["G7", "G9", "G13"],
        "vi": ["Amin7", "Amin9"],
        "vii": ["Bmin7(b5)", "Bdim7"]
    }
}

FORM_STRUCTURES = {
    "AABA": {
        "sections": [
            {"name": "A1", "measures": 8, "harmonic_area": "tonic"},
            {"name": "A2", "measures": 8, "harmonic_area": "tonic"},
            {"name": "B", "measures": 8, "harmonic_area": "bridge"},
            {"name": "A3", "measures": 8, "harmonic_area": "tonic"}
        ],
        "total_measures": 32
    },
    "ABAC": {
        "sections": [
            {"name": "A1", "measures": 8, "harmonic_area": "tonic"},
            {"name": "B", "measures": 8, "harmonic_area": "subdominant"},
            {"name": "A2", "measures": 8, "harmonic_area": "tonic"},
            {"name": "C", "measures": 8, "harmonic_area": "bridge"}
        ],
        "total_measures": 32
    },
    "16 bars": {
        "sections": [
            {"name": "A", "measures": 8, "harmonic_area": "tonic"},
            {"name": "B", "measures": 8, "harmonic_area": "bridge"}
        ],
        "total_measures": 16
    },
    "32 bars": {
        "sections": [
            {"name": "A", "measures": 16, "harmonic_area": "tonic"},
            {"name": "B", "measures": 16, "harmonic_area": "bridge"}
        ],
        "total_measures": 32
    }
}

# MARK: - Harmonic Generation Functions

def generate_harmonic_progression(params: Dict) -> Dict:
    """Generate harmonic progression in Axel Fisch style"""
    key = params.get("key", "C")
    form = params.get("form", "AABA")
    style = params.get("style", "Jazz Pop")
    complexity = params.get("complexity", "Medium")
    
    form_structure = FORM_STRUCTURES.get(form, FORM_STRUCTURES["AABA"])
    total_measures = form_structure["total_measures"]
    
    progression = []
    current_measure = 0
    
    for section in form_structure["sections"]:
        section_chords = generate_section_chords(
            section, key, style, complexity, current_measure
        )
        progression.extend(section_chords)
        current_measure += section["measures"]
    
    return {
        "progression": [asdict(chord) for chord in progression],
        "key": key,
        "form": form,
        "analysis": {
            "keyCenter": key,
            "modulations": [],
            "cadences": analyze_cadences(progression)
        }
    }

def generate_section_chords(section: Dict, key: str, style: str, complexity: str, start_measure: int) -> List[MeasureData]:
    """Generate chords for a specific section"""
    measures = []
    harmonic_area = section["harmonic_area"]
    section_length = section["measures"]
    
    # Define chord progressions based on harmonic area
    if harmonic_area == "tonic":
        chord_templates = get_tonic_progressions(key, style)
    elif harmonic_area == "subdominant":
        chord_templates = get_subdominant_progressions(key, style)
    elif harmonic_area == "bridge":
        chord_templates = get_bridge_progressions(key, style)
    else:
        chord_templates = get_tonic_progressions(key, style)
    
    # Select appropriate progression template
    template = random.choice(chord_templates)
    
    # Generate measures
    for i in range(section_length):
        measure_num = start_measure + i + 1
        chord_index = i % len(template)
        chord_symbol = transpose_chord(template[chord_index], key)
        
        chord_info = ChordInfo(
            symbol=chord_symbol,
            notes=get_chord_notes(chord_symbol),
            function=analyze_chord_function(chord_symbol, key),
            tensions=get_chord_tensions(chord_symbol)
        )
        
        measures.append(MeasureData(
            measure=measure_num,
            chord=chord_info,
            voicing=VoicingInfo(),  # Will be filled in voicing stage
            dynamics=get_section_dynamics(harmonic_area, i, section_length),
            articulation=get_section_articulation(style)
        ))
    
    return measures

def get_tonic_progressions(key: str, style: str) -> List[List[str]]:
    """Get tonic area chord progressions"""
    if style == "Jazz Pop":
        return [
            ["Imaj7", "vi-7", "ii-7", "V7"],
            ["Imaj9", "IV6/9", "ii-7", "V13"],
            ["I6/9", "vi-9", "IV7(11+)", "V7sus4"],
            ["Imaj7", "iii-7", "vi-7", "ii-7"]
        ]
    elif style == "Bossa Nova":
        return [
            ["Imaj7", "ii-7", "V7", "Imaj7"],
            ["I6/9", "vi-7", "ii-7", "V7(ALT)"],
            ["Imaj9", "IV7(11+)", "iii-7", "vi-7"]
        ]
    else:
        return [
            ["Imaj7", "vi-7", "ii-7", "V7"]
        ]

def get_subdominant_progressions(key: str, style: str) -> List[List[str]]:
    """Get subdominant area chord progressions"""
    return [
        ["IV7(11+)", "ii-7", "V7", "Imaj7"],
        ["IVmaj7", "V7/vi", "vi-7", "ii-7"],
        ["IV6/9", "iv-6", "Imaj7", "V7"]
    ]

def get_bridge_progressions(key: str, style: str) -> List[List[str]]:
    """Get bridge section chord progressions"""
    return [
        ["iii-7", "VI7", "ii-7", "V7"],
        ["vi-7", "ii-7", "V7", "Imaj7"],
        ["IV7(11+)", "V7/V", "V7", "Imaj7"],
        ["ii-7", "V7/vi", "vi-7", "V7/V"]
    ]

# MARK: - Voicing Generation Functions

def generate_voicings(harmonic_data: Dict) -> Dict:
    """Generate voicings for each instrument"""
    progression = harmonic_data["progression"]
    voicings = []
    
    for measure_data in progression:
        chord_symbol = measure_data["chord"]["symbol"]
        chord_notes = measure_data["chord"]["notes"]
        
        # Generate voicing for 8 instruments
        voicing = create_axel_fisch_voicing(chord_symbol, chord_notes)
        
        voicing_measure = {
            "measure": measure_data["measure"],
            "chord": chord_symbol,
            "voicing": asdict(voicing),
            "dynamics": measure_data.get("dynamics", "mf"),
            "articulation": measure_data.get("articulation", "legato")
        }
        
        voicings.append(voicing_measure)
    
    return {
        "voicings": voicings,
        "orchestration": {
            "texture": "chamber_ensemble",
            "density": "medium",
            "balance": {
                "flute": 0.8,
                "piano": 0.9,
                "violin1": 0.85,
                "violin2": 0.8,
                "viola1": 0.75,
                "viola2": 0.75,
                "cello": 0.8,
                "bass": 0.9
            }
        }
    }

def create_axel_fisch_voicing(chord_symbol: str, chord_notes: List[str]) -> VoicingInfo:
    """Create voicing in Axel Fisch style"""
    # Ensure we have enough notes for 8 instruments
    extended_notes = extend_chord_notes(chord_notes)
    
    # Distribute notes across instruments following Axel Fisch principles
    voicing = VoicingInfo()
    
    # Flute: Melody (highest note, often doubled)
    voicing.flute = extended_notes[-1] if extended_notes else None
    
    # Piano: Melody doubling or harmonic support
    voicing.piano = extended_notes[-1] if len(extended_notes) > 1 else extended_notes[0] if extended_notes else None
    
    # Violin 1: Upper harmonic voice
    voicing.violin1 = extended_notes[-2] if len(extended_notes) > 2 else extended_notes[0] if extended_notes else None
    
    # Violin 2: Inner harmonic voice
    voicing.violin2 = extended_notes[-3] if len(extended_notes) > 3 else extended_notes[1] if len(extended_notes) > 1 else None
    
    # Viola 1: Middle harmonic voice
    voicing.viola1 = extended_notes[1] if len(extended_notes) > 1 else None
    
    # Viola 2: Middle harmonic voice (doubled)
    voicing.viola2 = extended_notes[2] if len(extended_notes) > 2 else extended_notes[1] if len(extended_notes) > 1 else None
    
    # Cello: Lower harmonic voice or countermelody
    voicing.cello = extended_notes[1] if len(extended_notes) > 1 else extended_notes[0] if extended_notes else None
    
    # Bass: Root or bass note
    voicing.bass = extended_notes[0] if extended_notes else None
    
    return voicing

def extend_chord_notes(chord_notes: List[str]) -> List[str]:
    """Extend chord notes to cover 8 instruments"""
    if len(chord_notes) >= 8:
        return chord_notes[:8]
    
    extended = chord_notes.copy()
    
    # Add octave doublings and extensions
    while len(extended) < 8:
        for note in chord_notes:
            if len(extended) >= 8:
                break
            # Add octave higher
            octave_higher = transpose_note_octave(note, 1)
            if octave_higher not in extended:
                extended.append(octave_higher)
    
    return extended[:8]

# MARK: - Export Functions

def export_musicxml(composition_data: Dict) -> Dict:
    """Export composition to MusicXML format"""
    try:
        xml_content = generate_musicxml_content(composition_data)
        xml_base64 = base64.b64encode(xml_content.encode('utf-8')).decode('utf-8')
        
        return {
            "success": True,
            "data": xml_base64,
            "format": "musicxml",
            "filename": f"{composition_data.get('title', 'composition')}.musicxml"
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "data": "",
            "format": "musicxml",
            "filename": ""
        }

def export_midi(composition_data: Dict) -> Dict:
    """Export composition to MIDI format"""
    try:
        midi_data = generate_midi_data(composition_data)
        midi_base64 = base64.b64encode(midi_data).decode('utf-8')
        
        return {
            "success": True,
            "data": midi_base64,
            "format": "midi",
            "filename": f"{composition_data.get('title', 'composition')}.mid"
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "data": "",
            "format": "midi",
            "filename": ""
        }

def export_pdf(composition_data: Dict) -> Dict:
    """Export composition to PDF format"""
    try:
        pdf_data = generate_pdf_score(composition_data)
        pdf_base64 = base64.b64encode(pdf_data).decode('utf-8')
        
        return {
            "success": True,
            "data": pdf_base64,
            "format": "pdf",
            "filename": f"{composition_data.get('title', 'composition')}.pdf"
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "data": "",
            "format": "pdf",
            "filename": ""
        }

# MARK: - Utility Functions

def transpose_chord(chord_roman: str, key: str) -> str:
    """Transpose roman numeral chord to actual chord symbol"""
    # Simplified transposition - in real implementation would be more sophisticated
    key_map = {
        "C": {"I": "C", "ii": "D-", "iii": "E-", "IV": "F", "V": "G", "vi": "A-", "vii": "B"},
        "Eb": {"I": "Eb", "ii": "F-", "iii": "G-", "IV": "Ab", "V": "Bb", "vi": "C-", "vii": "D"},
        "F": {"I": "F", "ii": "G-", "iii": "A-", "IV": "Bb", "V": "C", "vi": "D-", "vii": "E"},
        "G": {"I": "G", "ii": "A-", "iii": "B-", "IV": "C", "V": "D", "vi": "E-", "vii": "F#"}
    }
    
    base_key_map = key_map.get(key, key_map["C"])
    
    # Extract roman numeral and quality
    base_roman = chord_roman.split("maj")[0].split("7")[0].split("-")[0].split("6")[0].split("9")[0].split("sus")[0].split("(")[0]
    chord_root = base_key_map.get(base_roman, "C")
    
    # Reconstruct chord with extensions
    if "maj7" in chord_roman:
        return f"{chord_root}maj7"
    elif "maj9" in chord_roman:
        return f"{chord_root}maj9"
    elif "-7" in chord_roman:
        return f"{chord_root}min7"
    elif "-9" in chord_roman:
        return f"{chord_root}min9"
    elif "7" in chord_roman:
        return f"{chord_root}7"
    elif "6/9" in chord_roman:
        return f"{chord_root}6/9"
    elif "add9" in chord_roman:
        return f"{chord_root}add9"
    else:
        return chord_root

def get_chord_notes(chord_symbol: str) -> List[str]:
    """Get notes for a chord symbol"""
    # Simplified chord note generation
    base_voicing = CHORD_VOICINGS.get("Cmaj7", ["C3", "E4", "G4", "B4"])
    
    # Transpose to correct key
    root = chord_symbol[0]
    if len(chord_symbol) > 1 and chord_symbol[1] in ['#', 'b']:
        root = chord_symbol[:2]
    
    transposed_notes = []
    for note in base_voicing:
        transposed_note = transpose_note(note, root)
        transposed_notes.append(transposed_note)
    
    return transposed_notes

def transpose_note(note: str, target_root: str) -> str:
    """Transpose a note to a different root"""
    # Simplified transposition
    note_map = {"C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3, "E": 4, "F": 5, "F#": 6, "Gb": 6, "G": 7, "G#": 8, "Ab": 8, "A": 9, "A#": 10, "Bb": 10, "B": 11}
    
    original_root = note[0]
    if len(note) > 1 and note[1] in ['#', 'b']:
        original_root = note[:2]
    
    octave = note[-1] if note[-1].isdigit() else "4"
    
    original_value = note_map.get(original_root, 0)
    target_value = note_map.get(target_root, 0)
    interval = target_value - original_value
    
    # Apply transposition (simplified)
    return f"{target_root}{octave}"

def transpose_note_octave(note: str, octave_change: int) -> str:
    """Transpose note by octave"""
    if note and note[-1].isdigit():
        current_octave = int(note[-1])
        new_octave = current_octave + octave_change
        return note[:-1] + str(max(0, min(9, new_octave)))
    return note

def analyze_chord_function(chord_symbol: str, key: str) -> str:
    """Analyze harmonic function of chord"""
    # Simplified function analysis
    if "maj7" in chord_symbol or "6/9" in chord_symbol:
        return "tonic"
    elif "min7" in chord_symbol:
        return "subdominant"
    elif "7" in chord_symbol and "maj" not in chord_symbol:
        return "dominant"
    else:
        return "tonic"

def get_chord_tensions(chord_symbol: str) -> List[str]:
    """Get available tensions for chord"""
    tensions = []
    if "9" in chord_symbol:
        tensions.append("9")
    if "11" in chord_symbol:
        tensions.append("11")
    if "13" in chord_symbol:
        tensions.append("13")
    if "b5" in chord_symbol:
        tensions.append("b5")
    if "#11" in chord_symbol or "11+" in chord_symbol:
        tensions.append("#11")
    return tensions

def get_section_dynamics(harmonic_area: str, measure_index: int, section_length: int) -> str:
    """Get dynamics for section"""
    if harmonic_area == "bridge":
        return "f" if measure_index < section_length // 2 else "mf"
    else:
        return "mf"

def get_section_articulation(style: str) -> str:
    """Get articulation for style"""
    if style == "Bossa Nova":
        return "legato"
    elif style == "ECM Style":
        return "molto legato"
    else:
        return "legato"

def analyze_cadences(progression: List[MeasureData]) -> List[Dict]:
    """Analyze cadences in progression"""
    cadences = []
    for i in range(len(progression) - 1):
        current_function = progression[i].chord.function
        next_function = progression[i + 1].chord.function
        
        if current_function == "dominant" and next_function == "tonic":
            cadences.append({
                "measure": progression[i + 1].measure,
                "type": "authentic",
                "strength": 0.9
            })
        elif current_function == "subdominant" and next_function == "tonic":
            cadences.append({
                "measure": progression[i + 1].measure,
                "type": "plagal",
                "strength": 0.7
            })
    
    return cadences

def generate_musicxml_content(composition_data: Dict) -> str:
    """Generate MusicXML content"""
    # Simplified MusicXML generation
    xml_header = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE score-partwise PUBLIC "-//Recordare//DTD MusicXML 3.1 Partwise//EN" "http://www.musicxml.org/dtds/partwise.dtd">
<score-partwise version="3.1">
  <work>
    <work-title>{title}</work-title>
  </work>
  <identification>
    <creator type="composer">AiXel Music Orchestrator</creator>
  </identification>'''.format(title=composition_data.get('title', 'Untitled'))
    
    # Add parts and measures (simplified)
    xml_content = xml_header + '''
  <part-list>
    <score-part id="P1">
      <part-name>Piano</part-name>
    </score-part>
  </part-list>
  <part id="P1">
    <measure number="1">
      <attributes>
        <divisions>4</divisions>
        <key>
          <fifths>0</fifths>
        </key>
        <time>
          <beats>4</beats>
          <beat-type>4</beat-type>
        </time>
      </attributes>
      <note>
        <pitch>
          <step>C</step>
          <octave>4</octave>
        </pitch>
        <duration>16</duration>
        <type>whole</type>
      </note>
    </measure>
  </part>
</score-partwise>'''
    
    return xml_content

def generate_midi_data(composition_data: Dict) -> bytes:
    """Generate MIDI data"""
    # Simplified MIDI generation - would use proper MIDI library in real implementation
    return b"MThd\x00\x00\x00\x06\x00\x00\x00\x01\x00\x60MTrk\x00\x00\x00\x04\x00\xff/\x00"

def generate_pdf_score(composition_data: Dict) -> bytes:
    """Generate PDF score"""
    # Simplified PDF generation - would use proper PDF library in real implementation
    return b"%PDF-1.4\n1 0 obj\n<<\n/Type /Catalog\n/Pages 2 0 R\n>>\nendobj\n"

# MARK: - Main Function

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "No function specified"}))
        return
    
    function_name = sys.argv[1]
    
    try:
        # Read input from stdin
        input_data = sys.stdin.read()
        if input_data:
            params = json.loads(input_data)
        else:
            params = {}
        
        # Execute requested function
        if function_name == "generate_harmonic_progression":
            result = generate_harmonic_progression(params)
        elif function_name == "generate_voicings":
            result = generate_voicings(params)
        elif function_name == "orchestrate":
            result = {"measures": params.get("voicings", [])}
        elif function_name == "export_musicxml":
            result = export_musicxml(params)
        elif function_name == "export_midi":
            result = export_midi(params)
        elif function_name == "export_pdf":
            result = export_pdf(params)
        elif function_name == "validate_environment":
            result = {"valid": True, "version": "1.0.0"}
        elif function_name == "get_available_keys":
            result = {"keys": ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]}
        elif function_name == "get_available_forms":
            result = {"forms": list(FORM_STRUCTURES.keys())}
        elif function_name == "get_available_styles":
            result = {"styles": ["Jazz Pop", "Bossa Nova", "ECM Style", "Rubato"]}
        else:
            result = {"error": f"Unknown function: {function_name}"}
        
        print(json.dumps(result))
        
    except Exception as e:
        print(json.dumps({"error": str(e)}))

if __name__ == "__main__":
    main()

