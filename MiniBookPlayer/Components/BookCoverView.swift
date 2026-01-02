import SwiftUI

struct BookCoverView: View {
    @State private var isImageLoaded = false
    
    let url: URL?
    
    var body: some View {
        ZStack {
            placeholder
                .opacity(isImageLoaded ? 0 : 1)
                .animation(.easeOut(duration: 0.25), value: isImageLoaded)
            
            if let url = url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .opacity(isImageLoaded ? 1 : 0)
                            .scaleEffect(isImageLoaded ? 1 : 0.97)
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    isImageLoaded = true
                                }
                            }
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: 260, height: 400)
        .cornerRadius(20)
        .shadow(radius: 12)
        .padding(.top, 16)
        .accessibilityHidden(true)
    }
    
    var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
            Image(systemName: "book.fill")//("placeholder")
                .resizable()
                .scaledToFit()
                .padding(40)
                .foregroundStyle(.secondary)
        }
    }
}
