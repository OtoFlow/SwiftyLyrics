import Foundation

public struct TextLine: Line {
    public var begin: TimeInterval?
    public var end: TimeInterval?
    public var slices: [TextLineSlice]
}
