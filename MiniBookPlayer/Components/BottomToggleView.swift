import SwiftUI

struct BottomToggleView: View {
    let onChaptersTap: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            
            HStack(spacing: 0) {
                toggleButton(systemName: "headphones", isActive: true)
                toggleButton(systemName: "list.bullet", isActive: false)
                    .onTapGesture {
                        onChaptersTap()
                    }
            }
            .background(
                Capsule()
                    .fill(Color(.secondarySystemBackground))
            )
            
            Spacer()
        }
        .padding(.bottom, 12)
    }
    
    private func toggleButton(systemName: String, isActive: Bool) -> some View {
        Image(systemName: systemName)
            .foregroundStyle(isActive ? .white : .primary)
            .padding(14)
            .background(
                Circle()
                    .fill(isActive ? Color.blue : Color.clear)
            )
    }
}
