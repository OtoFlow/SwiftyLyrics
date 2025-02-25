import Foundation
import Testing
@testable import SwiftyLyrics

struct LRCTests {
    @Test func example() async throws {
        let fileUrl = Bundle.module.url(forResource: "回留 - 方大同", withExtension: "lrc")!
        let lyrics = try Lyrics.Parser.LRC().parse(fileUrl, encoding: .utf8)
        #expect(lyrics.lines.count == 34)
        #expect(lyrics.lines.last?.begin == 213.5)
    }
}
