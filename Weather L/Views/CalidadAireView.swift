//
//  CalidadAireView.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 21/10/25.
//

import SwiftUI

struct CalidadAireView: View {
    let calidadAire: AirQualityValues?
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "aqi.medium")
                    .font(.title2)
                    .foregroundColor(colorCalidad)
                
                Text("Calidad del Aire")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            if let pm25 = calidadAire?.particulateMatter25 {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(nivelCalidad)
                            .font(.title3)
                            .bold()
                            .foregroundColor(colorCalidad)
                        
                        Spacer()
                        
                        Text("EPA: \(calidadAire?.epaIndex ?? 0)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("PM2.5")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Text(String(format: "%.1f", pm25))
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                            Text("μg/m³")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Image(systemName: iconoRecomendacion)
                                .font(.system(size: 30))
                                .foregroundColor(colorCalidad)
                        }
                    }
                    
                    Text(recomendacion)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 5)
                }
            } else {
                Text("No hay datos de calidad del aire disponibles")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .padding(.horizontal)
    }
    
    var nivelCalidad: String {
        guard let pm25 = calidadAire?.particulateMatter25 else { return "N/A" }
        switch pm25 {
        case 0..<12: return "Buena"
        case 12..<35: return "Moderada"
        case 35..<55: return "Dañina para grupos sensibles"
        case 55..<150: return "Dañina"
        case 150..<250: return "Muy dañina"
        default: return "Peligrosa"
        }
    }
    
    var colorCalidad: Color {
        guard let pm25 = calidadAire?.particulateMatter25 else { return .gray }
        switch pm25 {
        case 0..<12: return .green
        case 12..<35: return .yellow
        case 35..<55: return .orange
        case 55..<150: return .red
        default: return .purple
        }
    }
    
    var iconoRecomendacion: String {
        guard let pm25 = calidadAire?.particulateMatter25 else { return "questionmark" }
        switch pm25 {
        case 0..<35: return "figure.walk"
        case 35..<55: return "figure.walk.arrival"
        default: return "exclamationmark.triangle.fill"
        }
    }
    
    var recomendacion: String {
        guard let pm25 = calidadAire?.particulateMatter25 else { return "" }
        switch pm25 {
        case 0..<12: return "Excelente para actividades al aire libre"
        case 12..<35: return "Calidad aceptable. Grupos sensibles deben limitar actividad prolongada"
        case 35..<55: return "Grupos sensibles pueden experimentar problemas de salud"
        case 55..<150: return "Toda la población puede experimentar efectos. Limita actividad exterior"
        default: return "Evita salir. Muy peligroso para toda la población"
        }
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        CalidadAireView(calidadAire: nil)    }
}
