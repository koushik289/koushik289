import Foundation
import CoreLocation

@MainActor
final class DashboardViewModel: ObservableObject {
    enum LoadingState { case idle, loading, loaded, error(String) }

    @Published var outages: [Outage] = []
    @Published var weather: Weather?
    @Published var alerts: [WeatherAlert] = []
    @Published var loadingState: LoadingState = .idle
    @Published var showPlanned: Bool = false
    @Published var searchPostcode: String = ""

    private let outageService: OutageServicing
    private let weatherService: WeatherServicing
    private let locationManager: LocationManager
    private let notificationManager: NotificationManager

    init(outageService: OutageServicing, weatherService: WeatherServicing, locationManager: LocationManager, notificationManager: NotificationManager) {
        self.outageService = outageService
        self.weatherService = weatherService
        self.locationManager = locationManager
        self.notificationManager = notificationManager
    }

    func onAppear() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUse()
        }
    }

    func refresh() async {
        loadingState = .loading
        do {
            let status: Outage.Status? = showPlanned ? .planned : .live
            let outages = try await outageService.fetchOutages(postcode: searchPostcode.isEmpty ? nil : searchPostcode, coordinate: locationManager.lastKnownLocation?.coordinate, status: status)
            self.outages = outages

            if let postcode = searchPostcode.nonEmptyOrNil {
                async let weather = weatherService.fetchWeather(postcode: postcode)
                async let alerts = weatherService.fetchAlerts(postcode: postcode)
                self.weather = try await weather
                self.alerts = try await alerts
            }
            loadingState = .loaded
        } catch {
            loadingState = .error(error.localizedDescription)
        }
    }

    func requestNotifications() async {
        await notificationManager.requestAuthorization()
    }
}

private extension String {
    var nonEmptyOrNil: String? { isEmpty ? nil : self }
}
