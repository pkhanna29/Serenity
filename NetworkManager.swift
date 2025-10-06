import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    let baseURL = "https://your-backend.onrender.com" // Replace with your actual Render URL

    // Submit a gratitude entry
    func sendGratitude(_ text: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/gratitude") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["entry": text]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }
    
    func fetchGratitudeEntries(completion: @escaping ([String]) -> Void) {
        guard let url = URL(string: "\(baseURL)/gratitude/all") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let entries = try? JSONDecoder().decode([[String: String]].self, from: data) {
                let texts = entries.compactMap { $0["entry"] }
                completion(texts)
            } else {
                completion([])
            }
        }.resume()
    }


    // Send a chat prompt to AI
    func chatWithAI(prompt: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "\(baseURL)/chat") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["prompt": prompt]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data,
               let result = try? JSONDecoder().decode([String: String].self, from: data),
               let response = result["response"] {
                completion(response)
            } else {
                completion("Error")
            }
        }.resume()
    }
}
