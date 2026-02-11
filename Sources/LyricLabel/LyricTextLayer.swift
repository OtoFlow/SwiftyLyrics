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

    public var textColor: PlatformColor = .lyricLabelColor {
        didSet {

        }
    }

    public override var bounds: CGRect {
        didSet {

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

    public func setNeedsLayoutNodes() {
        _needsLayoutNodes = true
        setNeedsLayout()
    }

    public func layoutNodesIfNeeded() {
        guard _needsLayoutNodes else { return }
        _needsLayoutNodes = false

        backgroundColor = PlatformColor.black.cgColor

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
            let (layer, _) = findOrCreateLayer(node)
            layer.frame = boundingRect
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

    private func findOrCreateLayer(_ text: IndexedText) -> (LyricTextNodeLayer, Bool) {
        if let layer = textLayers[text] {
            return (layer, false)
        }
        let layer = LyricTextNodeLayer(text)
        layer.delegate = self
        textLayers[text] = layer
        return (layer, true)
    }
}

extension LyricTextLayer: CALayerDelegate {

    public func draw(_ layer: CALayer, in ctx: CGContext) {
        guard let layer = layer as? LyricTextNodeLayer else { return }

        ctx.saveGState()
        ctx.setAllowsAntialiasing(true)
        ctx.setShouldAntialias(true)
        ctx.setAllowsFontSmoothing(true)
        ctx.setShouldSmoothFonts(true)

        #if canImport(UIKit)
        UIGraphicsPushContext(ctx)

        let range = NSRange(location: layer.text.index, length: layer.text.length)
        let origin = layer.frame.origin
        textLayoutManager.drawGlyphs(forGlyphRange: range, at: .init(x: -origin.x, y: -origin.y))

        UIGraphicsPopContext()

        ctx.restoreGState()

        let bounds = CGRect(origin: .zero, size: layer.bounds.size)
        let imageRenderer = UIGraphicsImageRenderer(bounds: bounds)
        let image = imageRenderer.image { context in
            textLayoutManager.drawGlyphs(forGlyphRange: range, at: .init(x: -origin.x, y: -origin.y))
        }
        layer.maskLayer.frame = bounds
        layer.maskLayer.contents = image.cgImage
        layer.progressLayer.frame = .init(origin: .zero, size: .init(width: .zero, height: bounds.height))
        layer.setProgress(duration: 2.0, color: .lyricLabelColor, animated: true)
        #endif
    }
}

// MARK: - NSLayoutManagerDelegate

extension LyricTextLayer: NSLayoutManagerDelegate {

}
