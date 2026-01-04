import ComposableArchitecture
import Foundation

struct AudioPlayerService {

    var load: @Sendable (_ source: AudioSource) async throws -> TimeInterval
    var play: @Sendable () async -> Void
    var pause: @Sendable () async -> Void
    var seek: @Sendable (_ time: TimeInterval) async -> Void
    var setRate: @Sendable (_ rate: Float) async -> Void

    var events: @Sendable () async -> AsyncStream<Event>

    enum Event: Equatable {
        case playbackTimeUpdated(TimeInterval)
        case playbackEnded
    }
}

extension AudioPlayerService: DependencyKey {
    static let liveValue: AudioPlayerService = {
        let actor = AudioPlayerActor()
        
        return AudioPlayerService(
            load: { source in
                try await actor.load(source: source)
            },
            play: {
                await actor.play()
            },
            pause: {
                await actor.pause()
            },
            seek: { time in
                await actor.seek(to: time)
            },
            setRate: { rate in
                await actor.setRate(rate)
            },
            events: {
                await actor.events()
            }
        )
    }()

    static let testValue = AudioPlayerService(
        load: { _ in 60 },
        play: { },
        pause: { },
        seek: { _ in },
        setRate: { _ in },
        events: { AsyncStream { _ in } }
    )
}

extension DependencyValues {
    var audioPlayer: AudioPlayerService {
        get { self[AudioPlayerService.self] }
        set { self[AudioPlayerService.self] = newValue }
    }
}
