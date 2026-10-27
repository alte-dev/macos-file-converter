import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import AppKit
import PDFKit

public final class ConverterEngine {
    
    public enum EngineError: LocalizedError {
        case fileNotFound
        case cannotReadImageSource
        case cannotCreateImage
        case cannotCreateDestination
        case finalizeFailed
        case cannotCreateTemporaryFile
        
        public var errorDescription: String? {
            let s = L10n.current
            switch self {
            case .fileNotFound:
                return s.errFileNotFound
            case .cannotReadImageSource:
                return s.errCannotReadImageSource
            case .cannotCreateImage:
                return s.errCannotCreateImage
            case .cannotCreateDestination:
                return s.errCannotCreateDestination
            case .finalizeFailed:
                return s.errFinalizeFailed
            case .cannotCreateTemporaryFile:
                return s.errCannotCreateTempFile
            }
        }
    }
    
    /// Generates a fast, high-quality thumbnail for display in the queue
    public static func generateThumbnail(for url: URL, maxDimension: CGFloat = 140) -> NSImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension
        ]
        
        if let source = CGImageSourceCreateWithURL(url as CFURL, nil),
           let cgThumb = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) {
            return NSImage(cgImage: cgThumb, size: NSSize(width: cgThumb.width, height: cgThumb.height))
        }
        
        // Fallback for PDF
        if url.pathExtension.lowercased() == "pdf", let doc = PDFDocument(url: url), let page = doc.page(at: 0) {
            let bounds = page.bounds(for: .mediaBox)
            let scale = maxDimension / max(bounds.width, bounds.height)
            let targetSize = NSSize(width: bounds.width * scale, height: bounds.height * scale)
            return page.thumbnail(of: targetSize, for: .mediaBox)
        }
        
        // System file icon fallback
        return NSWorkspace.shared.icon(forFile: url.path)
    }
    
    /// Flattens transparent images onto a solid white background (crucial for JPEG & BMP)
    private static func flattenAlpha(cgImage: CGImage, background: CGColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)) -> CGImage? {
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let ctx = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else { return nil }
        
        ctx.setFillColor(background)
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return ctx.makeImage()
    }
    
    /// Loads a CGImage from various source types (standard images, PDFs, SVGs)
    private static func loadCGImage(from url: URL) throws -> CGImage {
        // 1. Try ImageIO
        let readOptions: [CFString: Any] = [
            kCGImageSourceShouldCache: true as CFBoolean
        ]
        
        if let source = CGImageSourceCreateWithURL(url as CFURL, nil),
           let cgImage = CGImageSourceCreateImageAtIndex(source, 0, readOptions as CFDictionary) {
            return cgImage
        }
        
        // 2. Try PDF first page
        if url.pathExtension.lowercased() == "pdf",
           let doc = PDFDocument(url: url),
           let page = doc.page(at: 0) {
            let box = page.bounds(for: .mediaBox)
            let width = Int(box.width * 2) // 2x retina crispness
            let height = Int(box.height * 2)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            if let ctx = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) {
                ctx.scaleBy(x: 2.0, y: 2.0)
                ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
                ctx.fill(box)
                page.draw(with: .mediaBox, to: ctx)
                if let rendered = ctx.makeImage() {
                    return rendered
                }
            }
        }
        
        // 3. Fallback to NSImage representations
        if let nsImage = NSImage(contentsOf: url),
           let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            return cgImage
        }
        
        throw EngineError.cannotReadImageSource
    }
    
    /// Converts an image file to the designated format and location
    public static func convert(
        inputURL: URL,
        targetFormat: ConversionFormat,
        quality: Float = 0.9,
        saveLocationMode: SaveLocationMode,
        customFolderURL: URL?,
        overwriteExisting: Bool = false,
        deleteOriginal: Bool = false
    ) throws -> (outputURL: URL, fileSize: Int64) {
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: inputURL.path) else {
            throw EngineError.fileNotFound
        }
        
        // 1. Determine destination folder
        let destinationDir: URL
        switch saveLocationMode {
        case .sameFolder:
            destinationDir = inputURL.deletingLastPathComponent()
        case .customFolder:
            if let customDir = customFolderURL {
                destinationDir = customDir
            } else {
                destinationDir = inputURL.deletingLastPathComponent()
            }
        }
        
        // Ensure destination directory exists
        try fileManager.createDirectory(at: destinationDir, withIntermediateDirectories: true, attributes: nil)
        
        // 2. Determine target file name and path
        let baseName = inputURL.deletingPathExtension().lastPathComponent
        let targetExt = targetFormat.fileExtension
        var finalURL = destinationDir.appendingPathComponent("\(baseName).\(targetExt)")
        
        // Handle name collisions if not overwriting
        if !overwriteExisting && fileManager.fileExists(atPath: finalURL.path) {
            var counter = 1
            while fileManager.fileExists(atPath: destinationDir.appendingPathComponent("\(baseName) (\(counter)).\(targetExt)").path) {
                counter += 1
            }
            finalURL = destinationDir.appendingPathComponent("\(baseName) (\(counter)).\(targetExt)")
        }
        
        // 3. Load CGImage
        var cgImage = try loadCGImage(from: inputURL)
        
        // Flatten alpha if destination doesn't support transparency
        if targetFormat == .jpeg || targetFormat == .jpg || targetFormat == .bmp {
            if let flattened = flattenAlpha(cgImage: cgImage) {
                cgImage = flattened
            }
        }
        
        // 4. Determine destination write URL
        // If finalURL == inputURL (overwriting same file), use a temporary file first
        let isWritingDirectlyToSameFile = (finalURL.path == inputURL.path)
        let writeURL: URL
        if isWritingDirectlyToSameFile {
            writeURL = destinationDir.appendingPathComponent(".temp_\(UUID().uuidString).\(targetExt)")
        } else {
            writeURL = finalURL
        }
        
        // 5. Write output (Smart WebP encoder for .webp, CGImageDestination for others)
        if targetFormat == .webp {
            do {
                try encodeWebP(cgImage: cgImage, quality: quality, to: writeURL)
            } catch {
                if isWritingDirectlyToSameFile {
                    try? fileManager.removeItem(at: writeURL)
                }
                throw error
            }
        } else {
            guard let destination = CGImageDestinationCreateWithURL(
                writeURL as CFURL,
                targetFormat.utType.identifier as CFString,
                1,
                nil
            ) else {
                throw EngineError.cannotCreateDestination
            }
            
            var options: [CFString: Any] = [:]
            if targetFormat.supportsQuality {
                options[kCGImageDestinationLossyCompressionQuality] = quality as CFNumber
            }
            
            CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
            
            guard CGImageDestinationFinalize(destination) else {
                if isWritingDirectlyToSameFile {
                    try? fileManager.removeItem(at: writeURL)
                }
                throw EngineError.finalizeFailed
            }
        }
        
        // If temporary file was written, replace original atomically
        if isWritingDirectlyToSameFile {
            _ = try fileManager.replaceItemAt(finalURL, withItemAt: writeURL)
        }
        
        // 6. Delete original if requested (and it's a distinct file)
        if deleteOriginal && inputURL.path != finalURL.path {
            try? fileManager.trashItem(at: inputURL, resultingItemURL: nil)
        }
        
        // 7. Get final file size
        let attr = try? fileManager.attributesOfItem(atPath: finalURL.path)
        let size = (attr?[.size] as? NSNumber)?.int64Value ?? 0
        
        return (finalURL, size)
    }
    
    /// Encodes a CGImage into a web-optimized WebP file using libwebp (method 6, multi-pass, Sharp YUV)
    private static func encodeWebP(cgImage: CGImage, quality: Float, to destinationURL: URL) throws {
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = width * 4
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
        
        var pixelData = [UInt8](repeating: 0, count: height * bytesPerRow)
        let drawn: Bool = pixelData.withUnsafeMutableBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress,
                  let ctx = CGContext(
                      data: baseAddress,
                      width: width,
                      height: height,
                      bitsPerComponent: 8,
                      bytesPerRow: bytesPerRow,
                      space: colorSpace,
                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                  ) else {
                return false
            }
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        
        guard drawn else {
            throw EngineError.cannotCreateImage
        }
        
        var outPtr: UnsafeMutablePointer<UInt8>? = nil
        var outSize: Int = 0
        let webpQuality = max(10.0, min(100.0, quality * 100.0))
        
        let ok = pixelData.withUnsafeBufferPointer { bufferPtr -> Int32 in
            guard let base = bufferPtr.baseAddress else { return 0 }
            return AlteEncodeWebP(
                base,
                Int32(width),
                Int32(height),
                Int32(bytesPerRow),
                webpQuality,
                &outPtr,
                &outSize
            )
        }
        
        guard ok != 0, let validPtr = outPtr, outSize > 0 else {
            if let ptr = outPtr {
                AlteFreeWebP(ptr)
            }
            throw EngineError.finalizeFailed
        }
        
        defer {
            AlteFreeWebP(validPtr)
        }
        
        let data = Data(bytes: validPtr, count: outSize)
        do {
            try data.write(to: destinationURL, options: .atomic)
        } catch {
            throw EngineError.finalizeFailed
        }
    }
}
