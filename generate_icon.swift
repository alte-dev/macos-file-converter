import AppKit
import UniformTypeIdentifiers

func createIcon() {
    let sizes: [CGFloat] = [16, 32, 64, 128, 256, 512, 1024]
    let iconData = NSMutableData()
    guard let dest = CGImageDestinationCreateWithData(iconData as CFMutableData, UTType.icns.identifier as CFString, sizes.count, nil) else {
        print("Error: Cannot create icns destination")
        exit(1)
    }

    for s in sizes {
        let size = CGSize(width: s, height: s)
        let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(s),
            pixelsHigh: Int(s),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )!
        
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        
        let rect = CGRect(origin: .zero, size: size)
        
        // Base squircle background
        let inset = s * 0.1
        let corner = s * 0.22
        let iconBounds = rect.insetBy(dx: inset, dy: inset)
        let path = NSBezierPath(roundedRect: iconBounds, xRadius: corner, yRadius: corner)
        
        // Gradient: Deep Royal Blue to Electric Indigo
        let gradient = NSGradient(
            colors: [
                NSColor(red: 0.12, green: 0.42, blue: 0.95, alpha: 1.0),
                NSColor(red: 0.38, green: 0.15, blue: 0.88, alpha: 1.0)
            ]
        )
        gradient?.draw(in: path, angle: -45)
        
        // Subtle inner border glow
        NSColor.white.withAlphaComponent(0.2).setStroke()
        path.lineWidth = max(1.0, s * 0.015)
        path.stroke()
        
        // Central Graphic: SF Symbol or custom graphics
        // Central Graphic: SF Symbol in crisp white
        let config = NSImage.SymbolConfiguration(pointSize: s * 0.42, weight: .semibold)
            .applying(NSImage.SymbolConfiguration(paletteColors: [.white]))
        if let symbol = NSImage(systemSymbolName: "arrow.triangle.2.circlepath.doc.on.clipboard", accessibilityDescription: nil)?.withSymbolConfiguration(config) {
            
            let symbolSize = symbol.size
            let symbolRect = CGRect(
                x: (s - symbolSize.width) / 2.0,
                y: (s - symbolSize.height) / 2.0,
                width: symbolSize.width,
                height: symbolSize.height
            )
            
            // Draw drop shadow for symbol
            let shadow = NSShadow()
            shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
            shadow.shadowOffset = NSSize(width: 0, height: -s * 0.02)
            shadow.shadowBlurRadius = s * 0.04
            shadow.set()
            
            symbol.draw(in: symbolRect, from: .zero, operation: .sourceOver, fraction: 1.0)
        }
        
        NSGraphicsContext.restoreGraphicsState()
        
        if let cg = rep.cgImage {
            CGImageDestinationAddImage(dest, cg, nil)
        }
    }

    if CGImageDestinationFinalize(dest) {
        let outputURL = URL(fileURLWithPath: "AppIcon.icns")
        try? (iconData as Data).write(to: outputURL)
        print("Generated AppIcon.icns (\(iconData.length) bytes)")
    }
}

createIcon()
