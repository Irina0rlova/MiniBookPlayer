import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            
            if let audioURL = Bundle.main.url(
                forResource: "19622-05",
                withExtension: "mp3"
            ) {
                Text("Audio OK: \(audioURL)")
            }
            
            if let metadataURL = Bundle.main.url(
                forResource: "aesops_fables",
                withExtension: "json"
            ) {
                Text("Metadata OK: \(metadataURL)")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
