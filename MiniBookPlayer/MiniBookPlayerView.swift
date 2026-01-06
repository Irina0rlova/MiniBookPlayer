import SwiftUI
import ComposableArchitecture

struct MiniBookPlayerView: View {
    let store: StoreOf<MiniBookPlayerFeature>
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        if let error = store.error {
            ErrorView(message: error) {
                store.send(.loadBook)
            }
        } else {
            MiniBookPlayerViewContent(store: store)
                .onAppear {
                    store.send(.onAppear)
                }
                .onDisappear {
                    store.send(.player(.onDisappear))
                }
                .onChange(of: scenePhase, initial: false) { _, newPhase in
                    switch newPhase {
                    case .background:
                        store.send(.appMovedToBackground)
                        
                    case .active:
                        store.send(.appReturnedToForeground)
                        
                    default:
                        break
                    }
                }
        }
    }
}

struct MiniBookPlayerViewContent: View {
    let store: StoreOf<MiniBookPlayerFeature>
    
    var body: some View {
        if let book = store.book,
           let player = store.player {
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
                    onSeek: { store.send(.player(.seek(to: $0))) }
                )
                SpeedButton(
                    playbackRate: player.playbackRate,
                    onChangeSpeed: { store.send(.player(.changeSpeed)) }
                )
                ControlsView(
                    isPlaying: player.isPlaying,
                    isFirstTrack: player.isFirstKeyPoint,
                    isLastTrack: player.isLastKeyPoint,
                    onPlayPause: { store.send(.player(.playPauseTapped)) },
                    onForward: { store.send(.player(.nextKeyPoint)) },
                    onBackward: { store.send(.player(.previousKeyPoint)) },
                    onSeekBackward: { store.send(.player(.seekBackward)) },
                    onSeekForward: { store.send(.player(.seekForward)) }
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
