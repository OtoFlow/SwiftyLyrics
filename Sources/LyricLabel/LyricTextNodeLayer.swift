#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

final class LyricTextNodeLayer: CALayer {

    lazy var progressLayer: CALayer = {
        let layer = CALayer()
        layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        layer.mask = maskLayer
        addSublayer(layer)
        return layer
    }()

    lazy var maskLayer: CALayer = .init()

    var text: IndexedText!

    private var animationBeginTime: TimeInterval = .zero

    init(_ text: IndexedText) {
        self.text = text

        super.init()

        #if canImport(UIKit)
        contentsScale = max(UITraitCollection.current.displayScale, 2.0)
        #else
        contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
        #endif

        setNeedsDisplay()
    }

    override init(layer: Any) {
        super.init(layer: layer)

        guard let layer = layer as? LyricTextNodeLayer else { return }

        self.text = layer.text
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setProgress(
        duration: TimeInterval,
        color: PlatformColor,
        animated: Bool
    ) {
        progressLayer.backgroundColor = color.cgColor

        guard let end = text.end else { return }

        animationBeginTime = CACurrentMediaTime() + text.begin

        if animated {
            let animation = CAKeyframeAnimation(keyPath: "bounds.size.width")
            animation.duration = end - text.begin
            animation.values = [0, bounds.width]
            animation.keyTimes = [0, 1]
            animation.beginTime = animationBeginTime
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false

            progressLayer.add(animation, forKey: "progressAnimation")
        } else {
            progressLayer.bounds.size.width = bounds.width
        }

        let animation = CAKeyframeAnimation(keyPath: "position.y")
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.duration = end - text.begin
        animation.values = [0, -1]
        animation.keyTimes = [0, 1]
        animation.beginTime = animationBeginTime
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.isAdditive = true
        add(animation, forKey: "translationAnimation")
    }
}

// MARK: - Interactive

extension LyricTextNodeLayer {

    func pause() {
        let pausedTime = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0.0
        timeOffset = pausedTime
    }

    func update(_ offset: TimeInterval) {
        if let end = text.end, offset > end {
            timeOffset = animationBeginTime + (end - text.begin)
        } else {
            timeOffset = animationBeginTime + (offset - text.begin)
        }
    }

    func resume() {
        let pausedTime = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        let timeSincePause = convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        beginTime = timeSincePause
    }
}
