   import Foundation

   struct Book: Identifiable, Equatable {
       let id: String
       let title: String
       let author: String
       let coverImageURL: URL?
       let keyPoints: [KeyPoint]
   }

   extension Book {
       init(remote: BookRemoteModel) {
           self.id = remote.id
           self.title = remote.title
           self.author = remote.author
           self.coverImageURL = URL(string: remote.coverImageURL ?? "")
        
           let remoteKeyPoints = remote.keyPoints ?? []
           self.keyPoints = remoteKeyPoints
               .sorted(by: { $0.order < $1.order })
               .map(KeyPoint.init(remote:))
       }
   }
