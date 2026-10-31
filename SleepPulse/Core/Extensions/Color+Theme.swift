//
//  Color+Theme.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import SwiftUI

public extension Color {
    static let appBackground = Color(red: 0.05, green: 0.07, blue: 0.11)
    static let cardBackground = Color(red: 0.10, green: 0.13, blue: 0.19)
    static let cardBorder = Color(white: 0.20).opacity(0.35)
    
    // Métricas temáticas
    static let performanceAccent = Color(red: 0.35, green: 0.85, blue: 0.70) // Esmeralda menta
    static let efficiencyAccent = Color(red: 0.30, green: 0.65, blue: 1.00)  // Azul eléctrico
    static let consistencyAccent = Color(red: 0.75, green: 0.45, blue: 1.00) // Púrpura orquídea
    static let debtAccent = Color(red: 1.00, green: 0.45, blue: 0.40)        // Coral advertencia
    
    // Gradientes temáticos
    static let cardGradient = LinearGradient(
        colors: [Color.cardBackground, Color.cardBackground.opacity(0.85)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
