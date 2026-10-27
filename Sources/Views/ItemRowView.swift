import SwiftUI

public struct ItemRowView: View {
    let item: ConversionItem
    let targetFormat: ConversionFormat
    let strings: L10nStrings
    let onConvert: () -> Void
    let onRemove: () -> Void
    let onReveal: (URL) -> Void
    
    public init(
        item: ConversionItem,
        targetFormat: ConversionFormat,
        strings: L10nStrings = L10n.current,
        onConvert: @escaping () -> Void,
        onRemove: @escaping () -> Void,
        onReveal: @escaping (URL) -> Void
    ) {
        self.item = item
        self.targetFormat = targetFormat
        self.strings = strings
        self.onConvert = onConvert
        self.onRemove = onRemove
        self.onReveal = onReveal
    }
    
    private var projectedOutputName: String {
        if let out = item.outputURL {
            return out.lastPathComponent
        }
        let base = item.inputURL.deletingPathExtension().lastPathComponent
        return "\(base).\(targetFormat.fileExtension)"
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            Group {
                if let thumb = item.thumbnail {
                    Image(nsImage: thumb)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.15))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        )
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
            
            // File Details
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(item.inputFileName)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                    
                    Text(item.inputExtension)
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.18))
                        .cornerRadius(4)
                }
                
                HStack(spacing: 6) {
                    Text(item.formattedOriginalSize)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Text(projectedOutputName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(item.status.isSuccess ? .primary : .secondary)
                        .lineLimit(1)
                    
                    if let convertedSize = item.formattedConvertedSize {
                        Text("(\(convertedSize))")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            // Status and Actions
            HStack(spacing: 12) {
                switch item.status {
                case .pending:
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        Text(strings.statusPending)
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.secondary)
                    
                    Button(action: onConvert) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                    .help(strings.convertSingleHelp)
                    
                case .converting:
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.small)
                        Text(strings.statusConverting)
                            .font(.system(size: 11))
                            .foregroundColor(.accentColor)
                    }
                    
                case .success:
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.green)
                        Text(strings.statusCompleted)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.green)
                    }
                    
                    if let outURL = item.outputURL {
                        Button {
                            onReveal(outURL)
                        } label: {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .font(.system(size: 17))
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(.plain)
                        .help(strings.revealInFinderHelp)
                    }
                    
                case .failed(let msg):
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                        Text(strings.statusFailed)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.red)
                    }
                    .help(msg)
                    
                    Button(action: onConvert) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.orange)
                    }
                    .buttonStyle(.plain)
                    .help(strings.retryHelp(msg))
                }
                
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .buttonStyle(.plain)
                .help(strings.removeFromListHelp)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.6))
        .cornerRadius(8)
    }
}

