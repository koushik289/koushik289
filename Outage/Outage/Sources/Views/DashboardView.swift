import SwiftUI
import MapKit

struct DashboardView: View {
    @StateObject var viewModel: DashboardViewModel
    @State private var mapPosition: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                map
                footer
            }
            .navigationTitle("Outage")
            .task { await viewModel.refresh() }
            .onAppear { viewModel.onAppear() }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("Enter postcode", text: $viewModel.searchPostcode)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                Button("Search") { Task { await viewModel.refresh() } }
                    .buttonStyle(.borderedProminent)
            }
            Toggle(isOn: $viewModel.showPlanned) {
                Text(viewModel.showPlanned ? "Planned Outages" : "Live Outages")
            }
            .onChange(of: viewModel.showPlanned) { _, _ in Task { await viewModel.refresh() } }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }

    private var map: some View {
        Map(position: $mapPosition) {
            ForEach(viewModel.outages) { outage in
                let coordinate = CLLocationCoordinate2D(latitude: outage.centroid.latitude, longitude: outage.centroid.longitude)
                Annotation(outage.distributor.name, coordinate: coordinate) {
                    NavigationLink {
                        OutageDetailView(outage: outage)
                    } label: {
                        Circle()
                            .fill(outage.status == .planned ? .orange : .red)
                            .frame(width: 16, height: 16)
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                    }
                }
            }
        }
        .mapStyle(.standard)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let weather = viewModel.weather {
                HStack {
                    Text("Weather: \(weather.condition) \(Int(weather.temperatureCelsius))°C")
                    Spacer()
                    Button("Alerts: \(viewModel.alerts.count)") {}
                }
                .padding(.horizontal)
            }
            HStack {
                Button("Enable Notifications") { Task { await viewModel.requestNotifications() } }
                Spacer()
                Button("Use My Location") { /* Location already requested on appear */ }
            }
            .padding()
        }
        .background(Color(UIColor.secondarySystemBackground))
    }
}

struct OutageDetailView: View {
    let outage: Outage

    var body: some View {
        List {
            Section("Summary") {
                LabeledContent("Distributor", value: outage.distributor.name)
                LabeledContent("Status", value: outage.status.rawValue.capitalized)
                if let cause = outage.cause { LabeledContent("Cause", value: cause) }
                if let started = outage.startedAt { LabeledContent("Started", value: started.formatted()) }
                if let eta = outage.estimatedRestoration { LabeledContent("ETA", value: eta.formatted()) }
                if let customers = outage.affectedCustomers { LabeledContent("Customers", value: "\(customers)") }
            }
            Section("Affected Postcodes") {
                ForEach(outage.affectedPostcodes, id: \.self) { pc in Text(pc) }
            }
        }
        .navigationTitle("Outage Details")
    }
}
