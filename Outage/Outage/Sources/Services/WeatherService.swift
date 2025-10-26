import Foundation

protocol WeatherServicing {
    func fetchWeather(postcode: String) async throws -> Weather
    func fetchAlerts(postcode: String) async throws -> [WeatherAlert]
}

struct WeatherService: WeatherServicing {
    private let networkClient: NetworkClient
    init(networkClient: NetworkClient) { self.networkClient = networkClient }

    func fetchWeather(postcode: String) async throws -> Weather {
        guard let url = Bundle.main.url(forResource: "mock_weather", withExtension: "json") else {
            throw NSError(domain: "WeatherService", code: 1)
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Weather.self, from: data)
    }

    func fetchAlerts(postcode: String) async throws -> [WeatherAlert] {
        guard let url = Bundle.main.url(forResource: "mock_weather_alerts", withExtension: "json") else {
            return []
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([WeatherAlert].self, from: data)
    }
}
