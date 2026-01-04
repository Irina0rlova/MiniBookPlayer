import ComposableArchitecture
import Foundation

struct PlayerSnapshotStorage {
    var save: (PlayerSnapshot) throws -> Void
    var load: () throws -> PlayerSnapshot?
}

extension PlayerSnapshotStorage: DependencyKey {
    static let liveValue = PlayerSnapshotStorage(
        save: { snapshot in
            let data = try JSONEncoder().encode(snapshot)
            UserDefaults.standard.set(data, forKey: "player_snapshot")
        },
        load: {
            guard let data = UserDefaults.standard.data(forKey: "player_snapshot") else {
                return nil
            }
            return try JSONDecoder().decode(PlayerSnapshot.self, from: data)
        }
    )
    
    static let testValue = PlayerSnapshotStorage(
        save: { _ in },
        load: { nil }
    )
}

extension DependencyValues {
    var playerSnapshotStorage: PlayerSnapshotStorage {
        get { self[PlayerSnapshotStorage.self] }
        set { self[PlayerSnapshotStorage.self] = newValue }
    }
}

