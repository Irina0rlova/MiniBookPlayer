import Foundation

struct PlayerSnapshot: Equatable, Codable {
    let bookId: String
    let keyPointIndex: Int
    let currentTime: TimeInterval
    let playbackRate: Float
}
