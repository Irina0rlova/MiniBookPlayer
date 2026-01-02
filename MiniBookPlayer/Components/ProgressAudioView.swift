import SwiftUI

struct ProgressAudioView: View {
    let currentTime: Double
    let duration: Double
    let onSeek: (Double) -> Void
    
    var body: some View {
        HStack {
            Text(timeString(currentTime))
            Slider(
                value: Binding(
                    get: { currentTime },
                    set: { onSeek($0) }
                ),
                in: 0...max(duration, 1)
            )
            .tint(.blue)
            Text(timeString(duration))
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    
    private func timeString(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
