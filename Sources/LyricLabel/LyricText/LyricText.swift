import SwiftUI
@_exported import SwiftyLyrics

@MainActor
public struct LyricText {

    public var line: TextLine

    @Environment(\.lyricTextFont) private var lyricLabelFont

    public init(line: TextLine) {
        self.line = line
    }

    func updateView(_ view: LyricTextLabel) {
        view.textLayer.textLine = line
        view.textLayer.font = lyricLabelFont ?? .preferredFont(forTextStyle: .body)
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
