//
//  ChordProgressionView.swift
//  AiXelMusicOrchestrator
//
//  Created by Manus AI on 30/01/2025.
//

import SwiftUI

struct ChordProgressionView: View {
    let composition: Composition
    @State private var currentMeasure: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Chord Progression")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(Array(composition.measures.chunked(into: 4).enumerated()), id: \.offset) { lineIndex, measureGroup in
                    HStack(spacing: 8) {
                        ForEach(Array(measureGroup.enumerated()), id: \.offset) { measureIndex, measure in
                            let globalMeasureIndex = lineIndex * 4 + measureIndex
                            
                            ChordView(
                                chord: measure.chord,
                                measureNumber: globalMeasureIndex + 1,
                                isActive: globalMeasureIndex == currentMeasure
                            )
                        }
                        
                        // Fill remaining spaces if needed
                        ForEach(measureGroup.count..<4, id: \.self) { _ in
                            Spacer()
                                .frame(height: 60)
                        }
                    }
                }
            }
            
            // Form structure indicator
            FormStructureView(composition: composition, currentMeasure: currentMeasure)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.gray.opacity(0.2))
        )
        .onReceive(NotificationCenter.default.publisher(for: .playbackPositionChanged)) { notification in
            if let position = notification.object as? Int {
                currentMeasure = position
            }
        }
    }
}

struct ChordView: View {
    let chord: Chord
    let measureNumber: Int
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(measureNumber)")
                .font(.caption2)
                .foregroundColor(.gray)
            
            Text(chord.symbol)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(isActive ? .black : .white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isActive ? .blue : .gray.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isActive ? .blue : .clear, lineWidth: 2)
                )
        )
        .scaleEffect(isActive ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

struct FormStructureView: View {
    let composition: Composition
    let currentMeasure: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Form Structure: \(composition.form)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack(spacing: 4) {
                ForEach(composition.sections, id: \.name) { section in
                    let isCurrentSection = currentMeasure >= section.startMeasure && 
                                         currentMeasure < section.startMeasure + section.length
                    
                    Text(section.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(isCurrentSection ? .black : .white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isCurrentSection ? .blue : .gray.opacity(0.3))
                        )
                }
            }
        }
    }
}

// Extension to chunk arrays
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

#Preview {
    ChordProgressionView(composition: Composition.sample)
        .background(.black)
}

