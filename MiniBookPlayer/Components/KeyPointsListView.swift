import SwiftUI

struct KeyPointsListView: View {
    let keyPoints: [KeyPoint]
    let currentIndex: Int
    let onSelect: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.secondary)
                .frame(width: 36, height: 4)
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            Text("Key points")
                .font(.headline)
                .padding(.bottom, 12)
            
            List {
                ForEach(Array(keyPoints.enumerated()), id: \.element.id) { index, keyPoint in
                    keyPointRow(
                        title: keyPoint.title,
                        isActive: index == currentIndex
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelect(index)
                    }
                }
            }
            .listStyle(.plain)
        }
    }
    
    private func keyPointRow(title: String, isActive: Bool) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(isActive ? .blue : .primary)
            
            Spacer()
            
            if isActive {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 8)
    }
}
