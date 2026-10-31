//
//  MetricCardView.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import SwiftUI

/// Tarjeta visual reutilizable para cada una de las 4 métricas clave:
/// Rendimiento, Eficiencia, Consistencia y Deuda de sueño.
public struct MetricCardView: View {
    public let title: String
    public let value: String
    public let subtitle: String
    public let icon: String
    public let accentColor: Color
    public let status: MetricStatus
    public var progress: Double? = nil

    public init(
        title: String,
        value: String,
        subtitle: String,
        icon: String,
        accentColor: Color,
        status: MetricStatus,
        progress: Double? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.accentColor = accentColor
        self.status = status
        self.progress = progress
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.18))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .foregroundColor(accentColor)
                        .font(.system(size: 16, weight: .semibold))
                }

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()

                // Estado de calidad (Óptimo, Bueno, etc.)
                HStack(spacing: 4) {
                    Image(systemName: status.systemIcon)
                        .font(.system(size: 10))
                    Text(status.rawValue)
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(status.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(status.color.opacity(0.14))
                .cornerRadius(12)
            }

            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Spacer()

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
            }

            // Barra de progreso opcional
            if let progress = progress {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 6)

                        Capsule()
                            .fill(accentColor)
                            .frame(width: geo.size.width * CGFloat(min(max(progress, 0.0), 1.0)), height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
    }
}
