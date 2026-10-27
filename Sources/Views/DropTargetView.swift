import SwiftUI
import AppKit

public struct DropTargetOverlay: NSViewRepresentable {
    public var onDropURLs: ([URL]) -> Void
    public var onTargetStateChanged: (Bool) -> Void
    
    public init(onDropURLs: @escaping ([URL]) -> Void, onTargetStateChanged: @escaping (Bool) -> Void) {
        self.onDropURLs = onDropURLs
        self.onTargetStateChanged = onTargetStateChanged
    }
    
    public func makeNSView(context: Context) -> DropNSView {
        let view = DropNSView()
        view.onDropURLs = onDropURLs
        view.onTargetStateChanged = onTargetStateChanged
        return view
    }
    
    public func updateNSView(_ nsView: DropNSView, context: Context) {
        nsView.onDropURLs = onDropURLs
        nsView.onTargetStateChanged = onTargetStateChanged
    }
    
    public class DropNSView: NSView {
        var onDropURLs: (([URL]) -> Void)?
        var onTargetStateChanged: ((Bool) -> Void)?
        
        public override init(frame: NSRect) {
            super.init(frame: frame)
            registerForDraggedTypes([.fileURL])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
            let pasteboard = sender.draggingPasteboard
            if pasteboard.canReadObject(forClasses: [NSURL.self], options: nil) {
                onTargetStateChanged?(true)
                return .copy
            }
            return []
        }
        
        public override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
            return .copy
        }
        
        public override func draggingExited(_ sender: NSDraggingInfo?) {
            onTargetStateChanged?(false)
        }
        
        public override func draggingEnded(_ sender: NSDraggingInfo) {
            onTargetStateChanged?(false)
        }
        
        public override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
            onTargetStateChanged?(false)
            let pasteboard = sender.draggingPasteboard
            guard let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], !urls.isEmpty else {
                return false
            }
            onDropURLs?(urls)
            return true
        }
    }
}

