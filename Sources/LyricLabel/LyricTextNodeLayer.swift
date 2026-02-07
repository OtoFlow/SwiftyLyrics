#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

open class LyricTextNodeLayer: CALayer {

    lazy var progressLayer: CALayer = {
        let layer = CALayer()
        layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        layer.mask = maskLayer
        addSublayer(layer)
        return layer
    }()

    lazy var maskLayer: CALayer = .init()

    public var text: IndexedText

    public init(_ text: IndexedText) {
        self.text = text

        super.init()

        #if canImport(UIKit)
        contentsScale = max(UITraitCollection.current.displayScale, 2.0)
        #endif

        setNeedsDisplay()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func setProgress(
        duration: TimeInterval,
        color: PlatformColor,
        animated: Bool
    ) {
        progressLayer.backgroundColor = color.cgColor

        guard let end = text.end else { return }

        if animated {
            let animation = CAKeyframeAnimation(keyPath: "bounds.size.width")
            animation.duration = end - text.begin
            animation.values = [0, bounds.width]
            animation.keyTimes = [0, 1]
            animation.beginTime = CACurrentMediaTime() + text.begin
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false

            progressLayer.add(animation, forKey: "progressAnimation")
        } else {
            progressLayer.bounds.size.width = bounds.width
        }


        let animation = CAKeyframeAnimation(keyPath: "position.y")
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.duration = end - text.begin + 0.2
        animation.values = [0, -1]
        animation.keyTimes = [0, 1]
        animation.beginTime = CACurrentMediaTime() + text.begin
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.isAdditive = true
        add(animation, forKey: "translationAnimation")
    }
}
