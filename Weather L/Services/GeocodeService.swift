//
//  GeocodeService.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 21/10/25.
//
import Foundation
import CoreLocation

class GeocodeService {
    
    // Función para convertir nombre de ciudad a coordenadas
    func obtenerCoordenadas(ciudad: String) async throws -> (lat: Double, lon: Double, nombre: String) {
        
        print("🔍 Geocodificando: \(ciudad)")
        
        return try await withCheckedThrowingContinuation { continuation in
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(ciudad) { placemarks, error in
                
                if let error = error {
                    print("❌ Error geocodificando: \(error.localizedDescription)")
                    continuation.resume(throwing: WeatherError.ciudadInvalida)
                    return
                }
                
                guard let placemark = placemarks?.first,
                      let location = placemark.location else {
                    print("❌ No se encontró la ciudad")
                    continuation.resume(throwing: WeatherError.ciudadInvalida)
                    return
                }
                
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                let nombre = placemark.locality ?? ciudad
                
                print("✅ Coordenadas encontradas: \(lat), \(lon) - \(nombre)")
                continuation.resume(returning: (lat, lon, nombre))
            }
        }
    }
}
