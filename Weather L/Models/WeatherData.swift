//
//  Untitled.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 21/10/25.
//

import Foundation

// Estructura principal que llega del API
struct WeatherResponse: Codable {
    let data: WeatherDataTimeline
    var location: Location
}

// Los datos del clima en un momento específico
struct WeatherDataTimeline: Codable {
    let time: String
    let values: WeatherValues
}

// Todos los valores del clima
struct WeatherValues: Codable {
    let temperature: Double
    let temperatureApparent: Double
    let humidity: Double
    let windSpeed: Double
    let weatherCode: Int
    let uvIndex: Int
    
    // Calidad del aire
    let particulateMatter25: Double?
    let particulateMatter10: Double?
    let pollutantO3: Double?
    let pollutantNO2: Double?
    let pollutantCO: Double?
    let epaIndex: Int?
}

// Coordenadas de la ubicación
struct Location: Codable {
    let lat: Double
    let lon: Double
    var nombre: String?
    
    enum CodingKeys: String, CodingKey {
        case lat
        case lon
    }
}

    
    // Para el pronóstico de varios días
    struct WeatherForecastResponse: Codable {
        let timelines: Timelines
        let location: Location
    }
    
    struct Timelines: Codable {
        let daily: [DailyForecast]
    }
    
    struct DailyForecast: Codable {
        let time: String
        let values: DailyValues
    }
    
    struct DailyValues: Codable {
        let temperatureMax: Double
        let temperatureMin: Double
        let weatherCodeMax: Int?  // Cambiado
        let weatherCodeMin: Int?  // Cambiado
        let precipitationProbabilityAvg: Double?  // Cambiado
        let uvIndexMax: Int?  // Cambiado
        let humidityAvg: Double?  // Cambiado
        
        // Propiedades computadas para mantener compatibilidad
        var weatherCode: Int {
            return weatherCodeMax ?? weatherCodeMin ?? 1000
        }
        
        var precipitationProbability: Double {
            return precipitationProbabilityAvg ?? 0
        }
        
        var uvIndex: Int {
            return uvIndexMax ?? 0
        }
        
        var humidity: Double {
            return humidityAvg ?? 0
        }
        
        enum CodingKeys: String, CodingKey {
            case temperatureMax
            case temperatureMin
            case weatherCodeMax
            case weatherCodeMin
            case precipitationProbabilityAvg
            case uvIndexMax
            case humidityAvg
        }
    }
    // Respuesta de calidad del aire
    struct AirQualityResponse: Codable {
        let data: AirQualityTimeline
        let location: Location
    }
    
    struct AirQualityTimeline: Codable {
        let time: String
        let values: AirQualityValues
    }
    
    struct AirQualityValues: Codable {
        let particulateMatter25: Double?
        let particulateMatter10: Double?
        let pollutantO3: Double?
        let pollutantNO2: Double?
        let pollutantCO: Double?
        let epaIndex: Int?
        
        enum CodingKeys: String, CodingKey {
            case particulateMatter25
            case particulateMatter10
            case pollutantO3
            case pollutantNO2
            case pollutantCO
            case epaIndex
        }
    }

// Pronóstico por hora
struct HourlyForecastResponse: Codable {
    let timelines: HourlyTimelines
    let location: Location
}

struct HourlyTimelines: Codable {
    let hourly: [HourlyForecast]
}

struct HourlyForecast: Codable {
    let time: String
    let values: HourlyValues
}

struct HourlyValues: Codable {
    let temperature: Double
    let weatherCode: Int
    let precipitationProbability: Double
    let windSpeed: Double
    let humidity: Double
}

