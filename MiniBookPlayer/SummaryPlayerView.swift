import SwiftUI

struct SummaryPlayerView: View {
    let book: Book = Book(id: "", title: "Book", author: "Author", coverImageURL: URL(string: "https://picsum.photos/400"), keyPoints: [])
    
    let currentTime: Double = 20
    let duration: Double = 100
    let playbackRate: Float = 1.0
    @State var isPlaying = false

    let onSeek: (Double) -> Void = { _ in }
    let onPlayPause: () -> Void = {}
    let onForward: () -> Void = {}
    let onBackward: () -> Void = {}
    let onChangeSpeed: () -> Void = {}
    let onSeekBackward: () -> Void = {}
    let onSeekForward: () -> Void = {}

    var body: some View {
        VStack(spacing: 18) {
            BookCoverView(url: book.coverImageURL)
            KeyPointView(
                keyPointIndex: 1,
                keyPointTotal: 5,
                keyPointText: "Very very very very very very very long Text"
            )
            ProgressAudioView(
                currentTime: currentTime,
                duration: duration,
                onSeek: onSeek
            )
            SpeedButton(playbackRate: playbackRate, onChangeSpeed: onChangeSpeed)
            ControlsView(
                isPlaying: $isPlaying,
                isFirstTrack: true,
                isLastTrack: false,
                onPlayPause: onPlayPause,
                onForward: onForward,
                onBackward: onBackward,
                onSeekBackward: onSeekBackward,
                onSeekForward: onSeekForward
            )
            Spacer()
            BottomToggleView()
        }
        .padding(.horizontal, 24)
        .background(Color(.systemBackground))
    }
}

#Preview {
    SummaryPlayerView()
}
