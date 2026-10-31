//
//  PeriodSummaryView.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import SwiftUI

/// Vista que despliega el resumen estadístico agregado para el periodo seleccionado (Día, Semana, Mes, Año).
public struct PeriodSummaryView: View {
    public let summary: SleepPeriodSummary
    public let latestMetrics: SleepMetrics?
    @ObservedObject public var depthViewModel: SleepDepthViewModel

    public var body: some View {
        VStack(spacing: 20) {
            // Tarjeta destacada con las 4 métricas principales
            metricsGridSection

            // Botón destacado hacia la pantalla de Profundidad del Sueño e Hipnograma
            if let session = summary.primarySession {
                NavigationLink(destination: SleepDepthHypnogramView(viewModel: depthViewModel)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Gráfica de Profundidad del Sueño")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Hipnograma con fases Profundo, REM y Core")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "waveform.path.ecg.rectangle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.performanceAccent)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(Color.cardBackground)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.performanceAccent.opacity(0.35), lineWidth: 1)
                    )
                }
            }

            // Gráfica de evolución según periodo
            MetricTrendChartView(
                dataPoints: summary.dataPoints,
                timeframe: summary.timeframe
            )

            // Resumen de Promedios del Periodo
            averagesCardSection
        }
    }

    // MARK: - Sección de 4 Métricas Clave
    private var metricsGridSection: some View {
        let metrics = latestMetrics ?? fallbackMetrics

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            // 1. Rendimiento del Sueño
            NavigationLink(destination: SleepPerformanceDetailView(metrics: metrics)) {
                MetricCardView(
                    title: "Rendimiento",
                    value: summary.averagePerformance.formattedPercentage,
                    subtitle: "Meta dinámica: \(metrics.dynamicNeedHours.formattedHoursAndMinutes)",
                    icon: "sparkles",
                    accentColor: .performanceAccent,
                    status: metrics.performanceStatus,
                    progress: summary.averagePerformance
                )
            }

            // 2. Eficiencia del Sueño
            NavigationLink(destination: SleepEfficiencyDetailView(metrics: metrics)) {
                MetricCardView(
                    title: "Eficiencia",
                    value: summary.averageEfficiency.formattedPercentage,
                    subtitle: "Objetivo ≥ 90%",
                    icon: "bed.double.fill",
                    accentColor: .efficiencyAccent,
                    status: metrics.efficiencyStatus,
                    progress: summary.averageEfficiency
                )
            }

            // 3. Consistencia
            NavigationLink(destination: SleepConsistencyDetailView(metrics: metrics)) {
                MetricCardView(
                    title: "Consistencia",
                    value: summary.consistencyScore.formattedPercentage,
                    subtitle: "Ritmo circadiano",
                    icon: "clock.arrow.2.circlepath",
                    accentColor: .consistencyAccent,
                    status: metrics.consistencyStatus,
                    progress: summary.consistencyScore
                )
            }

            // 4. Deuda de Sueño
            NavigationLink(destination: SleepDebtDetailView(metrics: metrics)) {
                MetricCardView(
                    title: "Deuda de Sueño",
                    value: summary.currentSleepDebtHours.formattedHoursAndMinutes,
                    subtitle: "Ventana 14 días",
                    icon: "hourglass.badge.plus",
                    accentColor: .debtAccent,
                    status: metrics.debtStatus,
                    progress: min(summary.currentSleepDebtHours / 8.0, 1.0)
                )
            }
        }
    }

    // MARK: - Resumen de Promedios
    private var averagesCardSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Promedios del Periodo (\(summary.timeframe.title))")
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tiempo dormido")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(summary.averageSleepHours.formattedHoursAndMinutes)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                Divider().frame(height: 36).background(Color.cardBorder)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Tiempo en cama")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(summary.averageTimeInBedHours.formattedHoursAndMinutes)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }

            Divider().background(Color.cardBorder)

            // Distribución de fases promedio
            VStack(alignment: .leading, spacing: 8) {
                Text("Composición Promedio de Fases")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    phaseIndicator(stage: .deep, pct: summary.stageDistribution[.deep] ?? 0)
                    phaseIndicator(stage: .core, pct: summary.stageDistribution[.core] ?? 0)
                    phaseIndicator(stage: .rem, pct: summary.stageDistribution[.rem] ?? 0)
                }
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

    private func phaseIndicator(stage: SleepStage, pct: Double) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(stage.color)
                .frame(width: 8, height: 8)
            Text("\(stage.shortName): \(pct.formattedPercentage)")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }

    private var fallbackMetrics: SleepMetrics {
        SleepMetrics(
            date: Date(),
            performance: summary.averagePerformance,
            efficiency: summary.averageEfficiency,
            consistency: summary.consistencyScore,
            sleepDebtHours: summary.currentSleepDebtHours,
            dynamicNeedHours: 8.0,
            actualSleepHours: summary.averageSleepHours,
            timeInBedHours: summary.averageTimeInBedHours
        )
    }
}
