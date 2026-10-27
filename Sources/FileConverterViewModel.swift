import Foundation
import SwiftUI
import AppKit
import Combine

@MainActor
public final class FileConverterViewModel: ObservableObject {
    @Published public var items: [ConversionItem] = []
    @Published public var selectedFormat: ConversionFormat = .webp
    @Published public var quality: Double = 0.85
    @Published public var saveLocationMode: SaveLocationMode = .sameFolder
    @Published public var customFolderURL: URL?
    @Published public var overwriteExisting: Bool = false
    @Published public var deleteOriginal: Bool = false
    @Published public var autoConvertOnDrop: Bool = false
    @Published public var isProcessing: Bool = false
    @Published public var isDropTargeted: Bool = false
    @Published public var bannerMessage: String?
    @Published public var language: AppLanguage = L10n.currentLanguage {
        didSet {
            L10n.currentLanguage = language
        }
    }
    
    public var strings: L10nStrings {
        language.strings
    }
    
    private let supportedExtensions: Set<String> = [
        "png", "jpg", "jpeg", "heic", "heif", "webp", "tiff", "tif",
        "bmp", "gif", "avif", "pdf", "ico", "icns", "psd", "svg",
        "raw", "cr2", "nef", "arw", "dng", "tga"
    ]
    
    public init() {
        self.language = L10n.currentLanguage
        // Default custom folder to Desktop
        if let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first {
            self.customFolderURL = desktop
        }
    }
    
    public var pendingCount: Int {
        items.filter { $0.status == .pending }.count
    }
    
    public var successCount: Int {
        items.filter { $0.status.isSuccess }.count
    }
    
    public var totalCount: Int {
        items.count
    }
    
    public var customFolderPathDisplay: String {
        guard let url = customFolderURL else { return strings.noFolderSelected }
        return url.path.replacingOccurrences(of: NSHomeDirectory(), with: "~")
    }
    
    // MARK: - File Ingestion
    
    public func handleIncomingURLs(_ rawURLs: [URL]) {
        let collected = collectImageURLs(from: rawURLs)
        guard !collected.isEmpty else {
            showBanner(strings.noSupportedImagesBanner)
            return
        }
        
        var newItems: [ConversionItem] = []
        for url in collected {
            // Avoid duplicate inputs in current pending list
            if !items.contains(where: { $0.inputURL.path == url.path && $0.status == .pending }) {
                let item = ConversionItem(url: url)
                // Generate quick thumbnail asynchronously
                newItems.append(item)
            }
        }
        
        items.append(contentsOf: newItems)
        
        // Asynchronously load thumbnails
        for item in newItems {
            Task.detached(priority: .userInitiated) {
                let thumb = ConverterEngine.generateThumbnail(for: item.inputURL)
                await MainActor.run {
                    if let index = self.items.firstIndex(where: { $0.id == item.id }) {
                        self.items[index].thumbnail = thumb
                    }
                }
            }
        }
        
        if autoConvertOnDrop {
            convertAll()
        }
    }
    
    private func collectImageURLs(from urls: [URL]) -> [URL] {
        var results: [URL] = []
        let fm = FileManager.default
        
        for url in urls {
            var isDir: ObjCBool = false
            if fm.fileExists(atPath: url.path, isDirectory: &isDir) {
                if isDir.boolValue {
                    if let enumerator = fm.enumerator(
                        at: url,
                        includingPropertiesForKeys: [.isRegularFileKey],
                        options: [.skipsHiddenFiles, .skipsPackageDescendants]
                    ) {
                        for case let fileURL as URL in enumerator {
                            if isSupported(fileURL) {
                                results.append(fileURL)
                            }
                        }
                    }
                } else if isSupported(url) {
                    results.append(url)
                }
            }
        }
        return results
    }
    
    private func isSupported(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return supportedExtensions.contains(ext)
    }
    
    // MARK: - Conversion
    
    public func convertAll() {
        guard !isProcessing else { return }
        
        let pendingIndices = items.indices.filter { items[$0].status == .pending || items[$0].status != .success }
        guard !pendingIndices.isEmpty else { return }
        
        isProcessing = true
        
        Task {
            for index in pendingIndices {
                await convertItemAtIndex(index)
            }
            self.isProcessing = false
            self.showBanner(self.strings.convertedSuccessBanner(self.successCount))
        }
    }
    
    public func convertSingleItem(id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        Task {
            await convertItemAtIndex(index)
        }
    }
    
    private func convertItemAtIndex(_ index: Int) async {
        guard index < items.count else { return }
        items[index].status = .converting
        items[index].errorMessage = nil
        
        let item = items[index]
        let format = selectedFormat
        let q = Float(quality)
        let mode = saveLocationMode
        let customFolder = customFolderURL
        let overwrite = overwriteExisting
        let delete = deleteOriginal
        
        do {
            let result = try await Task.detached(priority: .userInitiated) {
                try ConverterEngine.convert(
                    inputURL: item.inputURL,
                    targetFormat: format,
                    quality: q,
                    saveLocationMode: mode,
                    customFolderURL: customFolder,
                    overwriteExisting: overwrite,
                    deleteOriginal: delete
                )
            }.value
            
            items[index].outputURL = result.outputURL
            items[index].convertedFileSize = result.fileSize
            items[index].status = .success
        } catch {
            items[index].status = .failed(error.localizedDescription)
            items[index].errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Item Management
    
    public func removeItem(id: UUID) {
        items.removeAll(where: { $0.id == id })
    }
    
    public func clearCompleted() {
        items.removeAll(where: { $0.status.isSuccess })
    }
    
    public func clearAll() {
        items.removeAll()
    }
    
    // MARK: - Navigation & Panels
    
    public func revealInFinder(url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    public func openTargetFolder() {
        let folderURL: URL?
        switch saveLocationMode {
        case .sameFolder:
            folderURL = items.first(where: { $0.outputURL != nil })?.outputURL?.deletingLastPathComponent()
                ?? items.first?.inputURL.deletingLastPathComponent()
        case .customFolder:
            folderURL = customFolderURL
        }
        
        if let folder = folderURL {
            NSWorkspace.shared.open(folder)
        }
    }
    
    public func selectCustomFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = strings.folderPanelPrompt
        panel.message = strings.folderPanelMessage
        
        if let current = customFolderURL {
            panel.directoryURL = current
        }
        
        if panel.runModal() == .OK, let selectedURL = panel.url {
            self.customFolderURL = selectedURL
            self.saveLocationMode = .customFolder
        }
    }
    
    public func setQuickFolder(type: FileManager.SearchPathDirectory) {
        if let folder = FileManager.default.urls(for: type, in: .userDomainMask).first {
            self.customFolderURL = folder
            self.saveLocationMode = .customFolder
        }
    }
    
    public func openFileDialog() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.prompt = strings.openPanelPrompt
        panel.message = strings.openPanelMessage
        
        if panel.runModal() == .OK {
            handleIncomingURLs(panel.urls)
        }
    }
    
    private func showBanner(_ message: String) {
        self.bannerMessage = message
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if self.bannerMessage == message {
                self.bannerMessage = nil
            }
        }
    }
}

