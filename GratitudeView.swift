import SwiftUI

struct GratitudeView: View {
    @State private var gratitudeText: String = ""
    @State private var submitted = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Gratitude")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.bottom, 100)

                Text("Gratitude is a simple simple thing...")
                    .padding(30)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Text("Entry Log")
                    .padding(20)

                TextEditor(text: $gratitudeText)
                    .frame(height: 150)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))

                Button("Submit") {
                    NetworkManager.shared.sendGratitude(gratitudeText) { success in
                        DispatchQueue.main.async {
                            self.submitted = success
                        }
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                if submitted {
                    Text("Submitted successfully!")
                        .foregroundColor(.green)
                        .padding()
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
        }
    }
}



#Preview {
    GratitudeView()
}
