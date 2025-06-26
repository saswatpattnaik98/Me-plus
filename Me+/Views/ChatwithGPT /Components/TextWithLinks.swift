import SwiftUI
import SafariServices

struct TextWithLinks: View {
    let text: String
    @State private var urlToOpen: IdentifiableURL?

    var body: some View {
        let attributed = AttributedStringParser.parse(text)

        Text(attributed)
            .font(.system(size: 16))
            .foregroundColor(.primary)
            .onOpenURL { url in
                urlToOpen = IdentifiableURL(url: url)
            }
            .sheet(item: $urlToOpen) { identifiableURL in
                SafariView(url: identifiableURL.url)
            }
    }
}

// ✅ Wrapper for Identifiable conformance
struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

// ✅ Safari View
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
