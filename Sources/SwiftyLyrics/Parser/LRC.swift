import Foundation
import RegexBuilder
import UniformTypeIdentifiers

extension UTType {
    public static var lrc: UTType {
        .init(importedAs: "public.lrc", conformingTo: .plainText)
    }
}

extension Lyrics.Parser {
    public struct LRC {
        public enum TimeFormat: CaseIterable {
            /// `[mm:ss:xx]`
            case minutesSecondsHundredths
            /// `[mm:ss:xxx]`
            case minutesSecondsMilliseconds
        }

        public let timeFormat: TimeFormat

        private let timePattern = /(\d+)\:(\d+).(\d+)/

        public init(timeFormat: TimeFormat = .minutesSecondsHundredths) {
            self.timeFormat = timeFormat
        }
    }
}

extension Lyrics.Parser.LRC: LyricsParsing {
    public var fileExtension: String { "lrc" }

    public func parse(_ content: String) throws -> Lyrics {
        let lineContents = content
            .trimmingCharacters(in: .bom)
            .lines()

        var lines: [Line] = []

        let tagPattern = Regex {
            "["
            Capture {
                OneOrMore(.anyNonNewline, .reluctant)
            }
            "]"
        }

        let linePattern = Regex {
            tagPattern
            Capture {
                ZeroOrMore(.anyNonNewline)
            }
        }

        for lineContent in lineContents {
            guard let match = try linePattern.wholeMatch(
                in: lineContent.trimmingCharacters(in: .whitespacesAndNewlines)
            ) else { continue }

            let (_, tag, content) = match.output
            let tagString = String(tag)
            let text = content.trimmingCharacters(in: .whitespacesAndNewlines)

            if text.isEmpty {
                if let seconds = try? parse(timestamp: tagString) {
                    lines.append(TextLine(begin: seconds))
                } else {
                    // TODO: tags
                }
            } else {
                let seconds = try parse(timestamp: tagString)
                let line = TextLine(
                    begin: seconds,
                    slices: [
                        .text(text, begin: seconds),
                    ]
                )
                lines.append(line)
            }
        }

        return Lyrics(lines: lines)
    }

    private func parse(timestamp: String) throws -> TimeInterval {
        guard let match = try timePattern.wholeMatch(in: timestamp) else {
            throw LyricsError.invalidTimestamp
        }

        let (_, minutes, seconds, fractionalSeconds) = match.output

        let fraction = switch timeFormat {
        case .minutesSecondsHundredths:
            TimeInterval(fractionalSeconds)! / 100
        case .minutesSecondsMilliseconds:
            TimeInterval(fractionalSeconds)! / 1000
        }

        return TimeInterval(minutes)! * 60 + TimeInterval(seconds)! + fraction
    }
}
