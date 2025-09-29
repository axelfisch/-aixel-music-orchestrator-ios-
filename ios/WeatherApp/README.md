# WeatherApp (iOS, SwiftUI)

Une application météo simple construite avec SwiftUI et l'API Open-Meteo.

## Prérequis
- Xcode 15+ (iOS 16 ciblé)
- macOS avec outils de développement Apple

## Installation
1. Installer XcodeGen si vous souhaitez régénérer le projet Xcode (facultatif):
   ```bash
   brew install xcodegen
   ```
2. Ouvrir le projet:
   - Soit ouvrir `WeatherApp.xcodeproj` si présent
   - Soit générer le projet avec XcodeGen:
     ```bash
     cd ios/WeatherApp
     xcodegen generate
     open WeatherApp.xcodeproj
     ```

## Exécution
1. Sélectionnez la cible `WeatherApp` et un simulateur iOS 16+
2. Lancez avec le bouton Run (⌘R)

## Fonctionnalités
- Recherche de villes (géocodage Open-Meteo)
- Météo actuelle: température et résumé
- Prévisions quotidiennes: min/max et emoji météo

## Architecture
- `WeatherService`: appels réseau (géocoding + prévisions)
- `WeatherViewModel`: logique d'orchestration
- Vues SwiftUI: `ContentView`, `SearchBar`, `CurrentWeatherCard`, `DailyForecastList`

## Remarques
- Aucune clé API nécessaire (Open-Meteo)
- Langue et formats: FR