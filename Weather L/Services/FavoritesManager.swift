//
//  Favorites.swift
//  Weather L
//
//  Created by Alumno on 11/11/25.
//

import Foundation

class FavoritesManager {
    
    // Singleton para acceso global
    static let shared = FavoritesManager()
    
    private let defaults = UserDefaults.standard
    private let favoritasKey = "ciudadesFavoritas"
    private let ultimaCiudadKey = "ultimaCiudad"
    private let unidadTemperaturaKey = "usarFahrenheit"
    
    private init() {}
    
    // Ciudades Favoritas
    
    // Guardar lista completa de favoritas
    func guardarFavoritas(_ ciudades: [String]) {
        defaults.set(ciudades, forKey: favoritasKey)
        print("💾 Favoritas guardadas: \(ciudades)")
    }
    
    // Cargar lista de favoritas
    func cargarFavoritas() -> [String] {
        let favoritas = defaults.stringArray(forKey: favoritasKey) ?? ["Monterrey"]
        print("📂 Favoritas cargadas: \(favoritas)")
        return favoritas
    }
    
    // Agregar una ciudad a favoritas
    func agregarFavorita(_ ciudad: String) {
        var favoritas = cargarFavoritas()
        
        // Verificar que no esté duplicada
        if !favoritas.contains(ciudad) {
            favoritas.append(ciudad)
            guardarFavoritas(favoritas)
            print("⭐ Ciudad agregada a favoritas: \(ciudad)")
        } else {
            print("ℹ️ La ciudad ya está en favoritas: \(ciudad)")
        }
    }
    
    // Eliminar una ciudad de favoritas
    func eliminarFavorita(_ ciudad: String) {
        var favoritas = cargarFavoritas()
        favoritas.removeAll { $0 == ciudad }
        guardarFavoritas(favoritas)
        print("🗑️ Ciudad eliminada de favoritas: \(ciudad)")
    }
    
    // Verificar si una ciudad es favorita
    func esFavorita(_ ciudad: String) -> Bool {
        let favoritas = cargarFavoritas()
        return favoritas.contains(ciudad)
    }
    
    
    
    // Guardar la última ciudad consultada
    func guardarUltimaCiudad(_ ciudad: String) {
        defaults.set(ciudad, forKey: ultimaCiudadKey)
        print("💾 Última ciudad guardada: \(ciudad)")
    }
    
    // Cargar la última ciudad consultada
    func cargarUltimaCiudad() -> String {
        let ciudad = defaults.string(forKey: ultimaCiudadKey) ?? "Monterrey"
        print("📂 Última ciudad cargada: \(ciudad)")
        return ciudad
    }
    
    
    
    // Guardar preferencia °C o °F
    func guardarPreferenciaUnidad(_ usarFahrenheit: Bool) {
        defaults.set(usarFahrenheit, forKey: unidadTemperaturaKey)
        print("💾 Unidad guardada: \(usarFahrenheit ? "°F" : "°C")")
    }
    
    // Cargar preferencia de unidad
    func cargarPreferenciaUnidad() -> Bool {
        let usarF = defaults.bool(forKey: unidadTemperaturaKey)
        print("📂 Unidad cargada: \(usarF ? "°F" : "°C")")
        return usarF
    }
    

    
    // Eliminar todos los datos guardados
    func limpiarTodo() {
        defaults.removeObject(forKey: favoritasKey)
        defaults.removeObject(forKey: ultimaCiudadKey)
        defaults.removeObject(forKey: unidadTemperaturaKey)
        print("🗑️ Todos los datos eliminados")
    }
}
