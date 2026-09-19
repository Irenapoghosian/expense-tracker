import SwiftUI
import UIKit

/// A thin SwiftUI wrapper around UIActivityViewController, used to present
/// the native iOS share sheet (e.g. for sharing an exported CSV file).
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed.
    }
}
