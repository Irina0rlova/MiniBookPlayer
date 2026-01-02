import SwiftUI

struct SpeedButton: View {
    let playbackRate: Float
    let onChangeSpeed: () -> Void
    
    var body: some View {
        Button(action: onChangeSpeed) {
            Text("Speed x\(formattedRate)")
                .font(.footnote)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(.secondarySystemBackground))
                )
                .contentTransition(.numericText())
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.2), value: playbackRate)
    }
    
    private var formattedRate: String {
        playbackRate.formatted(
            .number.precision(.fractionLength(0...2))
            .locale(Locale(identifier: "en_US_POSIX"))
        )
    }
}
