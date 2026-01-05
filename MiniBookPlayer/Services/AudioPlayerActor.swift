import AVFoundation
import Foundation

actor AudioPlayerActor: NSObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?
    private var continuation: AsyncStream<AudioPlayerService.Event>.Continuation?
    
    private var timerTask: Task<Void, Never>?

    func load(source: AudioSource) throws -> TimeInterval {
        let url: URL

        switch source {
        case .local(let fileName):
            guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: nil) else {
                throw NSError(domain: "AudioPlayer", code: 1)
            }
            url = fileURL

        case .remote(let remoteURL):
            url = remoteURL
        }

        let player = try AVAudioPlayer(contentsOf: url)
        player.delegate = self
        player.enableRate = true
        player.prepareToPlay()

        self.player = player
        return player.duration
    }
    
    func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playback,
            mode: .spokenAudio,
            options: []
        )
        try session.setActive(true)
    }

    func play() {
        player?.play()
        startProgressTimer()
    }

    func pause() {
        player?.pause()
        stopProgressTimer()
    }

    func seek(to time: TimeInterval) {
        player?.currentTime = time
    }

    func setRate(_ rate: Float) {
        player?.rate = rate
    }

    func events() -> AsyncStream<AudioPlayerService.Event> {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }

    nonisolated func audioPlayerDidFinishPlaying(
        _ player: AVAudioPlayer,
        successfully flag: Bool
    ) {
        Task {
            await continuation?.yield(.playbackEnded)
        }
    }
    
    func startProgressTimer() {
        timerTask?.cancel()

        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 500_000_000)
                if let time = player?.currentTime {
                    continuation?.yield(.playbackTimeUpdated(time))
                }
            }
        }
    }

    func stopProgressTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
}
