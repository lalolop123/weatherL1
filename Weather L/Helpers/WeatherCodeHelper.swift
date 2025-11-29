//
//  WeatherCodeHelper.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 29/11/25.
//

import Foundation

struct WeatherCodeHelper {
    
    static func obtenerDescripcion(codigo: Int) -> String {
        switch codigo {
        case 1000: return "Despejado"
        case 1100: return "Mayormente despejado"
        case 1101: return "Parcialmente nublado"
        case 1102: return "Mayormente nublado"
        case 1001: return "Nublado"
        case 2000: return "Niebla"
        case 2100: return "Niebla ligera"
        case 4000: return "Llovizna"
        case 4001: return "Lluvia"
        case 4200: return "Lluvia ligera"
        case 4201: return "Lluvia fuerte"
        case 5000: return "Nieve"
        case 5001: return "Aguanieve"
        case 5100: return "Nieve ligera"
        case 5101: return "Nieve fuerte"
        case 6000: return "Lluvia engelante"
        case 6001: return "Lluvia engelante fuerte"
        case 6200: return "Lluvia engelante ligera"
        case 6201: return "Lluvia engelante fuerte"
        case 7000: return "Granizo"
        case 7101: return "Granizo fuerte"
        case 7102: return "Granizo ligero"
        case 8000: return "Tormenta eléctrica"
        default: return "Desconocido"
        }
    }
    
    static func obtenerIcono(codigo: Int) -> String {
        switch codigo {
        case 1000: return "sun.max.fill"
        case 1100: return "sun.max"
        case 1101: return "cloud.sun.fill"
        case 1102: return "cloud.sun"
        case 1001: return "cloud.fill"
        case 2000, 2100: return "cloud.fog.fill"
        case 4000, 4200: return "cloud.drizzle.fill"
        case 4001, 4201: return "cloud.rain.fill"
        case 5000, 5100, 5101: return "cloud.snow.fill"
        case 5001: return "cloud.sleet.fill"
        case 6000, 6001, 6200, 6201: return "cloud.hail.fill"
        case 7000, 7101, 7102: return "cloud.hail.fill"
        case 8000: return "cloud.bolt.fill"
        default: return "questionmark.circle.fill"
        }
    }
}
