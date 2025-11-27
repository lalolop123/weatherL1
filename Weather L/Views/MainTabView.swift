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
            
            // Tab 2: Favoritos
            FavoritosView(viewModel: viewModel)
                .tabItem {
                    Label("Favoritos", systemImage: "star.fill")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
}
