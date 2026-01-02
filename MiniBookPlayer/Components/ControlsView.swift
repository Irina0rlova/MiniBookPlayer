import SwiftUI

struct ControlsView: View {
    @Binding var isPlaying: Bool
    
    let isFirstTrack: Bool
    let isLastTrack: Bool
    
    let onPlayPause: () -> Void
    let onForward: () -> Void
    let onBackward: () -> Void
    let onSeekBackward: () -> Void
    let onSeekForward: () -> Void
    
    var body: some View {
        HStack(spacing: 28) {
            controlButton(
                systemName: "backward.end.fill",
                action: onBackward,
                isDisabled: isFirstTrack
            )
            
            controlButton(
                systemName: "gobackward.5",
                action: onSeekBackward
            )
            
            playPauseButton
            
            controlButton(
                systemName: "goforward.10",
                action: onSeekForward
            )
            
            controlButton(
                systemName: "forward.end.fill",
                action: onForward,
                isDisabled: isLastTrack
            )
        }
        .padding(.top, 12)
    }
    
    private var playPauseButton: some View {
        Button(action: onPlayPause) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 32, weight: .bold))
        }
        .buttonStyle(.plain)
        .tint(.black)
    }
    
    private func controlButton(
            systemName: String,
            action: @escaping () -> Void,
            isDisabled: Bool = false
        ) -> some View {
            Button(action: action) {
                Image(systemName: systemName)
                    .font(.title2)
                    .opacity(isDisabled ? 0.3 : 1)
            }
            .buttonStyle(.plain)
            .disabled(isDisabled)
        }
}
