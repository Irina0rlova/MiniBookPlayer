import SwiftUI

struct KeyPointView: View {
    let keyPointIndex: Int
    let keyPointTotal: Int
    let keyPointText: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text("KEY POINT \(keyPointIndex) OF \(keyPointTotal)")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(keyPointText)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
    }
}
