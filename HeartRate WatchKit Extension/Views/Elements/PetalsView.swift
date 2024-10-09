//
//  PetalsView.swift
//  HeartRate
//
//  Created by Clair Mutebi on 09/10/2024.
//
import SwiftUI

struct PetalView: View {
    var angle: Double // Angle at which the petal is positioned around the center
    var petalColor: Color // Color of the petal
    @Binding var isVisible: Bool // Binding to track visibility

    var body: some View {
        if isVisible {
            Ellipse()
                .fill(petalColor)
                .frame(width: 20, height: 50) // Elongated petal shape
                .offset(x: CGFloat(cos(angle) * 80), y: CGFloat(sin(angle) * 80)) // Position petals in circular pattern
                .rotationEffect(.degrees(angle * 180 / .pi)) // Rotate each petal to face outward
                .onTapGesture {
                    // When tapped, make the petal disappear
                    isVisible = false
                }
                .animation(.easeInOut, value: isVisible) // Smooth disappearing animation
        }
    }
}
