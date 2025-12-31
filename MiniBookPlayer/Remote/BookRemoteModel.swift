import Foundation

struct BookRemoteModel: Decodable {
    let id: String
    let title: String
    let author: String
    let coverImageURL: String?
    let keyPoints: [KeyPointRemoteModel]?
}
