import ComposableArchitecture
import Foundation

struct PlayerFeature: Reducer {
    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.Effect<Action> {
        switch action {

        case .playPauseTapped:
            state.isPlaying.toggle()
            return .none

        case .nextKeyPoint:
            guard state.currentKeyPointIndex < state.book.keyPoints.count - 1 else {
                return .none
            }
            state.currentKeyPointIndex += 1
            state.currentTime = 0
            state.duration = nil
            return .none

        case .previousKeyPoint:
            guard state.currentKeyPointIndex > 0 else {
                return .none
            }
            state.currentKeyPointIndex -= 1
            state.currentTime = 0
            state.duration = nil
            return .none

        case let .seek(time):
            state.currentTime = time
            return .none

        case .seekForward:
            state.currentTime += 10
            return .none

        case .seekBackward:
            state.currentTime = max(0, state.currentTime - 5)
            return .none

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
            } else {
                state.isPlaying = false
            }
            return .none
            
        case .changeSpeed:
            return .none
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
        // UI
        case playPauseTapped
        case nextKeyPoint
        case previousKeyPoint
        case seek(to: TimeInterval)
        case seekForward
        case seekBackward
        case changeSpeed

        // Player feedback
        case playbackTimeUpdated(TimeInterval)
        case durationLoaded(TimeInterval)
        case playbackEnded
    }
}
