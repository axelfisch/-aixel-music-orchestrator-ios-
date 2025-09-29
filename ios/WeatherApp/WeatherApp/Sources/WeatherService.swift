import Foundation

protocol WeatherServiceProviding {
    func searchCities(query: String) async throws -> [City]
    func fetchForecast(latitude: Double, longitude: Double) async throws -> ForecastData
}

struct WeatherService: WeatherServiceProviding {
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func searchCities(query: String) async throws -> [City] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(encoded)&count=10&language=fr&format=json") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await urlSession.data(from: url)
        try Self.validate(response: response)
        let decoded = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        return decoded.results ?? []
    }

    func fetchForecast(latitude: Double, longitude: Double) async throws -> ForecastData {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,weather_code"),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min"),
            URLQueryItem(name: "timezone", value: "auto")
        ]

        guard let url = components.url else { throw URLError(.badURL) }
        let (data, response) = try await urlSession.data(from: url)
        try Self.validate(response: response)
        let decoder = JSONDecoder()
        let raw = try decoder.decode(WeatherResponseRaw.self, from: data)
        return try Self.transform(raw: raw)
    }

    private static func validate(response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    private static func transform(raw: WeatherResponseRaw) throws -> ForecastData {
        let current = CurrentWeather(
            temperatureCelsius: raw.current.temperature_2m,
            weatherCode: raw.current.weather_code
        )

        var dailyForecasts: [DailyForecast] = []
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "fr_FR")
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let count = min(raw.daily.time.count, raw.daily.weather_code.count, raw.daily.temperature_2m_max.count, raw.daily.temperature_2m_min.count)
        for idx in 0..<count {
            guard let date = dateFormatter.date(from: raw.daily.time[idx]) else { continue }
            let forecast = DailyForecast(
                date: date,
                minTempCelsius: raw.daily.temperature_2m_min[idx],
                maxTempCelsius: raw.daily.temperature_2m_max[idx],
                weatherCode: raw.daily.weather_code[idx]
            )
            dailyForecasts.append(forecast)
        }

        return ForecastData(current: current, daily: dailyForecasts)
    }
}

