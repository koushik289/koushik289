import Foundation

protocol NetworkClient {
    func get(url: URL) async throws -> (Data, URLResponse)
}

struct URLSessionNetworkClient: NetworkClient {
    func get(url: URL) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(from: url)
    }
}
