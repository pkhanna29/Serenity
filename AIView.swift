import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct AIView: View {
    @State private var userInput = ""
    @State private var messages: [ChatMessage] = []
    @State private var isTyping = false

    var body: some View {
        VStack {
            Text("AI Chatbot")
                .font(.title)
                .bold()
                .padding(.top, 16)
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(messages) { message in
                            HStack {
                                if message.isUser {
                                    Spacer()
                                    Text(message.text)
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                        .frame(maxWidth: 250, alignment: .trailing)
                                } else {
                                    Text(message.text)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                        .frame(maxWidth: 250, alignment: .leading)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        }

                        if isTyping {
                            HStack {
                                Text("AI is typing...")
                                    .italic()
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: messages.count) { __ in
                    withAnimation {
                        scrollView.scrollTo(messages.last?.id)
                    }
                }
            }

            Divider()

            HStack {
                TextField("Type your message...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 40)

                Button("Send") {
                    sendMessage(userInput)
                }
                .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white) // optional
        .edgesIgnoringSafeArea(.all)
        
        .navigationTitle("AI Chat")
        .navigationBarTitleDisplayMode(.inline)
    }

    func sendMessage(_ message: String) {
        let userMsg = ChatMessage(text: message, isUser: true)
        messages.append(userMsg)
        userInput = ""

        isTyping = true

        guard let url = URL(string: "http://104.171.202.69:8000/chat") else {
            isTyping = false
            return
        }


        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let json = ["message": message]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: json) else {
            isTyping = false
            return
        }
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, _, error in
            defer { DispatchQueue.main.async { isTyping = false } }

            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    messages.append(ChatMessage(text: "⚠️ Network error.", isUser: false))
                }
                return
            }

            if let result = try? JSONDecoder().decode([String: String].self, from: data),
               let reply = result["response"] {
                DispatchQueue.main.async {
                    messages.append(ChatMessage(text: reply, isUser: false))
                }
            } else {
                DispatchQueue.main.async {
                    messages.append(ChatMessage(text: "⚠️ Error parsing response.", isUser: false))
                }
            }
        }.resume()
        
        
    }
    
    
}

#Preview {
    AIView()
}
