 WeatherL ☀️🌧️

App de clima desarrollada en SwiftUI.  
Muestra el clima actual, pronóstico semanal y por hora (24h), con opción de cambiar ciudad y unidad °C/°F.

## Características
- Clima actual con ícono y temperatura
- Pronóstico semanal horizontal
- Pronóstico por hora (00:00–23:00)
- Cambiar ciudad desde modal
- Ajustes de unidad °C / °F

## Requisitos
- Xcode 15 o superior
- iOS 16 o superior (simulador iPhone 15/16 Pro)

## Estructura del código
- `WeatherLApp.swift` → punto de entrada
- `ContentView.swift` → vista principal con ScrollView
- `CurrentWeatherView`, `WeeklyForecastView`, `HourlyForecastView` → componentes modulares
- `SettingsView`, `ChangeCityView` → modales

##  Roadmap futuro
- Conectar API real (OpenWeather)
- Animaciones suaves en scroll
- Fondo dinámico según clima
- Guardar ciudad preferida
