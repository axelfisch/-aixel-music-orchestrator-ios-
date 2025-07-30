//
//  ExportView.swift
//  AiXelMusicOrchestrator
//
//  Created by Manus AI on 30/01/2025.
//

import SwiftUI

struct ExportView: View {
    @EnvironmentObject var orchestrationManager: OrchestrationManager
    @State private var selectedFormat: ExportFormat = .musicXML
    @State private var isExporting = false
    @State private var exportProgress: Double = 0
    @State private var showingShareSheet = false
    @State private var exportedFileURL: URL?
    
    enum ExportFormat: String, CaseIterable {
        case musicXML = "MusicXML"
        case midi = "MIDI"
        case audio = "Audio (WAV)"
        case pdf = "PDF Score"
        
        var icon: String {
            switch self {
            case .musicXML: return "doc.text"
            case .midi: return "music.note.list"
            case .audio: return "waveform"
            case .pdf: return "doc.richtext"
            }
        }
        
        var description: String {
            switch self {
            case .musicXML: return "Compatible with MuseScore, Finale, Sibelius"
            case .midi: return "Compatible with DAWs and music software"
            case .audio: return "High-quality audio file"
            case .pdf: return "Printable sheet music"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Text("Export Composition")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Share your orchestrations in various formats")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                if orchestrationManager.currentComposition != nil {
                    // Format Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Export Format")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            ExportFormatRow(
                                format: format,
                                isSelected: selectedFormat == format,
                                action: { selectedFormat = format }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Export Button
                    Button(action: exportComposition) {
                        HStack {
                            if isExporting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "square.and.arrow.up")
                            }
                            
                            Text(isExporting ? "Exporting..." : "Export \(selectedFormat.rawValue)")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.green, .blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isExporting)
                    .padding(.horizontal)
                    
                    // Export Progress
                    if isExporting {
                        VStack(spacing: 8) {
                            ProgressView(value: exportProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            
                            Text("\(Int(exportProgress * 100))% Complete")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Recent Exports
                    RecentExportsView()
                        .padding(.horizontal)
                    
                } else {
                    // No Composition State
                    VStack(spacing: 16) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Composition to Export")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Generate a composition first to enable export options")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.black, .gray.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportedFileURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    private func exportComposition() {
        guard let composition = orchestrationManager.currentComposition else { return }
        
        isExporting = true
        exportProgress = 0
        
        Task {
            do {
                let url = try await orchestrationManager.exportComposition(
                    composition,
                    format: selectedFormat,
                    progressHandler: { progress in
                        DispatchQueue.main.async {
                            exportProgress = progress
                        }
                    }
                )
                
                await MainActor.run {
                    exportedFileURL = url
                    isExporting = false
                    showingShareSheet = true
                }
            } catch {
                await MainActor.run {
                    isExporting = false
                    // Handle error
                    print("Export failed: \(error)")
                }
            }
        }
    }
}

struct ExportFormatRow: View {
    let format: ExportView.ExportFormat
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: format.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(format.rawValue)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(format.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? .blue.opacity(0.2) : .gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? .blue : .clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecentExportsView: View {
    @State private var recentExports: [ExportItem] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Exports")
                .font(.headline)
                .foregroundColor(.white)
            
            if recentExports.isEmpty {
                Text("No recent exports")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
            } else {
                ForEach(recentExports, id: \.id) { export in
                    RecentExportRow(export: export)
                }
            }
        }
    }
}

struct RecentExportRow: View {
    let export: ExportItem
    
    var body: some View {
        HStack {
            Image(systemName: export.format.icon)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(export.filename)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Text(export.date, style: .relative)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button("Share") {
                // Share action
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
}

struct ExportItem {
    let id = UUID()
    let filename: String
    let format: ExportView.ExportFormat
    let date: Date
    let url: URL
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ExportView()
        .environmentObject(OrchestrationManager())
}

