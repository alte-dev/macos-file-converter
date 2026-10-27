import SwiftUI

public struct SettingsView: View {
    @ObservedObject var viewModel: FileConverterViewModel
    
    public init(viewModel: FileConverterViewModel) {
        self.viewModel = viewModel
    }
    
    private var s: L10nStrings {
        viewModel.strings
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            // Row 1: Target Format & Quality
            HStack(alignment: .center, spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "photo.badge.arrow.forward")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 14, weight: .semibold))
                    Text(s.targetFormatLabel)
                        .font(.system(size: 13, weight: .semibold))
                    
                    Picker("", selection: $viewModel.selectedFormat) {
                        ForEach(ConversionFormat.allCases) { format in
                            Text(format.displayName(for: viewModel.language)).tag(format)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 210)
                }
                
                if viewModel.selectedFormat.supportsQuality {
                    Divider()
                        .frame(height: 20)
                    
                    HStack(spacing: 8) {
                        Text(s.qualityLabel)
                            .font(.system(size: 13, weight: .semibold))
                        
                        Slider(value: $viewModel.quality, in: 0.1...1.0, step: 0.05)
                            .frame(width: 110)
                        
                        Text("\(Int(viewModel.quality * 100))%")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                            .frame(width: 38, alignment: .leading)
                    }
                }
                
                Spacer()
                
                Toggle(s.autoConvertToggle, isOn: $viewModel.autoConvertOnDrop)
                    .toggleStyle(.checkbox)
                    .font(.system(size: 12))
                    .help(s.autoConvertHelp)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
            
            // Row 2: Destination Folder
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    Image(systemName: "folder")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 14, weight: .semibold))
                    Text(s.saveLocationLabel)
                        .font(.system(size: 13, weight: .semibold))
                    
                    Picker("", selection: $viewModel.saveLocationMode) {
                        Text(s.saveSameFolder).tag(SaveLocationMode.sameFolder)
                        Text(s.saveCustomFolder).tag(SaveLocationMode.customFolder)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 360)
                    
                    Spacer()
                }
                
                if viewModel.saveLocationMode == .customFolder {
                    HStack(spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "folder.fill")
                                .foregroundColor(.accentColor)
                            Text(viewModel.customFolderPathDisplay)
                                .font(.system(size: 12, design: .monospaced))
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                        
                        Button(s.chooseFolderButton) {
                            viewModel.selectCustomFolder()
                        }
                        .buttonStyle(.bordered)
                        
                        Menu {
                            Button(s.quickFolderDesktop) {
                                viewModel.setQuickFolder(type: .desktopDirectory)
                            }
                            Button(s.quickFolderDownloads) {
                                viewModel.setQuickFolder(type: .downloadsDirectory)
                            }
                            Button(s.quickFolderPictures) {
                                viewModel.setQuickFolder(type: .picturesDirectory)
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        .menuStyle(.borderlessButton)
                        .frame(width: 24)
                        .help(s.quickFolderHelp)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                // Advanced Toggles
                HStack(spacing: 20) {
                    Toggle(s.overwriteToggle, isOn: $viewModel.overwriteExisting)
                        .toggleStyle(.checkbox)
                        .font(.system(size: 12))
                        .help(s.overwriteHelp)
                    
                    Toggle(s.deleteOriginalToggle, isOn: $viewModel.deleteOriginal)
                        .toggleStyle(.checkbox)
                        .font(.system(size: 12))
                        .help(s.deleteOriginalHelp)
                    
                    Spacer()
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
        }
    }
}

