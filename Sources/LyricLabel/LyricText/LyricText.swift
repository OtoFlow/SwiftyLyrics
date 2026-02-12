import SwiftUI
@_exported import SwiftyLyrics

@MainActor
public struct LyricText {

    public enum InteractiveState {
        case pause
        case offset(TimeInterval)
        case resume
    }

    public var line: TextLine

    @Binding private var interactiveState: InteractiveState?

    @Environment(\.lyricTextFont) private var lyricLabelFont

    public init(line: TextLine, interactiveState: Binding<InteractiveState?>) {
        self.line = line
        self._interactiveState = interactiveState
    }

    func updateView(_ view: LyricTextLabel) {
        view.textLayer.textLine = line
        view.textLayer.font = lyricLabelFont ?? .preferredFont(forTextStyle: .body)

        switch interactiveState {
        case .pause:
            view.textLayer.pause()
        case .offset(let offset):
            view.textLayer.update(offset)
        case .resume:
            view.textLayer.resume()
        case nil: ()
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, view: LyricTextLabel) -> CGSize? {
        switch proposal {
        case .zero:
            return .zero
        case .unspecified, .infinity:
            return view.sizeThatFits(.greatestFiniteMagnitude)
        default:
            let size = proposal.replacingUnspecifiedDimensions(by: .greatestFiniteMagnitude)
            return view.sizeThatFits(size)
        }
    }
}

#if canImport(UIKit)
extension LyricText: UIViewRepresentable {

    public func makeUIView(context: Context) -> LyricTextLabel {
        .init()
    }

    public func updateUIView(_ uiView: LyricTextLabel, context: Context) {
        updateView(uiView)
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: LyricTextLabel, context: Context) -> CGSize? {
        sizeThatFits(proposal, view: uiView)
    }
}
#else
extension LyricText: NSViewRepresentable {

    public func makeNSView(context: Context) -> LyricTextLabel {
        .init()
    }

    public func updateNSView(_ nsView: LyricTextLabel, context: Context) {
        updateView(nsView)
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, nsView: LyricTextLabel, context: Context) -> CGSize? {
        sizeThatFits(proposal, view: nsView)
    }
}
#endif
