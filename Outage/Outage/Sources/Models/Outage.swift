import Foundation
import CoreLocation

struct Outage: Identifiable, Codable, Equatable {
    enum Status: String, Codable { case live, planned, restored }

    let id: String
    let distributor: Distributor
    let status: Status
    let startedAt: Date?
    let estimatedRestoration: Date?
    let cause: String?
    let affectedCustomers: Int?
    let affectedPostcodes: [String]
    let centroid: CLLocationCoordinate2DWrapper
}

struct Distributor: Codable, Equatable, Hashable, Identifiable {
    let id: String
    let name: String
    let state: String
}

struct CLLocationCoordinate2DWrapper: Codable, Equatable {
    let latitude: Double
    let longitude: Double
}
