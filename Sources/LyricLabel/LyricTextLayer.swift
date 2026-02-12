#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

import SwiftyLyrics

public final class LyricTextLayer: CALayer {

    public var alignment: TextAlignment = .leading {
        didSet { setNeedsLayoutNodes() }
    }

    public var font: PlatformFont = .preferredFont(forTextStyle: .body) {
        didSet { setNeedsLayoutNodes() }
    }

    public var textLine: TextLine? {
        didSet { setNeedsLayoutNodes() }
    }

    public var textColor: PlatformColor = .lyricSecondaryLabelColor {
        didSet {

        }
    }

    public override var bounds: CGRect {
        didSet {
            _needsLayoutNodes = true
        }
    }

    public var textBounds: CGRect = .zero {
        didSet {
            if case let view as PlatformView = delegate {
                Task { @MainActor in
                    view.invalidateIntrinsicContentSize()
                }
            }
        }
    }

    private lazy var textContainer: NSTextContainer = {
        let textContainer = NSTextContainer(size: .init(width: bounds.width, height: .zero))
        textContainer.lineFragmentPadding = .zero
        textContainer.maximumNumberOfLines = .zero
        return textContainer
    }()

    private lazy var textStorage: NSTextStorage = {
        let textStorage = NSTextStorage()
        textStorage.addLayoutManager(textLayoutManager)
        return textStorage
    }()

    private lazy var textLayoutManager: NSLayoutManager = {
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        layoutManager.delegate = self
        return layoutManager
    }()

    private var textLayers: [IndexedText: LyricTextNodeLayer] = [:]

    private var _needsLayoutNodes = false

    public override func layoutSublayers() {
        if updateTextContainerSizeIfNeeded() { return }
        layoutNodesIfNeeded()
    }

    public func size(fitting size: CGSize) -> CGSize {
        if textContainer.size != size {
            _needsLayoutNodes = true
            textContainer.size = size
        }
        layoutNodesIfNeeded()
        return textBounds.size
    }

    public func setNeedsLayoutNodes() {
        _needsLayoutNodes = true
        setNeedsLayout()
    }

    public func layoutNodesIfNeeded() {
        guard _needsLayoutNodes else { return }
        _needsLayoutNodes = false

        guard let textLine else { return }

        var text = ""
        var index = 0
        let indexedTextNodes: [IndexedText] = (textLine.slices ?? [])
            .reduce(into: []) { nodes, slice in
                switch slice {
                case let .whitespace(count):
                    text += String(repeating: " ", count: count)
                    index += count
                case let .text(node):
                    text += node.text
                    nodes.append(IndexedText(node, index: index))
                    index += node.length
                }
            }

        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: textColor,
            ]
        )
        textStorage.setAttributedString(attributedText)

        let boundingRect = textLayoutManager.boundingRect(
            forGlyphRange: .init(text.startIndex..., in: text),
            in: textContainer
        )
        textBounds = boundingRect.integral

        for node in indexedTextNodes {
            let range = NSRange(location: node.index, length: node.length)
            let anchorX: CGFloat = switch alignment {
            case .leading: .zero
            case .center: boundingRect.midX
            case .trailing: boundingRect.maxX
            }
            let boundingRect = textLayoutManager.boundingRect(
                forGlyphRange: range,
                in: textContainer
            ).offsetBy(dx: -anchorX, dy: .zero)
            let (layer, _) = findOrCreateLayer(node, frame: boundingRect)
            addSublayer(layer)
            layer.setNeedsDisplay()
        }
    }

    public func updateTextContainerSizeIfNeeded() -> Bool {
        if textContainer.size.width != bounds.width {
            textContainer.size = .init(width: bounds.width, height: .zero)
            setNeedsLayout()
            return true
        }
        return false
    }

    private func findOrCreateLayer(_ text: IndexedText, frame: CGRect) -> (LyricTextNodeLayer, Bool) {
        if let layer = textLayers[text] {
            layer.frame = frame
            return (layer, false)
        }
        let layer = LyricTextNodeLayer(text)
        layer.delegate = self
        textLayers[text] = layer
        layer.frame = frame
        layer.setProgress(duration: 2.0, color: .lyricLabelColor, animated: true)
        return (layer, true)
    }

    func pause() {
        textLayers.values.forEach { $0.pause() }
    }

    func update(_ offset: TimeInterval) {
        textLayers.values.forEach { $0.update(offset) }
    }

    func resume() {
        textLayers.values.forEach { $0.resume() }
    }
}

// MARK: - CALayerDelegate

extension LyricTextLayer: CALayerDelegate {

    public func action(for layer: CALayer, forKey event: String) -> (any CAAction)? {
        NSNull()
    }

    public func draw(_ layer: CALayer, in ctx: CGContext) {
        guard let layer = layer as? LyricTextNodeLayer else { return }

        ctx.saveGState()
        ctx.setAllowsAntialiasing(true)
        ctx.setShouldAntialias(true)
        ctx.setShouldSubpixelPositionFonts(true)
        ctx.setShouldSubpixelQuantizeFonts(false)
        ctx.setAllowsFontSmoothing(true)
        ctx.setShouldSmoothFonts(true)

        #if canImport(UIKit)
        UIGraphicsPushContext(ctx)
        #else
        ctx.translateBy(x: 0, y: layer.bounds.height)
        ctx.scaleBy(x: 1, y: -1)
        let nsContext = NSGraphicsContext(cgContext: ctx, flipped: true)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = nsContext
        #endif

        let range = NSRange(location: layer.text.index, length: layer.text.length)
        let frame = layer.frame
        textLayoutManager.drawGlyphs(forGlyphRange: range, at: .init(x: -frame.minX, y: -frame.minY))

        #if canImport(UIKit)
        UIGraphicsPopContext()
        #else
        NSGraphicsContext.restoreGraphicsState()
        #endif

        ctx.restoreGState()

        #if canImport(UIKit)
        let bounds = CGRect(origin: .zero, size: layer.bounds.size)
        let imageRenderer = UIGraphicsImageRenderer(bounds: bounds)
        let image = imageRenderer.image { context in
            textLayoutManager.drawGlyphs(forGlyphRange: range, at: .init(x: -frame.minX, y: -frame.minY))
        }
        layer.maskLayer.frame = bounds
        layer.maskLayer.contents = image.cgImage
        layer.progressLayer.frame = .init(origin: .zero, size: .init(width: .zero, height: bounds.height))
        #endif
    }
}

// MARK: - NSLayoutManagerDelegate

extension LyricTextLayer: NSLayoutManagerDelegate {

}
