//
//  ScoreGaugeView.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import SwiftUI

/// Indicador circular animado para visualizar porcentajes (Rendimiento, Eficiencia, Consistencia).
public struct ScoreGaugeView: View {
    public let value: Double // 0.0 a 1.0 (o superior a 1.0 para rendimiento)
    public let title: String
    public let subtitle: String?
    public let accentColor: Color
    public var lineWidth: CGFloat = 14
    public var size: CGFloat = 130

    public init(
        value: Double,
        title: String,
        subtitle: String? = nil,
        accentColor: Color = .performanceAccent,
        lineWidth: CGFloat = 14,
        size: CGFloat = 130
    ) {
        self.value = value
        self.title = title
        self.subtitle = subtitle
        self.accentColor = accentColor
        self.lineWidth = lineWidth
        self.size = size
    }

    private var displayProgress: Double {
        min(max(value, 0.0), 1.0)
    }

    public var body: some View {
        ZStack {
            // Anillo base de fondo
            Circle()
                .stroke(accentColor.opacity(0.18), lineWidth: lineWidth)

            // Anillo de progreso con gradiente
            Circle()
                .trim(from: 0.0, to: CGFloat(displayProgress))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [accentColor.opacity(0.7), accentColor]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: value)

            // Contenido central
            VStack(spacing: 2) {
                Text("\(Int((value * 100).rounded()))%")
                    .font(.system(size: size * 0.24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(title)
                    .font(.system(size: size * 0.10, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: size * 0.09))
                        .foregroundColor(accentColor)
                }
            }
            .padding(12)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        ScoreGaugeView(value: 0.92, title: "Rendimiento", subtitle: "8h 10m / 8h 50m")
    }
}
