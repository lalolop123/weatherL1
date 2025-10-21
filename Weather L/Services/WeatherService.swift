//
//  Untitled.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 21/10/25.
//

import Foundation

// Tipos de errores posibles
enum WeatherError: Error {
    case ciudadInvalida
    case sinInternet
    case errorDelServidor
    case datosIncorrectos
    
    var mensaje: String {
        switch self {
        case .ciudadInvalida:
            return "No encontré esa ciudad 😕"
        case .sinInternet:
            return "Revisa tu conexión a internet"
        case .errorDelServidor:
            return "El servidor no responde"
        case .datosIncorrectos:
            return "Los datos llegaron mal"
        }
    }
}

class WeatherService {
    
    
    private let apiKey = "i24OFkbsvAWPnEAfhIoRBwclK4HqRjXi"
    private let baseURL = "https://api.tomorrow.io/v4"
    
    // Función principal para obtener el clima
    func obtenerClima(ciudad: String) async throws -> WeatherResponse {
        
       
        let coordenadas = try obtenerCoordenadas(ciudad: ciudad)
        let urlCompleta = "\(baseURL)/weather/realtime?location=\(coordenadas.lat),\(coordenadas.lon)&apikey=\(apiKey)&units=metric"
        
        print("🌐 Consultando API: \(urlCompleta)")
        
        guard let url = URL(string: urlCompleta) else {
            throw WeatherError.errorDelServidor
        }
        
        // 3. Hacemos la petición
        do {
            let (data, respuesta) = try await URLSession.shared.data(from: url)
            
            // 4. Verificamos que salió bien
            guard let httpRespuesta = respuesta as? HTTPURLResponse else {
                throw WeatherError.errorDelServidor
            }
            
            print("📡 Código de respuesta: \(httpRespuesta.statusCode)")
            
            if httpRespuesta.statusCode != 200 {
                throw WeatherError.errorDelServidor
            }
            
            // 5. Convertimos el JSON
            let decoder = JSONDecoder()
            let clima = try decoder.decode(WeatherResponse.self, from: data)
            print("✅ Clima obtenido exitosamente")
            return clima
            
        } catch let error as DecodingError {
            print("❌ Error decodificando: \(error)")
            throw WeatherError.datosIncorrectos
        } catch {
            print("❌ Error de red: \(error)")
            throw WeatherError.sinInternet
        }
    }
    
    // funcion para obtener el pronositoc de 7 dias
    func obtenerPronosticoSemanal(ciudad: String) async throws -> [DailyForecast] {
        
        let coordenadas = try obtenerCoordenadas(ciudad: ciudad)
        
        // URL para pronóstico diario
        let urlCompleta = "\(baseURL)/weather/forecast?location=\(coordenadas.lat),\(coordenadas.lon)&apikey=\(apiKey)&units=metric&timesteps=1d"
        
        print("🌐 Consultando pronóstico semanal: \(urlCompleta)")
        
        guard let url = URL(string: urlCompleta) else {
            throw WeatherError.errorDelServidor
        }
        
        do {
            let (data, respuesta) = try await URLSession.shared.data(from: url)
            
            guard let httpRespuesta = respuesta as? HTTPURLResponse else {
                throw WeatherError.errorDelServidor
            }
            
            print("📡 Código de respuesta pronóstico: \(httpRespuesta.statusCode)")
            
            if httpRespuesta.statusCode != 200 {
                throw WeatherError.errorDelServidor
            }
            
            let decoder = JSONDecoder()
            let pronostico = try decoder.decode(WeatherForecastResponse.self, from: data)
            print("✅ Pronóstico semanal obtenido: \(pronostico.timelines.daily.count) días")
            return pronostico.timelines.daily
            
        } catch let error as DecodingError {
            print("❌ Error decodificando pronóstico: \(error)")
            throw WeatherError.datosIncorrectos
        } catch {
            print("❌ Error de red pronóstico: \(error)")
            throw WeatherError.sinInternet
        }
    }
    
    // Nueva función para obtener calidad del aire
    func obtenerCalidadAire(ciudad: String) async throws -> AirQualityValues {
        
        let coordenadas = try obtenerCoordenadas(ciudad: ciudad)
        
        // URL para calidad del aire
        let urlCompleta = "\(baseURL)/weather/realtime?location=\(coordenadas.lat),\(coordenadas.lon)&apikey=\(apiKey)&fields=particulateMatter25,particulateMatter10,pollutantO3,pollutantNO2,pollutantCO,epaIndex"
        
        print("🌐 Consultando calidad del aire: \(urlCompleta)")
        
        guard let url = URL(string: urlCompleta) else {
            throw WeatherError.errorDelServidor
        }
        
        do {
            let (data, respuesta) = try await URLSession.shared.data(from: url)
            
            // Ver qué responde el API
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 Respuesta calidad aire: \(jsonString)")
            }
            
            guard let httpRespuesta = respuesta as? HTTPURLResponse else {
                throw WeatherError.errorDelServidor
            }
            
            print("📡 Código de respuesta calidad aire: \(httpRespuesta.statusCode)")
            
            if httpRespuesta.statusCode != 200 {
                throw WeatherError.errorDelServidor
            }
            
            let decoder = JSONDecoder()
            let airQuality = try decoder.decode(AirQualityResponse.self, from: data)
            print("✅ Calidad del aire obtenida")
            return airQuality.data.values
            
        } catch let error as DecodingError {
            print("❌ Error decodificando calidad aire: \(error)")
            throw WeatherError.datosIncorrectos
        } catch {
            print("❌ Error de red calidad aire: \(error)")
            throw WeatherError.sinInternet
        }
    }
    
    // Convierte nombres de ciudad a coordenadas
    private func obtenerCoordenadas(ciudad: String) throws -> (lat: Double, lon: Double) {
        
        let ciudades: [String: (Double, Double)] = [
            "monterrey": (25.6866, -100.3161),
            "ciudad de méxico": (19.4326, -99.1332),
            "cdmx": (19.4326, -99.1332),
            "guadalajara": (20.6597, -103.3496),
            "puebla": (19.0414, -98.2063),
            "tijuana": (32.5149, -117.0382),
            "león": (21.1212, -101.6842),
            "juárez": (31.6904, -106.4245),
            "cancún": (21.1619, -86.8515),
            "mérida": (20.9674, -89.5926),
            "querétaro": (20.5888, -100.3899),
            "san luis potosí": (22.1565, -100.9855)
        ]
        
        let ciudadLower = ciudad.lowercased().trimmingCharacters(in: .whitespaces)
        
        guard let coordenadas = ciudades[ciudadLower] else {
            print("❌ Ciudad no encontrada: \(ciudad)")
            throw WeatherError.ciudadInvalida
        }
        
        print("📍 Coordenadas de \(ciudad): \(coordenadas)")
        return coordenadas
    }
}
