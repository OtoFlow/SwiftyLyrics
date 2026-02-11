import Foundation

public struct TextLine: Line {

    public var begin: TimeInterval?

    public var end: TimeInterval?

    public var slices: [Slice]?

    public init(
        begin: TimeInterval? = nil,
        end: TimeInterval? = nil,
        slices: [Slice]? = nil
    ) {
        self.begin = begin
        self.end = end
        self.slices = slices
    }
}

extension TextLine {

    public enum Slice {

        case whitespace(_ count: Int)

        case text(any Text)

        public static var whitespace: Slice { .whitespace(1) }

        public static func text(
            _ text: String,
            begin: TimeInterval,
            end: TimeInterval? = nil
        ) -> Slice {
            .text(TextNode(begin: begin, end: end, text: text))
        }
    }
}
