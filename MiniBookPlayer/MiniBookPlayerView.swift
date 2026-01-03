import SwiftUI
import ComposableArchitecture

struct MiniBookPlayerView: View {
    let store: StoreOf<MiniBookPlayerFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            content(viewStore)
                .onAppear {
                    viewStore.send(.onAppear)
                }
        }
    }
}

private extension MiniBookPlayerView {
    func content(_ viewStore: ViewStore<MiniBookPlayerFeature.State, MiniBookPlayerFeature.Action>) -> some View {
        Group {
            if let book = viewStore.book,
               let player = viewStore.player {
                VStack(spacing: 18) {
                    BookCoverView(url: book.coverImageURL)
                    
                    if !book.keyPoints.isEmpty {
                        KeyPointView(
                            keyPointIndex: player.currentKeyPointIndex + 1,
                            keyPointTotal: book.keyPoints.count,
                            keyPointText: book.keyPoints[player.currentKeyPointIndex].title
                        )
                    } else {
                        Spacer()
                    }
                    ProgressAudioView(
                        currentTime: player.currentTime,
                        duration: player.duration ?? 0,
                        onSeek: { viewStore.send(.player(.seek(to: $0))) }
                    )
                    SpeedButton(
                        playbackRate: player.playbackRate,
                        onChangeSpeed: { viewStore.send(.player(.changeSpeed)) }
                    )
                    ControlsView(
                        isPlaying: player.isPlaying,
                        isFirstTrack: player.isFirstKeyPoint,
                        isLastTrack: player.isLastKeyPoint,
                        onPlayPause: { viewStore.send(.player(.playPauseTapped)) },
                        onForward: { viewStore.send(.player(.nextKeyPoint)) },
                        onBackward: { viewStore.send(.player(.previousKeyPoint)) },
                        onSeekBackward: { viewStore.send(.player(.seekBackward)) },
                        onSeekForward: { viewStore.send(.player(.seekForward)) }
                    )
                    Spacer()
                    BottomToggleView()
                }
                .padding(.horizontal, 24)
                .background(Color(.systemBackground))
            } else {
                ProgressView()
            }
        }
    }
}

#Preview {
    MiniBookPlayerView(
        store: Store(
            initialState: MiniBookPlayerFeature.State(),
            reducer: {
                MiniBookPlayerFeature()
            }
        )
    )
}
