//
//  StatisticsView.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 29/11/25.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    @ObservedObject var weatherViewModel: WeatherViewModel
    
    var body: some View {
        ZStack {
            // Fondo con gradiente
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.45),
                    Color(red: 0.2, green: 0.3, blue: 0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView("Generando estadísticas...")
                    .foregroundColor(.white)
            } else if let statistics = viewModel.statistics {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        headerView(cityName: statistics.cityName)
                        
                        // Gráfica de temperatura
                        if !statistics.temperatureData.isEmpty {
                            TemperatureChartView(data: statistics.temperatureData)
                                .padding(.horizontal)
                        }
                        
                        // Cards de estadísticas principales
                        statsCardsView(statistics: statistics)
                        
                        // Comparación de ciudades favoritas
                        if !viewModel.comparisons.isEmpty {
                            cityComparisonsView
                        }
                        
                        // Recomendaciones
                        if !viewModel.recommendations.isEmpty {
                            recommendationsView
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.top)
                }
            } else {
                emptyStateView
            }
        }
        .onAppear {
            loadStatistics()
        }
        .onChange(of: weatherViewModel.nombreCiudadActual) { oldValue, newValue in
            loadStatistics()
        }
    }
    
    // MARK: - Subvistas
    
    private func headerView(cityName: String) -> some View {
        VStack(spacing: 8) {
            Text("Análisis y Estadísticas")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(cityName)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
            
            if let ultimaActualizacion = weatherViewModel.ultimaActualizacion {
                Text("Actualizado: \(formatearFecha(ultimaActualizacion))")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding()
    }
    
    private func statsCardsView(statistics: WeatherStatistics) -> some View {
        VStack(spacing: 12) {
            Text("Estadísticas de la Semana")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "Promedio",
                    value: formatTemp(statistics.averageTemp),
                    icon: "thermometer.medium",
                    color: .orange
                )
                
                StatCard(
                    title: "Máxima",
                    value: formatTemp(statistics.maxTemp),
                    icon: "thermometer.sun.fill",
                    color: .red
                )
                
                StatCard(
                    title: "Mínima",
                    value: formatTemp(statistics.minTemp),
                    icon: "thermometer.snowflake",
                    color: .blue
                )
                
                StatCard(
                    title: "Humedad",
                    value: String(format: "%.0f%%", statistics.humidity),
                    icon: "humidity.fill",
                    color: .cyan
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var cityComparisonsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Comparación de Ciudades")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ForEach(viewModel.comparisons) { comparison in
                HStack(spacing: 15) {
                    Image(systemName: comparison.icon)
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .frame(width: 50)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(comparison.cityName)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(comparison.condition)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text(formatTemp(comparison.currentTemp))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.1))
                )
                .padding(.horizontal)
            }
        }
    }
    
    private var recommendationsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recomendaciones")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ForEach(viewModel.recommendations) { recommendation in
                RecommendationCard(recommendation: recommendation)
                    .padding(.horizontal)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.5))
            
            Text("No hay datos disponibles")
                .font(.title3)
                .foregroundColor(.white)
            
            Text("Busca el clima de una ciudad para ver las estadísticas")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                loadStatistics()
            }) {
                Text("Cargar Estadísticas")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.blue)
                    )
            }
        }
    }
    
    // MARK: - Funciones Helper
    
    private func loadStatistics() {
        guard !weatherViewModel.pronosticoSemanal.isEmpty else {
            print("⚠️ No hay pronóstico disponible")
            return
        }
        
        // Generar estadísticas
        viewModel.generateStatistics(
            for: weatherViewModel.nombreCiudadActual,
            forecast: weatherViewModel.pronosticoSemanal
        )
        
        // Generar comparaciones si hay favoritas
        if !weatherViewModel.ciudadesFavoritas.isEmpty {
            Task {
                await viewModel.generateComparisons(favorites: weatherViewModel.ciudadesFavoritas)
            }
        }
    }
    
    private func formatTemp(_ temp: Double) -> String {
        let temperatura = weatherViewModel.usarFahrenheit ?
            (temp * 9/5) + 32 : temp
        let simbolo = weatherViewModel.usarFahrenheit ? "°F" : "°C"
        return String(format: "%.0f%@", temperatura, simbolo)
    }
    
    private func formatearFecha(_ fecha: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: fecha)
    }
}
