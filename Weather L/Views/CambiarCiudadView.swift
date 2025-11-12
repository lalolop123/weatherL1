//
//  CambiarCiudadView.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 21/10/25.
//

import SwiftUI

struct CambiarCiudadView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @State private var ciudadTemporal = ""
    @Environment(\.dismiss) var dismiss
    
    let ciudadesDisponibles = [
        "Monterrey", "Ciudad de México", "CDMX", "Guadalajara",
        "Puebla", "Tijuana", "León", "Juárez", "Cancún", "Mérida",
        "Querétaro", "San Luis Potosí"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Botón grande para usar ubicación GPS
                Button {
                    Task {
                        await viewModel.usarUbicacionActual()
                        dismiss()
                    }
                } label: {
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.title2)
                        Text("Usar Mi Ubicación Actual")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Text("Selecciona una ciudad")
                    .font(.title2)
                    .bold()
                    .padding(.top)
                
                // Campo de texto
                TextField("Escribe una ciudad", text: $ciudadTemporal)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .autocapitalization(.words)
                
                // Lista de ciudades predefinidas
                List(ciudadesDisponibles, id: \.self) { ciudad in
                    Button {
                        viewModel.cambiarCiudad(a: ciudad)
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                            Text(ciudad)
                                .foregroundColor(.primary)
                            Spacer()
                            if viewModel.ciudadSeleccionada == ciudad {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                // Botón para confirmar ciudad escrita
                Button {
                    if !ciudadTemporal.isEmpty {
                        viewModel.cambiarCiudad(a: ciudadTemporal)
                        dismiss()
                    }
                } label: {
                    Text("Confirmar Ciudad")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ciudadTemporal.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(ciudadTemporal.isEmpty)
                .padding(.horizontal)
            }
            .navigationTitle("Cambiar Ciudad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CambiarCiudadView(viewModel: WeatherViewModel())
}
