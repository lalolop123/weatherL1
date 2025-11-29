//
//  WeatherStatistics.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 29/11/25.
//

import Foundation

struct WeatherStatistics {
    let cityName: String
    let temperatureData: [TemperaturePoint]
    let averageTemp: Double
    let maxTemp: Double
    let minTemp: Double
    let precipitationChance: Double
    let humidity: Double
    let windSpeed: Double
    
    struct TemperaturePoint: Identifiable {
        let id = UUID()
        let date: Date
        let temperature: Double
        let feelsLike: Double
        let description: String
        let icon: String
    }
}

struct CityComparison: Identifiable {
    let id = UUID()
    let cityName: String
    let currentTemp: Double
    let condition: String
    let icon: String
}

struct WeatherRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let category: RecommendationCategory
    
    enum RecommendationCategory {
        case outdoor, clothing, health, general
    }
}


