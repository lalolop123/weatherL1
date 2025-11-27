//
//  PronosticoHorarioView.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 27/11/25.
//

import SwiftUI

struct PronosticoHorarioView: View {
    let pronostico: [HourlyForecast]
    let usarFahrenheit: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Próximas 24 horas")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(pronostico.enumerated()), id: \.offset) { index, hora in
                        TarjetaHora(hora: hora, index: index, usarFahrenheit: usarFahrenheit)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct TarjetaHora: View {
    let hora: HourlyForecast
    let index: Int
    let usarFahrenheit: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(horaFormateada)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
            
            Image(systemName: obtenerIconoClima(codigo: hora.values.weatherCode))
                .font(.title2)
                .foregroundColor(.white)
            
            Text(temperaturaTexto)
                .font(.headline)
                .bold()
                .foregroundColor(.white)
            
            HStack(spacing: 3) {
                Image(systemName: "drop.fill")
                    .font(.caption2)
                Text("\(Int(hora.values.precipitationProbability))%")
                    .font(.caption2)
            }
            .foregroundColor(.cyan)
        }
        .frame(width: 70)
        .padding(.vertical, 12)
        .background(
            index == 0 ?
            LinearGradient(colors: [.blue.opacity(0.6), .cyan.opacity(0.4)], startPoint: .top, endPoint: .bottom) :
                LinearGradient(colors: [.white.opacity(0.15)], startPoint: .top, endPoint: .bottom)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(index == 0 ? Color.cyan : Color.clear, lineWidth: 1.5)
        )
    }
    
    var horaFormateada: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let fecha = formatter.date(from: hora.time) else {
            return "--:--"
        }
        
        if index == 0 {
            return "Ahora"
        }
        
        let horaFormatter = DateFormatter()
        horaFormatter.dateFormat = "HH:mm"
        horaFormatter.timeZone = TimeZone.current
        return horaFormatter.string(from: fecha)
    }
    
    var temperaturaTexto: String {
        let temp = usarFahrenheit ? celsiusAFahrenheit(hora.values.temperature) : hora.values.temperature
        let simbolo = usarFahrenheit ? "°F" : "°C"
        return String(format: "%.0f%@", temp, simbolo)
    }
    
    private func celsiusAFahrenheit(_ celsius: Double) -> Double {
        return (celsius * 9/5) + 32
    }
    
    func obtenerIconoClima(codigo: Int) -> String {
        switch codigo {
        case 1000: return "sun.max.fill"
        case 1100, 1101: return "cloud.sun.fill"
        case 1102: return "cloud.sun.rain.fill"
        case 1001: return "cloud.fill"
        case 4000...4201: return "cloud.rain.fill"
        case 5000...5101: return "snow"
        case 8000: return "cloud.bolt.fill"
        default: return "cloud.fill"
        }
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        PronosticoHorarioView(pronostico: [], usarFahrenheit: false)
    }
}
