import SwiftUI
import LyricLabel

struct ContentView: View {

    @State var line: TextLine = TextLine(
        begin: 3.490,
        end: 5.848,
        slices: [
            .text(TextNode(begin: 3.490, end: 3.553, text: "I")),
            .whitespace,
            .text(TextNode(begin: 3.553, end: 3.722, text: "know")),
            .whitespace,
            .text(TextNode(begin: 3.722, end: 3.904, text: "that")),
            .whitespace,
            .text(TextNode(begin: 3.904, end: 4.072, text: "I'm")),
            .whitespace,
            .text(TextNode(begin: 4.072, end: 4.239, text: "a")),
            .whitespace,
            .text(TextNode(begin: 4.239, end: 4.521, text: "hand")),
            .text(TextNode(begin: 4.521, end: 4.869, text: "ful")),
            .whitespace,
            .text(TextNode(begin: 4.869, end: 5.206, text: "ba")),
            .text(TextNode(begin: 5.206, end: 5.558, text: "by")),
            .whitespace,
            .text(TextNode(begin: 5.558, end: 5.848, text: "uh")),
        ]
    )

    var body: some View {
        LyricText(line: line)
            .lyricTextFont(.preferredFont(forTextStyle: .largeTitle))
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ContentView()
}
