//
//  ContentView.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 16/09/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @State private var mostrarCambioCiudad = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo dinámico según el clima
                fondoDinamico
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    // Si está cargando
                    if viewModel.estaCargando {
                        VStack(spacing: 15) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text("Cargando clima...")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    }
                    
                    // Si hay error
                    else if let error = viewModel.mensajeError {
                        VStack(spacing: 15) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.yellow)
                            
                            Text(error)
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding()
                            
                            Button {
                                Task {
                                    await viewModel.buscarClima()
                                }
                            } label: {
                                Label("Reintentar", systemImage: "arrow.clockwise")
                                    .padding()
                                    .background(.white.opacity(0.2))
                                    .cornerRadius(10)
                            }
                            .foregroundColor(.white)
                        }
                        .padding()
                    }
                    
                    // Si hay datos del clima
                    else if let clima = viewModel.clima {
                        ScrollView {
                            VStack(spacing: 30) {
                                
                                // Ícono y temperatura principal
                                VStack(spacing: 10) {
                                    Image(systemName: obtenerIconoClima(codigo: clima.values.weatherCode))
                                        .font(.system(size: 100))
                                        .foregroundColor(.white)
                                        .shadow(radius: 10)
                                    
                                    Text(viewModel.temperaturaTexto)
                                        .font(.system(size: 70, weight: .thin))
                                        .foregroundColor(.white)
                                    
                                    Text("Sensación: \(viewModel.sensacionTermica)")
                                        .font(.title3)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    if let ultima = viewModel.ultimaActualizacion {
                                        Text("Actualizado \(tiempoTranscurrido(desde: ultima))")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                            .padding(.top, 5)
                                    }
                                }
                                .padding(.top, 30)
                                
                                // Tarjetas de información expandibles
                                VStack(spacing: 15) {
                                    HStack(spacing: 15) {
                                        // Humedad expandible
                                        TarjetaExpandible(
                                            titulo: "Humedad",
                                            icono: "drop.fill",
                                            valorPrincipal: viewModel.humedadTexto,
                                            detalles: [
                                                DetalleItem(
                                                    icono: "thermometer",
                                                    titulo: "Sensación térmica",
                                                    valor: viewModel.sensacionTermica
                                                ),
                                                DetalleItem(
                                                    icono: "cloud.fill",
                                                    titulo: "Punto de rocío",
                                                    valor: "~\(Int(clima.values.temperature - 5))°"
                                                )
                                            ],
                                            color: .cyan
                                        )
                                        
                                        // Viento expandible
                                        TarjetaExpandible(
                                            titulo: "Viento",
                                            icono: "wind",
                                            valorPrincipal: viewModel.vientoTexto,
                                            detalles: [
                                                DetalleItem(
                                                    icono: "thermometer",
                                                    titulo: "Sensación térmica",
                                                    valor: viewModel.sensacionTermica
                                                ),
                                                DetalleItem(
                                                    icono: "drop.fill",
                                                    titulo: "Humedad relativa",
                                                    valor: viewModel.humedadTexto
                                                )
                                            ],
                                            color: .mint
                                        )
                                    }
                                    
                                    HStack(spacing: 15) {
                                        // UV expandible
                                        TarjetaExpandible(
                                            titulo: "Índice UV",
                                            icono: "sun.max.fill",
                                            valorPrincipal: "\(clima.values.uvIndex)",
                                            detalles: [
                                                DetalleItem(
                                                    icono: "exclamationmark.triangle.fill",
                                                    titulo: "Nivel",
                                                    valor: obtenerNivelUV(uv: clima.values.uvIndex)
                                                ),
                                                DetalleItem(
                                                    icono: "clock.fill",
                                                    titulo: "Protección",
                                                    valor: obtenerProteccionUV(uv: clima.values.uvIndex)
                                                )
                                            ],
                                            color: .orange
                                        )
                                        
                                        // Clima expandible
                                        TarjetaExpandible(
                                            titulo: "Condiciones",
                                            icono: "cloud.fill",
                                            valorPrincipal: obtenerDescripcionClima(codigo: clima.values.weatherCode),
                                            detalles: [
                                                DetalleItem(
                                                    icono: "thermometer.medium",
                                                    titulo: "Temperatura",
                                                    valor: viewModel.temperaturaTexto
                                                ),
                                                DetalleItem(
                                                    icono: "eye.fill",
                                                    titulo: "Visibilidad",
                                                    valor: "Buena"
                                                )
                                            ],
                                            color: .purple
                                        )
                                    }
                                }
                                .padding(.horizontal)
                                
                                // Calidad del aire
                                CalidadAireView(calidadAire: viewModel.calidadAire)
                                    .padding(.top, 10)
                                
                                // Pronóstico por hora
                                if !viewModel.pronosticoHorario.isEmpty {
                                    PronosticoHorarioView(pronostico: viewModel.pronosticoHorario, usarFahrenheit: viewModel.usarFahrenheit)
                                        .padding(.top, 10)
                                }
                                
                                // Pronóstico semanal
                                if !viewModel.pronosticoSemanal.isEmpty {
                                    PronosticoSemanalView(pronostico: viewModel.pronosticoSemanal, usarFahrenheit: viewModel.usarFahrenheit)
                                        .padding(.top, 10)
                                }
                            }
                        }
                        .refreshable {
                            await viewModel.buscarClima()
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle(viewModel.nombreCiudadActual)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 10) {
                        // Botón para usar ubicación actual (GPS)
                        Button {
                            Task {
                                await viewModel.usarUbicacionActual()
                            }
                        } label: {
                            Image(systemName: viewModel.usandoUbicacionActual ? "location.fill" : "location")
                                .foregroundColor(viewModel.usandoUbicacionActual ? .green : .white)
                        }
                        
                        // Botón para agregar/quitar de favoritas
                        Button {
                            if viewModel.esCiudadFavorita() {
                                viewModel.eliminarDeFavoritas(viewModel.nombreCiudadActual)
                            } else {
                                viewModel.agregarAFavoritas()
                            }
                        } label: {
                            Image(systemName: viewModel.esCiudadFavorita() ? "star.fill" : "star")
                                .foregroundColor(viewModel.esCiudadFavorita() ? .yellow : .white)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 15) {
                        // Botón para cambiar unidad
                        Button {
                            viewModel.cambiarUnidad()
                        } label: {
                            Text(viewModel.usarFahrenheit ? "°F" : "°C")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .cornerRadius(8)
                        }
                        
                        // Botón para cambiar ciudad manualmente
                        Button {
                            mostrarCambioCiudad = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .sheet(isPresented: $mostrarCambioCiudad) {
                CambiarCiudadView(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.buscarClima()
        }
    }
    
    // Fondo que cambia según el clima
    private var fondoDinamico: some View {
        let colores: [Color]
        
        if let codigo = viewModel.clima?.values.weatherCode {
            switch codigo {
            case 1000: // Despejado
                colores = [.orange, .yellow, .pink]
            case 1100, 1101: // Parcialmente nublado
                colores = [.blue.opacity(0.7), .cyan, .white]
            case 1001, 1102: // Nublado
                colores = [.gray, .blue.opacity(0.5)]
            case 4000...4201: // Lluvia
                colores = [.blue.opacity(0.8), .indigo, .purple.opacity(0.6)]
            case 5000...5101: // Nieve
                colores = [.white, .cyan.opacity(0.5), .blue.opacity(0.3)]
            case 8000: // Tormenta
                colores = [.black.opacity(0.7), .purple.opacity(0.8), .indigo]
            default:
                colores = [.blue, .purple.opacity(0.7)]
            }
        } else {
            colores = [.blue, .purple.opacity(0.7)]
        }
        
        return LinearGradient(
            colors: colores,
            startPoint: .top,
            endPoint: .bottom
        )
        .animation(.easeInOut(duration: 1.0), value: viewModel.clima?.values.weatherCode)
    }
    
    // Función para obtener el ícono según el código
    func obtenerIconoClima(codigo: Int) -> String {
        switch codigo {
        case 1000: return "sun.max.fill"
        case 1100, 1101: return "cloud.sun.fill"
        case 1102: return "cloud.sun.rain.fill"
        case 1001: return "cloud.fill"
        case 2000, 2100: return "cloud.fog.fill"
        case 4000, 4001: return "cloud.drizzle.fill"
        case 4200, 4201: return "cloud.rain.fill"
        case 5000, 5001, 5100, 5101: return "snow"
        case 6000, 6001, 6200, 6201: return "cloud.sleet.fill"
        case 7000, 7101, 7102: return "cloud.hail.fill"
        case 8000: return "cloud.bolt.fill"
        default: return "cloud.fill"
        }
    }
    
    // Función para descripción del clima
    func obtenerDescripcionClima(codigo: Int) -> String {
        switch codigo {
        case 1000: return "Despejado"
        case 1100: return "Mayormente despejado"
        case 1101: return "Parcialmente nublado"
        case 1102: return "Mayormente nublado"
        case 1001: return "Nublado"
        case 2000, 2100: return "Niebla"
        case 4000, 4001: return "Llovizna"
        case 4200, 4201: return "Lluvia"
        case 5000, 5001, 5100, 5101: return "Nieve"
        case 8000: return "Tormenta"
        default: return "Variado"
        }
    }
    
    func tiempoTranscurrido(desde fecha: Date) -> String {
        let segundos = Int(Date().timeIntervalSince(fecha))
        
        if segundos < 60 {
            return "hace \(segundos)s"
        } else if segundos < 3600 {
            let minutos = segundos / 60
            return "hace \(minutos)m"
        } else if segundos < 86400 {
            let horas = segundos / 3600
            return "hace \(horas)h"
        } else {
            let dias = segundos / 86400
            return "hace \(dias)d"
        }
    }
    
    func obtenerNivelUV(uv: Int) -> String {
        switch uv {
        case 0...2: return "Bajo"
        case 3...5: return "Moderado"
        case 6...7: return "Alto"
        case 8...10: return "Muy Alto"
        default: return "Extremo"
        }
    }

    func obtenerProteccionUV(uv: Int) -> String {
        switch uv {
        case 0...2: return "No necesaria"
        case 3...5: return "Bloqueador SPF 15+"
        case 6...7: return "Bloqueador SPF 30+"
        default: return "Bloqueador SPF 50+"
        }
    }
}

// Vista reutilizable para las tarjetas de información
struct TarjetaInfo: View {
    let icono: String
    let titulo: String
    let valor: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icono)
                .font(.title)
                .foregroundColor(color)
            
            Text(titulo)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Text(valor)
                .font(.title3)
                .bold()
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
}

#Preview {
    ContentView(viewModel: WeatherViewModel())
}
