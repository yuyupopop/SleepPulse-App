//
//  MetricTrendChartView.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import SwiftUI
import Charts

public enum TrendChartMode: String, CaseIterable, Identifiable {
    case stages = "Fases"
    case performance = "Rendimiento"
    case efficiency = "Eficiencia"

    public var id: String { rawValue }
}

/// Gráfica evolutiva multidimensional para tendencias Semanales, Mensuales y Anuales.
public struct MetricTrendChartView: View {
    public let dataPoints: [TrendDataPoint]
    public let timeframe: Timeframe
    @State private var selectedMode: TrendChartMode = .stages

    public init(dataPoints: [TrendDataPoint], timeframe: Timeframe) {
        self.dataPoints = dataPoints
        self.timeframe = timeframe
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Evolución \(timeframe.title)")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Picker("Modo", selection: $selectedMode) {
                    ForEach(TrendChartMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 220)
            }

            if dataPoints.isEmpty {
                Text("No hay suficientes datos registrados para este periodo.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
            } else {
                switch selectedMode {
                case .stages:
                    stagesStackedChart
                case .performance:
                    percentageTrendChart(isPerformance: true)
                case .efficiency:
                    percentageTrendChart(isPerformance: false)
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

    // MARK: - Gráfica Apilada de Fases
    private var stagesStackedChart: some View {
        Chart {
            ForEach(dataPoints) { point in
                BarMark(
                    x: .value("Fecha", point.label),
                    y: .value("Profundo", point.deepSleepHours)
                )
                .foregroundStyle(SleepStage.deep.color)

                BarMark(
                    x: .value("Fecha", point.label),
                    y: .value("Core", point.coreSleepHours)
                )
                .foregroundStyle(SleepStage.core.color)

                BarMark(
                    x: .value("Fecha", point.label),
                    y: .value("REM", point.remSleepHours)
                )
                .foregroundStyle(SleepStage.rem.color)
            }

            // Línea de referencia de 8 horas recomendadas
            RuleMark(y: .value("Meta 8h", 8.0))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .foregroundStyle(Color.green.opacity(0.8))
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 4, 8, 12]) { value in
                AxisGridLine().foregroundStyle(Color.white.opacity(0.08))
                AxisValueLabel {
                    if let hours = value.as(Double.self) {
                        Text("\(Int(hours))h")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisGridLine().foregroundStyle(Color.clear)
                AxisValueLabel()
                    .foregroundStyle(Color.secondary)
                    .font(.caption2)
            }
        }
        .frame(height: 190)
    }

    // MARK: - Gráfica de Líneas para Rendimiento o Eficiencia
    private func percentageTrendChart(isPerformance: Bool) -> some View {
        let accentColor = isPerformance ? Color.performanceAccent : Color.efficiencyAccent
        let targetThreshold = isPerformance ? 1.0 : 0.90

        return Chart {
            ForEach(dataPoints) { point in
                let val = isPerformance ? point.performance : point.efficiency
                
                LineMark(
                    x: .value("Fecha", point.label),
                    y: .value("Valor", val * 100)
                )
                .foregroundStyle(accentColor)
                .symbol(.circle)

                AreaMark(
                    x: .value("Fecha", point.label),
                    y: .value("Valor", val * 100)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [accentColor.opacity(0.35), accentColor.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

            RuleMark(y: .value("Objetivo", targetThreshold * 100))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .foregroundStyle(Color.white.opacity(0.6))
        }
        .chartYScale(domain: 40...110)
        .chartYAxis {
            AxisMarks(position: .leading, values: [50, 75, 90, 100]) { value in
                AxisGridLine().foregroundStyle(Color.white.opacity(0.08))
                AxisValueLabel {
                    if let pct = value.as(Int.self) {
                        Text("\(pct)%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisGridLine().foregroundStyle(Color.clear)
                AxisValueLabel()
                    .foregroundStyle(Color.secondary)
                    .font(.caption2)
            }
        }
        .frame(height: 190)
    }
}
