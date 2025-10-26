import SwiftUI

@main
struct OutageApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var notificationManager = NotificationManager()

    private let outageService: OutageService = OutageService(networkClient: URLSessionNetworkClient())
    private let weatherService: WeatherService = WeatherService(networkClient: URLSessionNetworkClient())

    var body: some Scene {
        WindowGroup {
            DashboardView(
                viewModel: DashboardViewModel(
                    outageService: outageService,
                    weatherService: weatherService,
                    locationManager: locationManager,
                    notificationManager: notificationManager
                )
            )
        }
    }
}
