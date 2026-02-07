import Foundation

public struct TextNode: Text, Hashable {

    public let begin: TimeInterval

    public var end: TimeInterval?

    public let text: String

    package init(
        begin: TimeInterval,
        end: TimeInterval? = nil,
        text: String
    ) {
        self.begin = begin
        self.end = end
        self.text = text
    }
}
