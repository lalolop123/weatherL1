//
//  SwiftUIView.swift
//  Weather L
//
//  Created by Maria Lopez Uresti on 29/11/25.
//

import SwiftUI

struct RecommendationCard: View {
    let recommendation: WeatherRecommendation
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: recommendation.icon)
                .font(.system(size: 35))
                .foregroundColor(categoryColor)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(categoryColor.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(recommendation.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(
                    colors: [categoryColor.opacity(0.2), categoryColor.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
        )
    }
    
    private var categoryColor: Color {
        switch recommendation.category {
        case .outdoor: return .green
        case .clothing: return .blue
        case .health: return .red
        case .general: return .orange
        }
    }
}
