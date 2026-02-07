import SwiftUI

@MainActor
public struct LyricText {

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

#if os(iOS)

extension LyricText: UIViewRepresentable {

    public func makeUIView(context: Context) -> LyricTextLabel {
        .init()
    }

    public func updateUIView(_ uiView: LyricTextLabel, context: Context) {

    }

    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: LyricTextLabel, context: Context) -> CGSize? {
        sizeThatFits(proposal, view: uiView)
    }
}

#endif
