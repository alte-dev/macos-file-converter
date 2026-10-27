import Foundation
import UniformTypeIdentifiers
import AppKit

public enum ConversionFormat: String, CaseIterable, Identifiable {
    case webp = "WebP"
    case jpeg = "JPEG"
    case jpg = "JPG"
    case png = "PNG"
    case heic = "HEIC"
    case avif = "AVIF"
    case tiff = "TIFF"
    case bmp = "BMP"
    case gif = "GIF"
    case pdf = "PDF"
    case icns = "ICNS"
    
    public var id: String { rawValue }
    
    public var fileExtension: String {
        switch self {
        case .webp: return "webp"
        case .jpeg: return "jpeg"
        case .jpg: return "jpg"
        case .png: return "png"
        case .heic: return "heic"
        case .avif: return "avif"
        case .tiff: return "tiff"
        case .bmp: return "bmp"
        case .gif: return "gif"
        case .pdf: return "pdf"
        case .icns: return "icns"
        }
    }
    
    public func displayName(for language: AppLanguage) -> String {
        let s = language.strings
        switch self {
        case .webp: return s.formatWebPDesc
        case .jpeg: return "JPEG (.jpeg)"
        case .jpg: return "JPG (.jpg)"
        case .png: return s.formatPNGDesc
        case .heic: return s.formatHEICDesc
        case .avif: return s.formatAVIFDesc
        case .tiff: return s.formatTIFFDesc
        case .bmp: return "BMP (.bmp)"
        case .gif: return "GIF (.gif)"
        case .pdf: return s.formatPDFDesc
        case .icns: return s.formatICNSDesc
        }
    }
    
    public var displayName: String {
        displayName(for: L10n.currentLanguage)
    }
    
    public var utType: UTType {
        switch self {
        case .webp: return .webP
        case .jpeg, .jpg: return .jpeg
        case .png: return .png
        case .heic: return .heic
        case .avif: return UTType("public.avif") ?? .image
        case .tiff: return .tiff
        case .bmp: return .bmp
        case .gif: return .gif
        case .pdf: return .pdf
        case .icns: return .icns
        }
    }
    
    public var supportsQuality: Bool {
        switch self {
        case .webp, .jpeg, .jpg, .heic, .avif:
            return true
        default:
            return false
        }
    }
}

public enum SaveLocationMode: String, CaseIterable, Identifiable {
    case sameFolder = "sameFolder"
    case customFolder = "customFolder"
    
    public var id: String { rawValue }
    
    public func title(for language: AppLanguage) -> String {
        let s = language.strings
        switch self {
        case .sameFolder: return s.saveSameFolder
        case .customFolder: return s.saveCustomFolder
        }
    }
    
    public var title: String {
        title(for: L10n.currentLanguage)
    }
}

public enum ConversionStatus: Equatable {
    case pending
    case converting
    case success
    case failed(String)
    
    public var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
    
    public var isConverting: Bool {
        if case .converting = self { return true }
        return false
    }
}

public struct ConversionItem: Identifiable {
    public let id: UUID
    public let inputURL: URL
    public var outputURL: URL?
    public let originalFileSize: Int64
    public var convertedFileSize: Int64?
    public var status: ConversionStatus
    public var thumbnail: NSImage?
    public var errorMessage: String?
    
    public init(url: URL) {
        self.id = UUID()
        self.inputURL = url
        self.outputURL = nil
        self.status = .pending
        self.errorMessage = nil
        
        let resources = try? url.resourceValues(forKeys: [.fileSizeKey])
        self.originalFileSize = Int64(resources?.fileSize ?? 0)
        self.convertedFileSize = nil
        self.thumbnail = nil
    }
    
    public var inputFileName: String {
        inputURL.lastPathComponent
    }
    
    public var inputExtension: String {
        inputURL.pathExtension.uppercased()
    }
    
    public var formattedOriginalSize: String {
        ByteCountFormatter.string(fromByteCount: originalFileSize, countStyle: .file)
    }
    
    public var formattedConvertedSize: String? {
        guard let size = convertedFileSize else { return nil }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

