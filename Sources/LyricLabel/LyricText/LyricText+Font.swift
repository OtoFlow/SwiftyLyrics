import SwiftUI
import SwiftyLyrics

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
