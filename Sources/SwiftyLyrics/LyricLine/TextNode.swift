import Foundation

public struct TextNode: Hashable {
    public var begin: TimeInterval?
    public var end: TimeInterval?
    public let text: String

    public init(
        begin: TimeInterval?,
        end: TimeInterval?,
        text: String
    ) {
        self.begin = begin
        self.end = end
        self.text = text
    }
}

extension TextNode {
    public var length: Int { text.count }
}
