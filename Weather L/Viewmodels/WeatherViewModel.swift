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
    @Published var ubicacion: Location?
    @Published var estaCargando = false
    @Published var mensajeError: String?
    @Published var ciudadSeleccionada = "Monterrey"
    @Published var nombreCiudadActual = "Monterrey"
    @Published var pronosticoSemanal: [DailyForecast] = []
    @Published var calidadAire: AirQualityValues?
    @Published var usarFahrenheit = false  // false = Celsius, true = Fahrenheit
    
    private let servicio = WeatherService()
    private let airQualityService = AirQualityService()
    
    
    // Función para buscar el clima, pronóstico y calidad del aire
    func buscarClima() async {
        print("🔍 Iniciando búsqueda para: \(ciudadSeleccionada)")
        
        estaCargando = true
        mensajeError = nil
        clima = nil
        pronosticoSemanal = []
        calidadAire = nil
        
        do {
            // Primero obtenemos clima y pronóstico
            async let climaActual = servicio.obtenerClima(ciudad: ciudadSeleccionada)
            async let pronostico = servicio.obtenerPronosticoSemanal(ciudad: ciudadSeleccionada)
            
            let (respuestaClima, respuestaPronostico) = try await (climaActual, pronostico)

            self.clima = respuestaClima.data
            self.ubicacion = respuestaClima.location
            self.nombreCiudadActual = respuestaClima.location.nombre ?? ciudadSeleccionada
            self.pronosticoSemanal = Array(respuestaPronostico.prefix(7))
            
            // Ahora obtenemos calidad del aire con las coordenadas
            let lat = respuestaClima.location.lat
            let lon = respuestaClima.location.lon
            
            let respuestaAire = try await airQualityService.obtenerCalidadAire(lat: lat, lon: lon)
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
        let temperatura = usarFahrenheit ? celsiusAFahrenheit(temp) : temp
        let simbolo = usarFahrenheit ? "°F" : "°C"
        return String(format: "%.0f%@", temperatura, simbolo)
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
        let temperatura = usarFahrenheit ? celsiusAFahrenheit(temp) : temp
        let simbolo = usarFahrenheit ? "°F" : "°C"
        return String(format: "%.0f%@", temperatura, simbolo)
    }
    // Función para convertir Celsius a Fahrenheit
    private func celsiusAFahrenheit(_ celsius: Double) -> Double {
        return (celsius * 9/5) + 32
    }

    // Función para alternar entre unidades
    func cambiarUnidad() {
        usarFahrenheit.toggle()
    }
}
