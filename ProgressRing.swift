import SwiftUI

struct ProgressRing: View {
    var progress: Double
    var body: some View {
        ZStack {
            Circle().stroke(Color.gray.opacity(0.3), lineWidth: 6)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}
