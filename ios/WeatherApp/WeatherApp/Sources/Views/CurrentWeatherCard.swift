import SwiftUI

struct CurrentWeatherCard: View {
    let city: City
    let current: CurrentWeather

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(city.name)
                        .font(.title2.bold())
                    Text(city.country)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(WeatherCodeMapper.emoji(for: current.weatherCode))
                    .font(.system(size: 48))
            }
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(String(format: "%.0f", current.temperatureCelsius))
                    .font(.system(size: 56, weight: .semibold))
                Text("°C")
                    .font(.title3)
                    .baselineOffset(10)
                    .foregroundColor(.secondary)
            }
            Text(current.description)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct CurrentWeatherCard_Previews: PreviewProvider {
    static var previews: some View {
        CurrentWeatherCard(
            city: City(id: 1, name: "Paris", country: "France", latitude: 48.8566, longitude: 2.3522),
            current: CurrentWeather(temperatureCelsius: 22, weatherCode: 2)
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

