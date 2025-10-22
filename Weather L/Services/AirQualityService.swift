//
//  a.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 21/10/25.
//

import Foundation

class AirQualityService {
    
    
    private let apiKey = "f7d0bf6188ee7f0e82785fb3369cfe2b"
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    
    // Función para obtener calidad del aire
    func obtenerCalidadAire(lat: Double, lon: Double) async throws -> AirQualityValues {
        
        let urlCompleta = "\(baseURL)/air_pollution?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
        
        print("🌐 Consultando calidad del aire OpenWeather: \(urlCompleta)")
        
        guard let url = URL(string: urlCompleta) else {
            throw WeatherError.errorDelServidor
        }
        
        do {
            let (data, respuesta) = try await URLSession.shared.data(from: url)
            
            // Ver respuesta
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 Respuesta OpenWeather: \(jsonString)")
            }
            
            guard let httpRespuesta = respuesta as? HTTPURLResponse else {
                throw WeatherError.errorDelServidor
            }
            
            print("📡 Código de respuesta calidad aire: \(httpRespuesta.statusCode)")
            
            if httpRespuesta.statusCode != 200 {
                throw WeatherError.errorDelServidor
            }
            
            let decoder = JSONDecoder()
            let airQualityResponse = try decoder.decode(OpenWeatherAirQuality.self, from: data)
            
            // Convertir a nuestro formato
            let components = airQualityResponse.list.first?.components
            let aqi = airQualityResponse.list.first?.main.aqi
            
            let values = AirQualityValues(
                particulateMatter25: components?.pm2_5,
                particulateMatter10: components?.pm10,
                pollutantO3: components?.o3,
                pollutantNO2: components?.no2,
                pollutantCO: components?.co,
                epaIndex: aqi
            )
            
            print("✅ Calidad del aire obtenida de OpenWeather")
            return values
            
        } catch let error as DecodingError {
            print("❌ Error decodificando calidad aire: \(error)")
            throw WeatherError.datosIncorrectos
        } catch {
            print("❌ Error de red calidad aire: \(error)")
            throw WeatherError.sinInternet
        }
    }
}

// Estructuras para decodificar la respuesta de OpenWeatherMap
struct OpenWeatherAirQuality: Codable {
    let list: [AirQualityData]
}

struct AirQualityData: Codable {
    let main: AirQualityMain
    let components: AirQualityComponents
}

struct AirQualityMain: Codable {
    let aqi: Int
}

struct AirQualityComponents: Codable {
    let co: Double?
    let no2: Double?
    let o3: Double?
    let pm2_5: Double?
    let pm10: Double?
}
