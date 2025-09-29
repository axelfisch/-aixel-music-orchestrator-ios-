import Foundation

struct City: Identifiable, Decodable, Hashable {
    let id: Int?
    let name: String
    let country: String
    let latitude: Double
    let longitude: Double

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case country
        case latitude
        case longitude
    }
}

struct GeocodingResponse: Decodable {
    let results: [City]?
}

struct CurrentWeather: Equatable {
    let temperatureCelsius: Double
    let weatherCode: Int

    var description: String {
        WeatherCodeMapper.description(for: weatherCode)
    }
}

struct DailyForecast: Identifiable, Equatable {
    let id: UUID = UUID()
    let date: Date
    let minTempCelsius: Double
    let maxTempCelsius: Double
    let weatherCode: Int

    var description: String {
        WeatherCodeMapper.description(for: weatherCode)
    }
}

struct ForecastData {
    let current: CurrentWeather
    let daily: [DailyForecast]
}

struct WeatherResponseRaw: Decodable {
    struct Current: Decodable {
        let temperature_2m: Double
        let weather_code: Int
    }

    struct Daily: Decodable {
        let time: [String]
        let weather_code: [Int]
        let temperature_2m_max: [Double]
        let temperature_2m_min: [Double]
    }

    let current: Current
    let daily: Daily
}

enum WeatherCodeMapper {
    static func description(for code: Int) -> String {
        switch code {
        case 0: return "Ciel dégagé"
        case 1, 2: return "Partiellement nuageux"
        case 3: return "Couvert"
        case 45, 48: return "Brouillard"
        case 51, 53, 55: return "Bruine"
        case 56, 57: return "Bruine verglaçante"
        case 61, 63, 65: return "Pluie"
        case 66, 67: return "Pluie verglaçante"
        case 71, 73, 75: return "Neige"
        case 77: return "Grains de neige"
        case 80, 81, 82: return "Averses"
        case 85, 86: return "Averses de neige"
        case 95: return "Orage"
        case 96, 99: return "Orage avec grêle"
        default: return "Conditions inconnues"
        }
    }

    static func emoji(for code: Int) -> String {
        switch code {
        case 0: return "☀️"
        case 1, 2: return "⛅️"
        case 3: return "☁️"
        case 45, 48: return "🌫️"
        case 51, 53, 55: return "🌦️"
        case 56, 57: return "🌧️🧊"
        case 61, 63, 65: return "🌧️"
        case 66, 67: return "🌧️🧊"
        case 71, 73, 75: return "🌨️"
        case 77: return "❄️"
        case 80, 81, 82: return "🌦️"
        case 85, 86: return "🌨️"
        case 95: return "⛈️"
        case 96, 99: return "⛈️🧊"
        default: return "❔"
        }
    }
}

