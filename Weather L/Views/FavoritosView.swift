//
//  FavoritosView.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 27/11/25.
//

import SwiftUI

struct FavoritosView: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.6), .purple.opacity(0.4)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if viewModel.ciudadesFavoritas.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "star.slash")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("No tienes ciudades favoritas")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("Agrega ciudades tocando la ⭐ en la pantalla principal")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(viewModel.ciudadesFavoritas, id: \.self) { ciudad in
                                Button {
                                    viewModel.seleccionarFavorita(ciudad)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 5) {
                                            HStack {
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                                Text(ciudad)
                                                    .font(.title3)
                                                    .bold()
                                                    .foregroundColor(.white)
                                            }
                                            
                                            if viewModel.nombreCiudadActual == ciudad {
                                                Text("Ciudad actual")
                                                    .font(.caption)
                                                    .foregroundColor(.green)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Button {
                                            withAnimation {
                                                viewModel.eliminarDeFavoritas(ciudad)
                                            }
                                        } label: {
                                            Image(systemName: "trash.fill")
                                                .foregroundColor(.red.opacity(0.8))
                                                .padding(10)
                                                .background(.ultraThinMaterial)
                                                .clipShape(Circle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(15)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Favoritos")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    FavoritosView(viewModel: WeatherViewModel())
}
