import Foundation

struct Weather: Codable, Equatable {
    let locationName: String
    let temperatureCelsius: Double
    let condition: String
    let windKph: Double
    let humidityPercent: Double
    let updatedAt: Date
}

struct WeatherAlert: Codable, Equatable, Identifiable {
    let id: String
    let title: String
    let description: String
    let severity: String
    let effective: Date
    let expires: Date
}
