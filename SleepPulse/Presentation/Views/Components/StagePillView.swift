//
//  StagePillView.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import SwiftUI

/// Ficha visual para mostrar el resumen de una fase de sueño individual (Profundo, Core, REM, Despierto).
public struct StagePillView: View {
    public let item: StageAnalysisItem

    public init(item: StageAnalysisItem) {
        self.item = item
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(item.stage.color)
                    .frame(width: 10, height: 10)

                Text(item.stage.shortName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: item.stage.icon)
                    .foregroundColor(item.stage.color)
                    .font(.caption)
            }

            HStack(alignment: .firstTextBaseline) {
                Text(item.duration.hoursAndMinutesString)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Spacer()

                Text(item.percentage.formattedPercentage)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }

            // Indicador de rango de referencia
            HStack(spacing: 4) {
                Image(systemName: item.isWithinHealthyRange ? "checkmark.circle.fill" : "info.circle")
                    .font(.system(size: 10))
                    .foregroundColor(item.isWithinHealthyRange ? .green : .orange)

                Text("Meta: \(item.targetDescription)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(item.stage.color.opacity(0.25), lineWidth: 1)
        )
    }
}
