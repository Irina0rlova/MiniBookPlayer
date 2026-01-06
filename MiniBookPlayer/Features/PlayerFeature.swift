import ComposableArchitecture
import Foundation

struct PlayerFeature: Reducer {
    @Dependency(\.audioPlayer) var audioPlayer

    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.Effect<Action> {
        switch action {
        case .loadCurrentTrack:
            let keyPoint = state.book.keyPoints[state.currentKeyPointIndex]
            let shouldAutoPlay = state.isPlaying

            return .run { send in
                do {
                    let duration = try await audioPlayer.load(keyPoint.audioSource)
                    await send(.durationLoaded(duration))
                    await send(.setRate)
                    
                    if shouldAutoPlay {
                        await audioPlayer.play()
                    }
                } catch {
                    await send(.failedToLoadCurrentTrack(error.localizedDescription))
                }
            }
            
        case let .audioEvent(event):
            switch event {
            case let .playbackTimeUpdated(time):
                state.currentTime = time
                return .none
                
            case .playbackEnded:
                return .send(.playbackEnded)
            }
            
        case .failedToLoadCurrentTrack(_):
            return .none
            
        case .startListening:
            return .run { send in
                for await event in await audioPlayer.events() {
                    await send(.audioEvent(event))
                }
            }
            .cancellable(id: CancelId.startListening, cancelInFlight: true)
            
        case .playPauseTapped:
            state.isPlaying.toggle()
            let isPlaying = state.isPlaying

            return .run { _ in
                if isPlaying {
                    await audioPlayer.play()
                } else {
                    await audioPlayer.pause()
                }
            }
            
        case .nextKeyPoint:
            guard state.currentKeyPointIndex < state.book.keyPoints.count - 1 else {
                return .none
            }
            state.currentKeyPointIndex += 1
            state.currentTime = 0
            state.duration = nil
            return .send(.loadCurrentTrack)
            
        case .previousKeyPoint:
            guard state.currentKeyPointIndex > 0 else {
                return .none
            }
            state.currentKeyPointIndex -= 1
            state.currentTime = 0
            state.duration = nil
            return .send(.loadCurrentTrack)
            
        case let .seek(to: time):
            state.currentTime = max(0, time)
            return .run { _ in
                await audioPlayer.seek(time)
            }
            
        case .seekForward:
            state.currentTime = min(state.duration ?? 0, state.currentTime + 10)
            let time = state.currentTime
            return .run { _ in
                await audioPlayer.seek(time)
            }
            
        case .seekBackward:
            state.currentTime = max(0, state.currentTime - 5)
            let time = state.currentTime
            return .run { _ in
                await audioPlayer.seek(time)
            }
            
        case let .durationLoaded(duration):
            state.duration = duration
            return .none
            
        case let .playbackTimeUpdated(time):
            state.currentTime = time
            return .none
            
        case .playbackEnded:
            if state.currentKeyPointIndex < state.book.keyPoints.count - 1 {
                state.currentKeyPointIndex += 1
                state.currentTime = 0
                state.duration = nil
                state.isPlaying = true
                return .send(.loadCurrentTrack)
            } else {
                state.isPlaying = false
            }
            return .none
            
        case .changeSpeed:
            let speeds: [Float] = [0.75, 1.0, 1.25, 1.5]
            let index = speeds.firstIndex(of: state.playbackRate) ?? 1
            state.playbackRate = speeds[(index + 1) % speeds.count]
            return .send(.setRate)
            
        case .setRate:
            let playbackRate = state.playbackRate
            return .run { _ in
                await audioPlayer.setRate(playbackRate)
            }
            
        case .onDisappear:
            return .cancel(id: CancelId.startListening)
        }
    }
    
    struct State: Equatable {
        let book: Book
        
        var currentKeyPointIndex: Int
        var isPlaying: Bool
        var currentTime: TimeInterval
        var duration: TimeInterval?
        var playbackRate: Float
        var isFirstKeyPoint: Bool { currentKeyPointIndex == 0 }
        var isLastKeyPoint: Bool { currentKeyPointIndex == book.keyPoints.count - 1 }
    }
    
    enum Action: Equatable {
        // Loading audio
        case loadCurrentTrack
        case audioEvent(AudioPlayerService.Event)
        case failedToLoadCurrentTrack(String)
        case startListening
        
        // UI
        case playPauseTapped
        case nextKeyPoint
        case previousKeyPoint
        case seek(to: TimeInterval)
        case seekForward
        case seekBackward
        case changeSpeed
        case setRate
        
        // Player feedback
        case playbackTimeUpdated(TimeInterval)
        case durationLoaded(TimeInterval)
        case playbackEnded
        
        case onDisappear
    }
    
    private enum CancelId: Hashable {
        static let startListening = "CancelId.startListening"
    }
}
