import Foundation

public protocol LyricsParsing {

    var fileExtension: String { get }

    func parse(_ content: String) throws -> Lyrics
}

extension LyricsParsing {

    public func parse(_ url: URL, encoding: String.Encoding) throws -> Lyrics {
        guard url.pathExtension.lowercased() == fileExtension else {
            throw LyricsError.unsupportedFileExtension
        }
        return try parse(String(contentsOf: url, encoding: encoding))
    }
}
