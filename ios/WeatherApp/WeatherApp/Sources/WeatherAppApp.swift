import SwiftUI

@main
struct WeatherAppApp: App {
    @StateObject private var viewModel = WeatherViewModel(service: WeatherService())

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}

