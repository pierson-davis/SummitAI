import SwiftUI

struct CharacterView: View {
    var body: some View {
        VStack {
            Text("Character System")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Coming Soon")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Character")
    }
}

#Preview {
    CharacterView()
}
