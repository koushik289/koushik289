import Foundation
import CoreLocation

protocol OutageServicing {
    func fetchOutages(postcode: String?, coordinate: CLLocationCoordinate2D?, status: Outage.Status?) async throws -> [Outage]
}

struct OutageService: OutageServicing {
    private let networkClient: NetworkClient
    init(networkClient: NetworkClient) { self.networkClient = networkClient }

    func fetchOutages(postcode: String?, coordinate: CLLocationCoordinate2D?, status: Outage.Status?) async throws -> [Outage] {
        // Placeholder: In MVP, call multiple distributor endpoints and merge
        // For now, load bundled mock JSON
        guard let url = Bundle.main.url(forResource: "mock_outages", withExtension: "json") else { return [] }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let outages = try decoder.decode([Outage].self, from: data)
        return outages.filter { item in
            let statusMatch = status == nil || item.status == status
            let postcodeMatch = postcode == nil || item.affectedPostcodes.contains(postcode!)
            return statusMatch && postcodeMatch
        }
    }
}
