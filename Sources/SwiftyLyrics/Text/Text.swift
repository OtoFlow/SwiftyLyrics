import Foundation
import QuartzCore

public protocol Text: Sendable {

    var begin: TimeInterval { get }

    var end: TimeInterval? { get }

    var text: String { get }
}

extension Text {

    package var length: Int {
        text.count
    }

    package var isWord: Bool {
        text.allSatisfy(\.isLetter)
    }
}
