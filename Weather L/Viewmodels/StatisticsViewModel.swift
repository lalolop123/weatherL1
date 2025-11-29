//
//  StatisticsViewModel.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 29/11/25.
import Foundation
import Combine

@MainActor
class StatisticsViewModel: ObservableObject {
    @Published var statistics: WeatherStatistics?
    @Published var comparisons: [CityComparison] = []
    @Published var recommendations: [WeatherRecommendation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let weatherService = WeatherService()
    
    // Generar estadísticas desde el pronóstico DIARIO
    func generateStatistics(for city: String, forecast: [DailyForecast]) {
        isLoading = true
        errorMessage = nil
        
        // Tomar los próximos 7 días del pronóstico
        let weekForecast = Array(forecast.prefix(7))
        
        // Crear puntos de temperatura para la gráfica
        let temperaturePoints = weekForecast.enumerated().map { index, weather in
            // Calcular fecha para cada día
            let dateFormatter = ISO8601DateFormatter()
            let date = dateFormatter.date(from: weather.time) ?? Date().addingTimeInterval(TimeInterval(index * 86400))
            
            // Usar promedio de temp máxima y mínima
            let avgTemp = (weather.values.temperatureMax + weather.values.temperatureMin) / 2
            
            return WeatherStatistics.TemperaturePoint(
                date: date,
                temperature: avgTemp,
                feelsLike: avgTemp, // Tomorrow.io no da "feels like" en forecast
                description: WeatherCodeHelper.obtenerDescripcion(codigo: weather.values.weatherCode),
                icon: WeatherCodeHelper.obtenerIcono(codigo: weather.values.weatherCode)
            )
        }
        
        // Calcular estadísticas
        let maxTemps = weekForecast.map { $0.values.temperatureMax }
        let minTemps = weekForecast.map { $0.values.temperatureMin }
        let allTemps = maxTemps + minTemps
        
        let avgTemp = allTemps.reduce(0, +) / Double(allTemps.count)
        let maxTemp = maxTemps.max() ?? 0
        let minTemp = minTemps.min() ?? 0
        
        // Calcular promedio de humedad (si está disponible)
        let avgHumidity = weekForecast.compactMap { $0.values.humidity }.reduce(0, +) / Double(weekForecast.count)
        
        // Calcular promedio de probabilidad de precipitación
        let avgPrecipitation = weekForecast.compactMap { $0.values.precipitationProbability }.reduce(0, +) / Double(weekForecast.count)
        
        statistics = WeatherStatistics(
            cityName: city,
            temperatureData: temperaturePoints,
            averageTemp: avgTemp,
            maxTemp: maxTemp,
            minTemp: minTemp,
            precipitationChance: avgPrecipitation,
            humidity: avgHumidity,
            windSpeed: 0 // Tomorrow.io no da velocidad del viento en pronóstico diario
        )
        
        generateRecommendations(avgTemp: avgTemp, humidity: avgHumidity, windSpeed: 0)
        
        isLoading = false
    }
    
    // Generar comparaciones entre ciudades favoritas
    func generateComparisons(favorites: [String]) async {
        comparisons.removeAll()
        
        for city in favorites.prefix(5) { // Máximo 5 ciudades
            do {
                let weather = try await weatherService.obtenerClima(ciudad: city)
                let comparison = CityComparison(
                    cityName: weather.location.nombre ?? city,
                    currentTemp: weather.data.values.temperature,
                    condition: WeatherCodeHelper.obtenerDescripcion(codigo: weather.data.values.weatherCode),
                    icon: WeatherCodeHelper.obtenerIcono(codigo: weather.data.values.weatherCode)
                )
                comparisons.append(comparison)
            } catch {
                print("Error fetching comparison for \(city): \(error)")
            }
        }
    }
    
    // Generar recomendaciones inteligentes
    private func generateRecommendations(avgTemp: Double, humidity: Double, windSpeed: Double) {
        recommendations.removeAll()
        
        // Recomendación de vestimenta
        if avgTemp < 15 {
            recommendations.append(WeatherRecommendation(
                title: "Abrígate bien",
                description: "Temperaturas frías esta semana. Lleva chamarra y bufanda.",
                icon: "snowflake",
                category: .clothing
            ))
        } else if avgTemp > 28 {
            recommendations.append(WeatherRecommendation(
                title: "Ropa ligera",
                description: "Calor intenso. Usa ropa fresca y clara.",
                icon: "sun.max.fill",
                category: .clothing
            ))
        }
        
        // Recomendación de actividades outdoor
        if avgTemp >= 18 && avgTemp <= 26 {
            recommendations.append(WeatherRecommendation(
                title: "Perfecto para actividades",
                description: "Clima ideal para ejercicio al aire libre.",
                icon: "figure.run",
                category: .outdoor
            ))
        }
        
        // Recomendación de hidratación
        if avgTemp > 25 || humidity > 70 {
            recommendations.append(WeatherRecommendation(
                title: "Mantente hidratado",
                description: "Alta temperatura/humedad. Toma suficiente agua.",
                icon: "drop.fill",
                category: .health
            ))
        }
        
        // Recomendación general de temperatura
        if avgTemp >= 20 && avgTemp <= 24 {
            recommendations.append(WeatherRecommendation(
                title: "Clima perfecto",
                description: "Temperaturas ideales esta semana.",
                icon: "sun.max",
                category: .general
            ))
        }
        
        // Siempre agregar al menos una recomendación general
        if recommendations.isEmpty {
            recommendations.append(WeatherRecommendation(
                title: "Clima estable",
                description: "Condiciones climáticas normales esta semana.",
                icon: "checkmark.circle.fill",
                category: .general
            ))
        }
    }
}
