//
//  ContentView.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 16/09/25.
//

import SwiftUI

// 1) Enum de unidad (para Picker y comparación)
enum TemperatureUnit: String, CaseIterable, Hashable {
    case celsius, fahrenheit
}

// 2) Modelo de pronóstico por día (en °C)
struct DayForecast: Identifiable {
    let id = UUID()
    let day: String
    let iconName: String
    let tempCelsius: Double
}

// 3) Modelo de pronóstico por hora (en °C)
struct HourForecast: Identifiable {
    let id = UUID()
    let hour: String      // "00:00" ... "23:00"
    let iconName: String
    let tempCelsius: Double
}

// 4) Cabecera de clima actual
struct CurrentWeatherView: View {
    let city: String
    let tempCelsius: Double
    let iconName: String
    let unit: TemperatureUnit

    private var displayedTemp: String {
        let value = unit == .celsius ? tempCelsius : tempCelsius * 9 / 5 + 32
        let symbol = unit == .celsius ? "°C" : "°F"
        return "\(Int(value))\(symbol)"
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(city)
                .font(.largeTitle)
                .foregroundColor(.white)
                .bold()

            Text(displayedTemp)
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(.white)

            Image(systemName: iconName)
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 80))
        }
        .padding(.top, 8)
    }
}

// 5) Barra horizontal de pronóstico semanal
struct WeeklyForecastView: View {
    let forecasts: [DayForecast]
    let unit: TemperatureUnit

    private func format(_ tempC: Double) -> String {
        let value = unit == .celsius ? tempC : tempC * 9 / 5 + 32
        let symbol = unit == .celsius ? "°C" : "°F"
        return "\(Int(value))\(symbol)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pronóstico semanal")
                .foregroundColor(.white)
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(forecasts) { f in
                        VStack(spacing: 8) {
                            Text(f.day)
                                .foregroundColor(.white)
                                .font(.headline)

                            Image(systemName: f.iconName)
                                .foregroundColor(.white)
                                .font(.title)

                            Text(format(f.tempCelsius))
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// 6) Pronóstico por hora (24 horas)
struct HourlyForecastView: View {
    let hours: [HourForecast]
    let unit: TemperatureUnit

    private func format(_ tempC: Double) -> String {
        let value = unit == .celsius ? tempC : tempC * 9 / 5 + 32
        let symbol = unit == .celsius ? "°C" : "°F"
        return "\(Int(value))\(symbol)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pronóstico por hora")
                .foregroundColor(.white)
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(hours) { h in
                        VStack(spacing: 8) {
                            Text(h.hour)
                                .foregroundColor(.white)
                                .font(.subheadline)

                            Image(systemName: h.iconName)
                                .foregroundColor(.white)
                                .font(.title3)

                            Text(format(h.tempCelsius))
                                .foregroundColor(.white)
                                .font(.footnote)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 10)
                        .background(Color.white.opacity(0.18))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 8)
    }
}

// 7) Modal para cambiar ciudad
struct ChangeCityView: View {
    @Binding var currentCity: String
    @Binding var isPresented: Bool
    @State private var draftCity: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Nueva ciudad")) {
                    TextField("Escribe el nombre", text: $draftCity)
                        .textInputAutocapitalization(.words)
                }
            }
            .navigationTitle("Cambiar ciudad")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        currentCity = draftCity.trimmingCharacters(in: .whitespaces)
                        isPresented = false
                    }
                    .disabled(draftCity.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { draftCity = currentCity }
        }
    }
}

// 8) Modal de ajustes (°C / °F)
struct SettingsView: View {
    @Binding var unit: TemperatureUnit
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Unidad de temperatura")) {
                    Picker("Unidad", selection: $unit) {
                        Text("Celsius (°C)").tag(TemperatureUnit.celsius)
                        Text("Fahrenheit (°F)").tag(TemperatureUnit.fahrenheit)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Ajustes")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Hecho") { isPresented = false }
                }
            }
        }
    }
}

// 9) Generador de 24 horas (00:00–23:00) con íconos básicos y temps de ejemplo
func makeFullDayHourlyData(baseTempC: Double = 26) -> [HourForecast] {
    (0..<24).map { hour in
        // Oscilación simple de temperatura a lo largo del día
        // más fresco de madrugada, más cálido a media tarde
        let variation = -4 * cos((Double(hour) - 15) / 24.0 * 2 * .pi) // pico aprox 15:00
        let temp = baseTempC + variation

        // Ícono aproximado según hora
        let isNight = hour < 6 || hour >= 20
        let icon: String
        if isNight {
            icon = hour < 20 ? "moon.stars.fill" : "moon.stars.fill"
        } else if (9...16).contains(hour) {
            icon = "sun.max.fill"
        } else {
            icon = "cloud.sun.fill"
        }

        return HourForecast(
            hour: String(format: "%02d:00", hour),
            iconName: icon,
            tempCelsius: temp
        )
    }
}

// 10) Vista principal con Scroll vertical
struct ContentView: View {
    @State private var currentCity = "Monterrey"
    @State private var showChangeCity = false
    @State private var showSettings = false
    @State private var unit: TemperatureUnit = .celsius

    // Datos de ejemplo
    let forecastData = [
        DayForecast(day: "Dom", iconName: "cloud.fill", tempCelsius: 26),
        DayForecast(day: "Lun", iconName: "cloud.sun.fill", tempCelsius: 28),
        DayForecast(day: "Mar", iconName: "sun.max.fill", tempCelsius: 30),
        DayForecast(day: "Mié", iconName: "cloud.rain.fill", tempCelsius: 24),
        DayForecast(day: "Jue", iconName: "cloud.bolt.fill", tempCelsius: 22),
        DayForecast(day: "Vie", iconName: "cloud.fog.fill", tempCelsius: 23),
        DayForecast(day: "Sáb", iconName: "cloud.sun.fill", tempCelsius: 27)
    ]

    // 24 horas del día
    let hourlyData: [HourForecast] = makeFullDayHourlyData(baseTempC: 26)

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .cyan]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 24) {
                        CurrentWeatherView(
                            city: currentCity,
                            tempCelsius: 28,
                            iconName: "cloud.sun.fill",
                            unit: unit
                        )

                        WeeklyForecastView(
                            forecasts: forecastData,
                            unit: unit
                        )

                        HourlyForecastView(
                            hours: hourlyData,
                            unit: unit
                        )

                        Button("Cambiar ciudad") {
                            showChangeCity = true
                        }
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationTitle("☀️ WeatherL")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.blue.opacity(0.25), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showChangeCity) {
                ChangeCityView(currentCity: $currentCity, isPresented: $showChangeCity)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(unit: $unit, isPresented: $showSettings)
            }
        }
    }
}

#Preview {
    ContentView()
}
