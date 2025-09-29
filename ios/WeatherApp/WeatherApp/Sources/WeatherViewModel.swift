import Foundation
import Combine

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var cities: [City] = []
    @Published var selectedCity: City?

    @Published var currentWeather: CurrentWeather?
    @Published var dailyForecasts: [DailyForecast] = []

    private let service: WeatherServiceProviding

    init(service: WeatherServiceProviding) {
        self.service = service
    }

    func searchCities() async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        errorMessage = nil
        do {
            let results = try await service.searchCities(query: query)
            cities = results
        } catch {
            errorMessage = NSLocalizedString("Erreur de recherche.", comment: "")
        }
        isLoading = false
    }

    func selectCity(_ city: City) async {
        selectedCity = city
        cities = []
        await refresh()
    }

    func refresh() async {
        guard let city = selectedCity else { return }
        isLoading = true
        errorMessage = nil
        do {
            let forecast = try await service.fetchForecast(latitude: city.latitude, longitude: city.longitude)
            currentWeather = forecast.current
            dailyForecasts = forecast.daily
        } catch {
            errorMessage = NSLocalizedString("Impossible de charger la météo.", comment: "")
        }
        isLoading = false
    }
}

