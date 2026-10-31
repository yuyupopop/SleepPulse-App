//
//  SleepDebtDetailView.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import SwiftUI

/// Vista de detalle para la Deuda de Sueño (Sleep Debt).
public struct SleepDebtDetailView: View {
    public let metrics: SleepMetrics

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Tarjeta Principal
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.debtAccent.opacity(0.15))
                            .frame(width: 140, height: 140)

                        VStack(spacing: 2) {
                            Image(systemName: "hourglass.badge.plus")
                                .font(.system(size: 32))
                                .foregroundColor(.debtAccent)

                            Text(metrics.sleepDebtHours.formattedHoursAndMinutes)
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Text("Deuda acumulada")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack(spacing: 6) {
                        Image(systemName: metrics.debtStatus.systemIcon)
                        Text(metrics.debtStatus.rawValue)
                    }
                    .font(.headline)
                    .foregroundColor(metrics.debtStatus.color)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(20)

                // Resumen de la Ventana de 14 Días
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ventana Móvil de 14 Días")
                        .font(.headline)
                        .foregroundColor(.white)

                    VStack(spacing: 12) {
                        HStack {
                            Text("Déficit neto acumulado:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(metrics.sleepDebtHours.formattedHoursAndMinutes)
                                .fontWeight(.bold)
                                .foregroundColor(.debtAccent)
                        }

                        Divider().background(Color.cardBorder)

                        HStack {
                            Text("Recargo en necesidad de hoy:")
                                .foregroundColor(.secondary)
                            Spacer()
                            let surcharge = max(0, metrics.dynamicNeedHours - 8.0)
                            Text("+\(surcharge.formattedHoursAndMinutes)")
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

                // Definición Médica
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.debtAccent)
                        Text("¿Qué es la Deuda de Sueño?")
                            .font(.headline)
                            .foregroundColor(.white)
                    }

                    Text("Calcula el **déficit de descanso acumulado a lo largo de los últimos 14 días** en comparación con lo que tu cuerpo realmente requería. Perder solo 30 a 45 minutos por noche parece poco, pero tras 14 días suma una deuda de casi 10 horas, lo que reduce la velocidad de procesamiento cognitivo, debilita la inmunidad y eleva el cortisol basal.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding(16)
                .background(Color.cardBackground)
                .cornerRadius(18)

                // Cómo pagar la deuda de sueño
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "cross.vial.fill")
                            .foregroundColor(.cyan)
                        Text("Cómo pagar tu deuda sin desajustar tu reloj")
                            .font(.headline)
                            .foregroundColor(.white)
                    }

                    Text("• **No duermas 4 horas de más el fin de semana**: Desajustará tu fase circadiana.\n• **Amortiza gradualmente**: Ve a la cama entre 30 y 45 minutos antes cada noche durante la siguiente semana.\n• **Siestas estratégicas**: Siestas diurnas de 20 minutos antes de las 15:00 ayudan a amortizar deuda sin inhibir la presión homeostática nocturna.")
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
        .navigationTitle("Deuda de Sueño")
        .inlineNavigationTitle()
    }
}
