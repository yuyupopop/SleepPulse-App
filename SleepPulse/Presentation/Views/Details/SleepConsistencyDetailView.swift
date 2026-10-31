//
//  SleepConsistencyDetailView.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import SwiftUI

/// Vista de detalle para la Consistencia del Sueño (Sleep Consistency).
public struct SleepConsistencyDetailView: View {
    public let metrics: SleepMetrics

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Tarjeta Principal
                VStack(spacing: 12) {
                    ScoreGaugeView(
                        value: metrics.consistency,
                        title: "Consistencia",
                        accentColor: .consistencyAccent,
                        lineWidth: 16,
                        size: 150
                    )

                    HStack(spacing: 6) {
                        Image(systemName: metrics.consistencyStatus.systemIcon)
                        Text(metrics.consistencyStatus.rawValue)
                    }
                    .font(.headline)
                    .foregroundColor(metrics.consistencyStatus.color)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(20)

                // Variabilidad de Horarios
                VStack(alignment: .leading, spacing: 12) {
                    Text("Variabilidad de Horarios")
                        .font(.headline)
                        .foregroundColor(.white)

                    VStack(spacing: 12) {
                        HStack {
                            Label("Desviación al acostarse", systemImage: "moon.fill")
                                .foregroundColor(.consistencyAccent)
                            Spacer()
                            Text("±\(Int(metrics.bedtimeVarianceMinutes)) min")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }

                        Divider().background(Color.cardBorder)

                        HStack {
                            Label("Desviación al despertar", systemImage: "sun.max.fill")
                                .foregroundColor(.yellow)
                            Spacer()
                            Text("±\(Int(metrics.wakeVarianceMinutes)) min")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
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
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.consistencyAccent)
                        Text("¿Qué es la Consistencia?")
                            .font(.headline)
                            .foregroundColor(.white)
                    }

                    Text("Evalúa la **regularidad con la que te acuestas y te levantas** comparando tus horarios de los últimos días. La estabilidad circadiana optimiza el pulso natural de melatonina y cortisol. Variar tus horarios en más de 60 minutos entre días laborables y fines de semana genera el llamado *jet lag social*, reduciendo la calidad del sueño profundo.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding(16)
                .background(Color.cardBackground)
                .cornerRadius(18)

                // Recomendación
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "sun.and.horizon.fill")
                            .foregroundColor(.orange)
                        Text("Sincronización Circadiana")
                            .font(.headline)
                            .foregroundColor(.white)
                    }

                    Text("Mantener un horario de despertar fijo (con una desviación menor a 30 minutos, incluso fines de semana) es el factor más potente para anclar tu ritmo circadiano y facilitar un sueño reparador.")
                        .font(.footnote)
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
        .navigationTitle("Consistencia del Sueño")
        .navigationBarTitleDisplayMode(.inline)
    }
}
