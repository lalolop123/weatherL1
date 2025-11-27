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
    
    // 🔑 API KEY DE TOMORROW.IO
    private let apiKey = "8CAqCK7mXkH1HSDNgKFzgAX6rL2TD4g3"
    private let baseURL = "https://api.tomorrow.io/v4"
    private let geocoder = GeocodeService()
    
    // MARK: - Clima Actual
    
    // Función principal para obtener el clima
    func obtenerClima(ciudad: String) async throws -> WeatherResponse {
        
        // 1. Obtenemos las coordenadas usando geocodificación
        let (lat, lon, nombreCiudad) = try await geocoder.obtenerCoordenadas(ciudad: ciudad)
        
        // 2. Construimos la URL
        let urlCompleta = "\(baseURL)/weather/realtime?location=\(lat),\(lon)&apikey=\(apiKey)&units=metric"
        
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
            var clima = try decoder.decode(WeatherResponse.self, from: data)
            
            // Actualizamos el nombre de la ubicación con el geocodificado
            clima.location.nombre = nombreCiudad
            
            print("✅ Clima obtenido exitosamente para \(nombreCiudad)")
            return clima
            
        } catch let error as DecodingError {
            print("❌ Error decodificando: \(error)")
            throw WeatherError.datosIncorrectos
        } catch {
            print("❌ Error de red: \(error)")
            throw WeatherError.sinInternet
        }
    }
    
    // MARK: - Pronóstico Semanal (7 días)
    
    func obtenerPronosticoSemanal(ciudad: String) async throws -> [DailyForecast] {
        
        let (lat, lon, _) = try await geocoder.obtenerCoordenadas(ciudad: ciudad)
        
        // URL para pronóstico diario
        let urlCompleta = "\(baseURL)/weather/forecast?location=\(lat),\(lon)&apikey=\(apiKey)&units=metric&timesteps=1d"
        
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
    
    // MARK: - Pronóstico Horario (24 horas)
    
    func obtenerPronosticoHorario(ciudad: String) async throws -> [HourlyForecast] {
        
        let (lat, lon, _) = try await geocoder.obtenerCoordenadas(ciudad: ciudad)
        
        // URL para pronóstico por hora
        let urlCompleta = "\(baseURL)/weather/forecast?location=\(lat),\(lon)&apikey=\(apiKey)&units=metric&timesteps=1h"
        
        print("🌐 Consultando pronóstico por hora: \(urlCompleta)")
        
        guard let url = URL(string: urlCompleta) else {
            throw WeatherError.errorDelServidor
        }
        
        do {
            let (data, respuesta) = try await URLSession.shared.data(from: url)
            
            guard let httpRespuesta = respuesta as? HTTPURLResponse else {
                throw WeatherError.errorDelServidor
            }
            
            print("📡 Código de respuesta pronóstico horario: \(httpRespuesta.statusCode)")
            
            if httpRespuesta.statusCode != 200 {
                throw WeatherError.errorDelServidor
            }
            
            let decoder = JSONDecoder()
            let pronostico = try decoder.decode(HourlyForecastResponse.self, from: data)
            
            // Tomar solo las próximas 24 horas
            let siguientes24h = Array(pronostico.timelines.hourly.prefix(24))
            print("✅ Pronóstico horario obtenido: \(siguientes24h.count) horas")
            return siguientes24h
            
        } catch let error as DecodingError {
            print("❌ Error decodificando pronóstico horario: \(error)")
            throw WeatherError.datosIncorrectos
        } catch {
            print("❌ Error de red pronóstico horario: \(error)")
            throw WeatherError.sinInternet
        }
    }
}
