//
//  Locationmanager.swift
//  Weather L
//
//  Created by Alumno on 11/11/25.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    
    // Gestor de ubicación de iOS
    private let locationManager = CLLocationManager()
    
    // Estados publicados
    @Published var ubicacionActual: CLLocation?
    @Published var estadoAutorizacion: CLAuthorizationStatus = .notDetermined
    @Published var errorUbicacion: String?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        estadoAutorizacion = locationManager.authorizationStatus
    }
    
    // Solicitar permisos de ubicación
    func solicitarPermiso() {
        print("📍 Solicitando permiso de ubicación...")
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Obtener ubicación actual
    func obtenerUbicacion() {
        print("📍 Obteniendo ubicación actual...")
        
        // Verificar que tenemos permiso
        guard estadoAutorizacion == .authorizedWhenInUse || estadoAutorizacion == .authorizedAlways else {
            errorUbicacion = "Necesitas dar permiso de ubicación en Ajustes"
            print("❌ No hay permiso de ubicación")
            return
        }
        
        locationManager.requestLocation()
    }
    
    // Convertir coordenadas a nombre de ciudad
    func obtenerNombreCiudad(de ubicacion: CLLocation) async throws -> String {
        print("🔍 Convirtiendo coordenadas a ciudad...")
        
        return try await withCheckedThrowingContinuation { continuation in
            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(ubicacion) { placemarks, error in
                if let error = error {
                    print("❌ Error geocodificando: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    print("❌ No se encontró información de la ubicación")
                    continuation.resume(throwing: NSError(domain: "LocationManager", code: 1))
                    return
                }
                
                let ciudad = placemark.locality ?? placemark.name ?? "Ubicación Desconocida"
                print("✅ Ciudad encontrada: \(ciudad)")
                continuation.resume(returning: ciudad)
            }
        }
    }
}

// Delegado de CLLocationManager
extension LocationManager: CLLocationManagerDelegate {
    
    // Se llama cuando cambia el estado de autorización
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        estadoAutorizacion = manager.authorizationStatus
        print("📍 Estado de autorización cambió a: \(estadoAutorizacion.rawValue)")
        
        // Si nos dan permiso, obtener ubicación automáticamente
        if estadoAutorizacion == .authorizedWhenInUse || estadoAutorizacion == .authorizedAlways {
            obtenerUbicacion()
        }
    }
    
    // Se llama cuando se obtiene la ubicación exitosamente
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let ubicacion = locations.last else { return }
        
        print("✅ Ubicación obtenida: \(ubicacion.coordinate.latitude), \(ubicacion.coordinate.longitude)")
        ubicacionActual = ubicacion
        errorUbicacion = nil
    }
    
    // Se llama cuando hay un error al obtener ubicación
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Error obteniendo ubicación: \(error.localizedDescription)")
        errorUbicacion = "No se pudo obtener tu ubicación. Verifica que tengas GPS activado."
    }
}
