//
//  PronosticoSemanalView.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 21/10/25.
//

import SwiftUI

struct PronosticoSemanalView: View {
    let pronostico: [DailyForecast]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Pronóstico de 7 días")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(Array(pronostico.enumerated()), id: \.offset) { index, dia in
                        TarjetaDia(dia: dia, index: index)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct TarjetaDia: View {
    let dia: DailyForecast
    let index: Int
    
    var body: some View {
        VStack(spacing: 10) {
            Text(nombreDia)
                .font(.headline)
                .foregroundColor(.white)
            
            Image(systemName: obtenerIconoClima(codigo: dia.values.weatherCode))
                .font(.system(size: 40))
                .foregroundColor(.white)
            
            VStack(spacing: 5) {
                Text("\(Int(dia.values.temperatureMax))°")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                
                Text("\(Int(dia.values.temperatureMin))°")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            HStack(spacing: 3) {
                Image(systemName: "drop.fill")
                    .font(.caption)
                Text("\(Int(dia.values.precipitationProbability))%")
                    .font(.caption)
            }
            .foregroundColor(.cyan)
        }
        .frame(width: 100)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
    
    var nombreDia: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.locale = Locale(identifier: "es_MX")
        
        guard let fecha = formatter.date(from: dia.time) else {
            return "---"
        }
        
        if index == 0 {
            return "Hoy"
        } else if index == 1 {
            return "Mañana"
        }
        
        let diaSemana = DateFormatter()
        diaSemana.locale = Locale(identifier: "es_MX")
        diaSemana.dateFormat = "EEE"
        return diaSemana.string(from: fecha).capitalized
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
        PronosticoSemanalView(pronostico: [])
    }
}
