import SwiftUI

public struct ContentView: View {
    @StateObject private var viewModel: FileConverterViewModel
    
    @MainActor
    public init() {
        _viewModel = StateObject(wrappedValue: FileConverterViewModel())
    }
    
    @MainActor
    public init(viewModel: FileConverterViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private var s: L10nStrings {
        viewModel.strings
    }
    
    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header Bar
                HStack(spacing: 12) {
                    Image(systemName: "arrow.triangle.2.circlepath.doc.on.clipboard")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.accentColor)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Alte File Converter")
                            .font(.system(size: 15, weight: .bold))
                        Text(s.appSubtitle)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Language Selector Menu
                    Menu {
                        ForEach(AppLanguage.allCases) { lang in
                            Button {
                                viewModel.language = lang
                            } label: {
                                HStack {
                                    Text(lang.menuLabel)
                                    if viewModel.language == lang {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "globe")
                                .font(.system(size: 12))
                            Text(viewModel.language.badgeLabel)
                                .font(.system(size: 12, weight: .medium))
                        }
                    }
                    .menuStyle(.borderedButton)
                    .fixedSize()
                    .help(s.languageTooltip)
                    
                    Button {
                        viewModel.openFileDialog()
                    } label: {
                        Label(s.chooseFilesButton, systemImage: "plus.circle")
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(Color(nsColor: .windowBackgroundColor))
                
                Divider()
                
                // Settings Section
                SettingsView(viewModel: viewModel)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                
                // Main Content (Drop Zone / List)
                if viewModel.items.isEmpty {
                    emptyStateDropZone
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    itemListSection
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Divider()
                
                // Bottom Footer Toolbar
                footerBar
            }
            
            // Floating notification toast
            if let banner = viewModel.bannerMessage {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text(banner)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.85))
                    .cornerRadius(20)
                    .shadow(radius: 8)
                    .padding(.bottom, 60)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut(duration: 0.25), value: viewModel.bannerMessage)
            }
            
            // Full window drop target overlay
            DropTargetOverlay(
                onDropURLs: { urls in
                    viewModel.handleIncomingURLs(urls)
                },
                onTargetStateChanged: { isTargeted in
                    viewModel.isDropTargeted = isTargeted
                }
            )
            .opacity(0.001) // Invisible overlay to capture drops across the entire window
            
            // Visual drag overlay indicator when user drags files over window
            if viewModel.isDropTargeted {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.accentColor, style: StrokeStyle(lineWidth: 4, dash: [10, 6]))
                    .background(Color.accentColor.opacity(0.08))
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.accentColor)
                            Text(s.dropOverlayTitle)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.accentColor)
                        }
                    )
                    .allowsHitTesting(false)
            }
        }
        .frame(minWidth: 720, minHeight: 560)
    }
    
    // MARK: - Subviews
    
    private var emptyStateDropZone: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    viewModel.isDropTargeted ? Color.accentColor : Color.secondary.opacity(0.3),
                    style: StrokeStyle(lineWidth: 2, dash: [8, 6])
                )
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(viewModel.isDropTargeted ? Color.accentColor.opacity(0.05) : Color(nsColor: .controlBackgroundColor).opacity(0.4))
                )
            
            VStack(spacing: 14) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 46))
                    .foregroundColor(viewModel.isDropTargeted ? .accentColor : .secondary)
                
                VStack(spacing: 4) {
                    Text(s.emptyDropTitle)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text(s.emptyDropSubtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Button(s.emptyDropButton) {
                    viewModel.openFileDialog()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            }
            .padding(24)
        }
    }
    
    private var itemListSection: some View {
        VStack(spacing: 8) {
            // Mini drop banner
            HStack {
                Image(systemName: "arrow.down.doc")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Text(s.miniDropHint)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Button(s.miniDropAddButton) {
                    viewModel.openFileDialog()
                }
                .buttonStyle(.link)
                .font(.system(size: 11))
                
                Spacer()
                
                Text(s.filesInQueue(viewModel.items.count))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
            .padding(.top, 2)
            
            // List of items
            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(viewModel.items) { item in
                        ItemRowView(
                            item: item,
                            targetFormat: viewModel.selectedFormat,
                            strings: s,
                            onConvert: {
                                viewModel.convertSingleItem(id: item.id)
                            },
                            onRemove: {
                                viewModel.removeItem(id: item.id)
                            },
                            onReveal: { url in
                                viewModel.revealInFinder(url: url)
                            }
                        )
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private var footerBar: some View {
        HStack(spacing: 14) {
            if !viewModel.items.isEmpty {
                Button(s.clearAllButton) {
                    viewModel.clearAll()
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .font(.system(size: 12))
                
                if viewModel.successCount > 0 {
                    Button(s.clearCompletedButton) {
                        viewModel.clearCompleted()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
                }
            }
            
            Spacer()
            
            if viewModel.successCount > 0 {
                Button {
                    viewModel.openTargetFolder()
                } label: {
                    Label(s.openFolderButton, systemImage: "folder")
                }
                .buttonStyle(.bordered)
            }
            
            Button {
                viewModel.convertAll()
            } label: {
                HStack(spacing: 6) {
                    if viewModel.isProcessing {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    Text(viewModel.isProcessing ? s.convertingButton : s.convertAllButton)
                        .fontWeight(.semibold)
                }
                .frame(minWidth: 140)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.items.isEmpty || viewModel.isProcessing || viewModel.pendingCount == 0)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

