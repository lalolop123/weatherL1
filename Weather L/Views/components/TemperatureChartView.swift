//
//  TemperatureChartView.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 29/11/25.
//

import SwiftUI
import Charts

struct TemperatureChartView: View {
    let data: [WeatherStatistics.TemperaturePoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Temperatura de la Semana")
                .font(.headline)
                .foregroundColor(.white)
            
            Chart {
                ForEach(data) { point in
                    LineMark(
                        x: .value("Día", point.date, unit: .day),
                        y: .value("Temperatura", point.temperature)
                    )
                    .foregroundStyle(Color.orange.gradient)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Día", point.date, unit: .day),
                        y: .value("Temperatura", point.temperature)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let temp = value.as(Double.self) {
                            Text("\(Int(temp))°")
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        )
    }
}
