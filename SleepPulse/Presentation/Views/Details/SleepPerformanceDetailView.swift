//
//  SleepPerformanceDetailView.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import SwiftUI

/// Vista de detalle para el Rendimiento del Sueño (Sleep Performance).
public struct SleepPerformanceDetailView: View {
    public let metrics: SleepMetrics

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Tarjeta Principal de Puntuación
                VStack(spacing: 12) {
                    ScoreGaugeView(
                        value: metrics.performance,
                        title: "Rendimiento",
                        accentColor: .performanceAccent,
                        lineWidth: 16,
                        size: 150
                    )

                    Text(metrics.performanceStatus.rawValue)
                        .font(.headline)
                        .foregroundColor(metrics.performanceStatus.color)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(20)

                // Ecuación y cálculo dinámico
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cálculo Dinámico")
                        .font(.headline)
                        .foregroundColor(.white)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Horas dormidas reales:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(metrics.actualSleepHours.formattedHoursAndMinutes)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }

                        Divider().background(Color.cardBorder)

                        HStack {
                            Text("Necesidad dinámica calculada:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(metrics.dynamicNeedHours.formattedHoursAndMinutes)
                                .fontWeight(.bold)
                                .foregroundColor(.performanceAccent)
                        }

                        Divider().background(Color.cardBorder)

                        HStack {
                            Text("Proporción alcanzada:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(metrics.performance.formattedPercentage)
                                .fontWeight(.bold)
                                .foregroundColor(.performanceAccent)
                        }
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(12)
                }
                .padding(16)
                .background(Color.cardBackground)
                .cornerRadius(18)

                // Definición Médica / Explicación
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.performanceAccent)
                        Text("¿Qué es el Rendimiento del Sueño?")
                            .font(.headline)
                            .foregroundColor(.white)
                    }

                    Text("Es un porcentaje que indica qué parte de la necesidad de descanso de tu cuerpo cubriste esa noche. A diferencia de una meta estática de 8 horas, se calcula comparando tus horas reales dormidas frente a tu **necesidad dinámica** (que ajusta tu necesidad basal sumando el recargo por deuda acumulada de sueño y el esfuerzo físico registrado).")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding(16)
                .background(Color.cardBackground)
                .cornerRadius(18)

                // Recomendaciones
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                        Text("Optimización")
                            .font(.headline)
                            .foregroundColor(.white)
                    }

                    Text("Para alcanzar el 100%, anticipa tu hora de ir a la cama cuando tu deuda de sueño sea alta. Si tu cuerpo acumuló 3 horas de deuda en la semana, tu necesidad dinámica se incrementará entre 40 y 50 minutos adicionales esta noche.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(3)
                }
                .padding(16)
                .background(Color.cardBackground)
                .cornerRadius(18)
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Rendimiento del Sueño")
        .inlineNavigationTitle()
    }
}
