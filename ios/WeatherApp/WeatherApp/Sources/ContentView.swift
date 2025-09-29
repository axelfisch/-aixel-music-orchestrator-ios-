import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: WeatherViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                SearchBar(text: $viewModel.query, isLoading: viewModel.isLoading) {
                    Task { await viewModel.searchCities() }
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.callout)
                        .padding(.horizontal)
                }

                if !viewModel.cities.isEmpty {
                    List(viewModel.cities) { city in
                        Button {
                            Task { await viewModel.selectCity(city) }
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(city.name)
                                        .font(.headline)
                                    Text(city.country)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(String(format: "%.2f, %.2f", city.latitude, city.longitude))
                                    .foregroundColor(.secondary)
                                    .font(.footnote)
                            }
                        }
                    }
                    .listStyle(.plain)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            if let city = viewModel.selectedCity, let current = viewModel.currentWeather {
                                CurrentWeatherCard(city: city, current: current)
                            }

                            if !viewModel.dailyForecasts.isEmpty {
                                DailyForecastList(forecasts: viewModel.dailyForecasts)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Météo")
            .toolbar {
                if viewModel.selectedCity != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task { await viewModel.refresh() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(WeatherViewModel(service: WeatherService()))
    }
}

