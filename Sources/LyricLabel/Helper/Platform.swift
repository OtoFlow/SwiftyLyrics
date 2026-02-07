#if canImport(UIKit)

import UIKit

public typealias PlatformView = UIView
public typealias PlatformFont = UIFont
public typealias PlatformColor = UIColor

extension PlatformColor {

    @inlinable
    static var lyricLabelColor: PlatformColor { .label }

    @inlinable
    static var lyricSecondaryLabelColor: PlatformColor { .secondaryLabel }
}

#else

import AppKit

public typealias PlatformView = NSView
public typealias PlatformFont = NSFont
public typealias PlatformColor = NSColor

extension PlatformColor {

    @inlinable
    static var lyricLabelColor: PlatformColor { .labelColor }

    @inlinable
    static var lyricSecondaryLabelColor: PlatformColor { .secondaryLabelColor }
}

#endif

extension CGSize {

    @inlinable
    static var greatestFiniteMagnitude: CGSize {
        .init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    }
}
