//
//  TarjetaExpandible.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 27/11/25.
//

import SwiftUI

struct TarjetaExpandible: View {
    let titulo: String
    let icono: String
    let valorPrincipal: String
    let detalles: [DetalleItem]
    let color: Color
    
    @State private var expandida = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Contenido principal (siempre visible)
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    expandida.toggle()
                }
            } label: {
                HStack {
                    VStack(spacing: 8) {
                        Image(systemName: icono)
                            .font(.title)
                            .foregroundColor(color)
                        
                        Text(titulo)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(valorPrincipal)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Indicador de expandir/contraer
                    Image(systemName: expandida ? "chevron.up.circle.fill" : "chevron.down.circle")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.title3)
                        .padding(.trailing, 8)
                }
            }
            .buttonStyle(.plain)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(expandida ? 15 : 15, corners: expandida ? [.topLeft, .topRight] : .allCorners)
            
            // Detalles expandibles
            if expandida {
                VStack(spacing: 12) {
                    ForEach(detalles) { detalle in
                        HStack {
                            Image(systemName: detalle.icono)
                                .foregroundColor(color.opacity(0.8))
                                .frame(width: 25)
                            
                            Text(detalle.titulo)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Spacer()
                            
                            Text(detalle.valor)
                                .bold()
                                .foregroundColor(.white)
                        }
                        .font(.subheadline)
                        
                        if detalle.id != detalles.last?.id {
                            Divider()
                                .background(.white.opacity(0.2))
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial.opacity(0.8))
                .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .cornerRadius(15)
    }
}

// Modelo para los detalles
struct DetalleItem: Identifiable {
    let id = UUID()
    let icono: String
    let titulo: String
    let valor: String
}

// Extension para redondear esquinas específicas
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        TarjetaExpandible(
            titulo: "Humedad",
            icono: "drop.fill",
            valorPrincipal: "65%",
            detalles: [
                DetalleItem(icono: "thermometer", titulo: "Punto de rocío", valor: "18°C"),
                DetalleItem(icono: "wind", titulo: "Presión", valor: "1013 hPa"),
                DetalleItem(icono: "eye", titulo: "Visibilidad", valor: "10 km")
            ],
            color: .cyan
        )
        .padding()
    }
}
