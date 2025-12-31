import Foundation

struct KeyPoint: Identifiable, Equatable {
    let id: String
    let title: String
    let order: Int
    let audioSource: AudioSource
}

enum AudioSource: Equatable {
    case local(fileName: String)
    case remote(url: URL)
}

extension KeyPoint {
    init(remote: KeyPointRemoteModel) {
        self.id = remote.id
        self.title = remote.title
        self.order = remote.order
        self.audioSource = .local(fileName: remote.trackName)
    }
}
