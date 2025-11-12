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
    private let favoritesManager = FavoritesManager.shared
    private let servicio = WeatherService()
    private let airQualityService = AirQualityService()

    
    @Published var clima: WeatherDataTimeline?
    @Published var estaCargando = false
    @Published var mensajeError: String?
    @Published var ciudadSeleccionada = "Monterrey"
    @Published var nombreCiudadActual = "Monterrey"
    @Published var pronosticoSemanal: [DailyForecast] = []
    @Published var calidadAire: AirQualityValues?
    @Published var usarFahrenheit = false
    @Published var ubicacion: Location?
    @Published var locationManager = LocationManager()
    @Published var usandoUbicacionActual = false
    @Published var ciudadesFavoritas: [String] = []

    
    init() {
        
        ciudadesFavoritas = favoritesManager.cargarFavoritas()
        usarFahrenheit = favoritesManager.cargarPreferenciaUnidad()
        ciudadSeleccionada = favoritesManager.cargarUltimaCiudad()
        nombreCiudadActual = ciudadSeleccionada
        
        print("✅ ViewModel inicializado con datos guardados")
    }
    
    
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
        favoritesManager.guardarUltimaCiudad(nuevaCiudad)
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
        favoritesManager.guardarPreferenciaUnidad(usarFahrenheit)
    }
    // Función para usar ubicación actual del GPS
    func usarUbicacionActual() async {
        print("📍 Iniciando proceso de ubicación actual...")
        
        // Si no hay permiso, solicitarlo
        if locationManager.estadoAutorizacion == .notDetermined {
            locationManager.solicitarPermiso()
            // Esperar un momento para que el usuario responda
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo
        }
        
        // Verificar que tengamos permiso
        guard locationManager.estadoAutorizacion == .authorizedWhenInUse ||
              locationManager.estadoAutorizacion == .authorizedAlways else {
            mensajeError = "Necesitas dar permiso de ubicación en Ajustes de iOS"
            print("❌ No hay permiso de ubicación")
            return
        }
        
        estaCargando = true
        
        // Obtener ubicación
        locationManager.obtenerUbicacion()
        
        // Esperar a que se obtenga la ubicación (máximo 5 segundos)
        var intentos = 0
        while locationManager.ubicacionActual == nil && intentos < 10 {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos
            intentos += 1
        }
        
        guard let ubicacion = locationManager.ubicacionActual else {
            mensajeError = locationManager.errorUbicacion ?? "No se pudo obtener tu ubicación"
            estaCargando = false
            print("❌ No se obtuvo ubicación después de esperar")
            return
        }
        
        // Convertir coordenadas a nombre de ciudad
        do {
            let nombreCiudad = try await locationManager.obtenerNombreCiudad(de: ubicacion)
            print("✅ Cambiando a ciudad detectada: \(nombreCiudad)")
            
            usandoUbicacionActual = true
            ciudadSeleccionada = nombreCiudad
            
            // Buscar clima de la ciudad detectada
            await buscarClima()
            
        } catch {
            mensajeError = "No se pudo identificar tu ciudad"
            estaCargando = false
            print("❌ Error identificando ciudad: \(error)")
        }
    }
    
    // Gestion de ciudades favoritas 
    // Agregar ciudad actual a favoritas
    func agregarAFavoritas() {
        favoritesManager.agregarFavorita(nombreCiudadActual)
        ciudadesFavoritas = favoritesManager.cargarFavoritas()
    }

    // Eliminar una ciudad de favoritas
    func eliminarDeFavoritas(_ ciudad: String) {
        favoritesManager.eliminarFavorita(ciudad)
        ciudadesFavoritas = favoritesManager.cargarFavoritas()
    }

    // Verificar si la ciudad actual es favorita
    func esCiudadFavorita() -> Bool {
        return favoritesManager.esFavorita(nombreCiudadActual)
    }

    // Seleccionar una ciudad favorita
    func seleccionarFavorita(_ ciudad: String) {
        cambiarCiudad(a: ciudad)
    }
}
