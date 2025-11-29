//
//  MainTabView.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 27/11/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = WeatherViewModel()
    
    var body: some View {
        TabView {
            // Tab 1: Clima Principal
            ContentView(viewModel: viewModel)
                .tabItem {
                    Label("Clima", systemImage: "cloud.sun.fill")
                }
            
            // Tab 2: Favoritas
            FavoritosView(viewModel: viewModel)
                .tabItem {
                    Label("Favoritas", systemImage: "star.fill")
                }
            
            // Tab 3: Estadísticas
            StatisticsView(weatherViewModel: viewModel)
                .tabItem {
                    Label("Estadísticas", systemImage: "chart.bar.fill")
                }
        }
        .tint(.white) // Color de los íconos seleccionados
    }
}

#Preview {
    MainTabView()
}
