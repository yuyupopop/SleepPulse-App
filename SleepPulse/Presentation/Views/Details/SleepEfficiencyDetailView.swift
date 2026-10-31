//
//  SleepEfficiencyDetailView.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import SwiftUI

/// Vista de detalle para la Eficiencia del Sueño (Sleep Efficiency).
public struct SleepEfficiencyDetailView: View {
    public let metrics: SleepMetrics

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Tarjeta de Puntuación
                VStack(spacing: 12) {
                    ScoreGaugeView(
                        value: metrics.efficiency,
                        title: "Eficiencia",
                        accentColor: .efficiencyAccent,
                        lineWidth: 16,
                        size: 150
                    )

                    HStack(spacing: 6) {
                        Image(systemName: metrics.efficiencyStatus.systemIcon)
                        Text(metrics.efficiencyStatus.rawValue)
                    }
                    .font(.headline)
                    .foregroundColor(metrics.efficiencyStatus.color)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(20)

                // Comparativa En Cama vs Dormido
                VStack(alignment: .leading, spacing: 12) {
                    Text("Distribución del Tiempo")
                        .font(.headline)
                        .foregroundColor(.white)

                    VStack(spacing: 12) {
                        HStack {
                            Label("Tiempo dormido", systemImage: "moon.fill")
                                .foregroundColor(.efficiencyAccent)
                            Spacer()
                            Text(metrics.actualSleepHours.formattedHoursAndMinutes)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }

                        Divider().background(Color.cardBorder)

                        HStack {
                            Label("Tiempo en cama", systemImage: "bed.double.fill")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(metrics.timeInBedHours.formattedHoursAndMinutes)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }

                        Divider().background(Color.cardBorder)

                        let awakeTime = max(0, metrics.timeInBedHours - metrics.actualSleepHours)
                        HStack {
                            Label("Tiempo despierto en cama", systemImage: "eye.fill")
                                .foregroundColor(.orange)
                            Spacer()
                            Text(awakeTime.formattedHoursAndMinutes)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(12)
                }
                .padding(16)
                .background(Color.cardBackground)
                .cornerRadius(18)

                // Definición Médica
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.efficiencyAccent)
                        Text("¿Qué es la Eficiencia del Sueño?")
                            .font(.headline)
                            .foregroundColor(.white)
                    }

                    Text("Mide el porcentaje del tiempo total que pasaste en la cama en el que realmente estuviste dormido. Los estudios de medicina del sueño establecen que **lo ideal es un 90% o más**. Una eficiencia menor al 85% suele reflejar dificultades para conciliar el sueño (latencia elevada) o microdespertares frecuentes.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding(16)
                .background(Color.cardBackground)
                .cornerRadius(18)

                // Higiene del sueño
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        Text("Consejos para superar el 90%")
                            .font(.headline)
                            .foregroundColor(.white)
                    }

                    Text("• Si tardas más de 20 minutos en dormirte, sal de la cama y realiza una actividad relajante con luz tenue.\n• Mantén la habitación fresca (entre 18 y 20 °C).\n• Limita el uso de pantallas emisoras de luz azul al menos 60 minutos antes de acostarte.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding(16)
                .background(Color.cardBackground)
                .cornerRadius(18)
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Eficiencia del Sueño")
        .inlineNavigationTitle()
    }
}
