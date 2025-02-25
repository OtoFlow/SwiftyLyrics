import Foundation

public enum TextLineSlice {
    case whitespace(Int)
    case text(TextNode)

    public static var whitespace: TextLineSlice { .whitespace(1) }

    public static func text(
        begin: TimeInterval? = nil,
        end: TimeInterval? = nil,
        text: String
    ) -> TextLineSlice {
        .text(TextNode(begin: begin, end: end, text: text))
    }
}
