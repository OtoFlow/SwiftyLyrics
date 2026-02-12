import SwiftUI
import SwiftyLyrics

#if os(macOS) && compiler(>=6)
extension PlatformFont: @retroactive @unchecked Sendable { }
#endif

struct LyricTextFont: EnvironmentKey {
    static let defaultValue: PlatformFont? = nil
}

extension EnvironmentValues {
    var lyricTextFont: PlatformFont? {
        get { self[LyricTextFont.self] }
        set { self[LyricTextFont.self] = newValue }
    }
}

extension View {
    public func lyricTextFont(_ font: PlatformFont?) -> some View {
        environment(\.lyricTextFont, font)
    }
}
