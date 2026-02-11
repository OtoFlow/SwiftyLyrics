import Foundation

public enum TextAlignment {
    case center
    case leading
    case trailing
}

open class LyricTextLabel: PlatformView {

    #if canImport(UIKit)
    open override class var layerClass: AnyClass {
        LyricTextLayer.self
    }

    public var textLayer: LyricTextLayer {
        layer as! LyricTextLayer
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        textLayer.bounds.size = size
        textLayer.layoutNodesIfNeeded()
        return textLayer.textBounds.size
    }
    #else
    public let textLayer = LyricTextLayer()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        wantsLayer = true
        layer?.addSublayer(textLayer)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        wantsLayer = true
        layer?.addSublayer(textLayer)
    }
    
    open func sizeThatFits(_ size: CGSize) -> CGSize {
        textLayer.bounds.size = size
        textLayer.layoutNodesIfNeeded()
        return textLayer.textBounds.size
    }
    #endif
}
