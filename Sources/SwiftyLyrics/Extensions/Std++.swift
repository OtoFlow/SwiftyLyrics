import Foundation

extension String {
    func lines() -> [String] {
        var lines: [String] = []
        self.enumerateLines { line, _ in
            lines.append(line)
        }
        return lines
    }
}

extension CharacterSet {
    static var bom: CharacterSet {
        .init(charactersIn: "\u{feff}")
    }

    static var objectReplacement: CharacterSet {
        .init(charactersIn: "\u{fffc}")
    }
}
