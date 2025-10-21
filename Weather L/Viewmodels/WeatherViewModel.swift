//
//  Untitled.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 21/10/25.
//

import Foundation

@MainActor
class WeatherViewModel: ObservableObject {
    
    // Variables que actualizan la interfaz automáticamente
    @Published var clima: WeatherDataTimeline?
    @Published var estaCargando = false
    @Published var mensajeError: String?
    @Published var ciudadSeleccionada = "Monterrey"
    @Published var pronosticoSemanal: [DailyForecast] = []
    @Published var calidadAire: AirQualityValues?
    
    private let servicio = WeatherService()
    
    // Función para buscar el clima
    // Función para buscar el clima y pronóstico
    // Función para buscar el clima, pronóstico y calidad del aire
    func buscarClima() async {
        print("🔍 Iniciando búsqueda para: \(ciudadSeleccionada)")
        
        estaCargando = true
        mensajeError = nil
        clima = nil
        pronosticoSemanal = []
        calidadAire = nil
        
        do {
            // Obtenemos todo en paralelo
            async let climaActual = servicio.obtenerClima(ciudad: ciudadSeleccionada)
            async let pronostico = servicio.obtenerPronosticoSemanal(ciudad: ciudadSeleccionada)
            async let airQuality = servicio.obtenerCalidadAire(ciudad: ciudadSeleccionada)
            
            let (respuestaClima, respuestaPronostico, respuestaAire) = try await (climaActual, pronostico, airQuality)
            
            self.clima = respuestaClima.data
            self.pronosticoSemanal = Array(respuestaPronostico.prefix(7))
            self.calidadAire = respuestaAire
            
            print("✅ Clima, pronóstico y calidad del aire actualizados")
        } catch let error as WeatherError {
            self.mensajeError = error.mensaje
            print("❌ Error: \(error.mensaje)")
        } catch {
            self.mensajeError = "Error inesperado"
            print("❌ Error desconocido: \(error)")
        }
        
        estaCargando = false
    }
    
    // Cambiar de ciudad
    func cambiarCiudad(a nuevaCiudad: String) {
        print("🏙️ Cambiando ciudad a: \(nuevaCiudad)")
        ciudadSeleccionada = nuevaCiudad
        Task {
            await buscarClima()
        }
    }
    
    // Propiedades computadas para mostrar en la UI
    var temperaturaTexto: String {
        guard let temp = clima?.values.temperature else { return "--°" }
        return String(format: "%.0f°C", temp)
    }
    
    var humedadTexto: String {
        guard let humedad = clima?.values.humidity else { return "--%" }
        return String(format: "%.0f%%", humedad)
    }
    
    var vientoTexto: String {
        guard let viento = clima?.values.windSpeed else { return "-- km/h" }
        return String(format: "%.1f km/h", viento)
    }
    
    var sensacionTermica: String {
        guard let temp = clima?.values.temperatureApparent else { return "--°" }
        return String(format: "%.0f°C", temp)
    }
}
