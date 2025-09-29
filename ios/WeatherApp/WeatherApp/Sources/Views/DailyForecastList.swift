import SwiftUI

struct DailyForecastList: View {
    let forecasts: [DailyForecast]

    private static let dayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "fr_FR")
        df.dateFormat = "EEEE d MMM"
        return df
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prévisions quotidiennes")
                .font(.headline)
                .padding(.horizontal, 4)
            ForEach(forecasts) { day in
                HStack {
                    Text(Self.dayFormatter.string(from: day.date).capitalized)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(WeatherCodeMapper.emoji(for: day.weatherCode))
                    Text(String(format: "%.0f°", day.maxTempCelsius))
                        .frame(width: 48, alignment: .trailing)
                        .foregroundColor(.primary)
                    Text(String(format: "%.0f°", day.minTempCelsius))
                        .frame(width: 48, alignment: .trailing)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 6)
                Divider()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct DailyForecastList_Previews: PreviewProvider {
    static var previews: some View {
        DailyForecastList(forecasts: [
            DailyForecast(date: Date(), minTempCelsius: 12, maxTempCelsius: 20, weatherCode: 2),
            DailyForecast(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, minTempCelsius: 10, maxTempCelsius: 18, weatherCode: 61)
        ])
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

