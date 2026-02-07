import Foundation
import SwiftyLyrics

public struct IndexedText: Text, Hashable {

    private let base: any Text

    public let index: Int

    public var begin: TimeInterval {
        base.begin
    }

    public var end: TimeInterval? {
        base.end
    }

    public var text: String {
        base.text
    }

    public init(_ base: any Text, index: Int) {
        self.base = base
        self.index = index
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.index == rhs.index
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
}
