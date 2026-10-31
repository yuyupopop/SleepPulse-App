//
//  SleepDepthHypnogramView.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import SwiftUI
import Charts

/// Pantalla dedicada a la visualización de la profundidad de las fases de sueño (Hipnograma).
/// Muestra con precisión cronológica los estados: Despierto (arriba), REM, Ligero/Core y Profundo (abajo).
public struct SleepDepthHypnogramView: View {
    @ObservedObject public var viewModel: SleepDepthViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: SleepDepthViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Encabezado de la sesión
                if let session = viewModel.session {
                    sessionHeaderView(session: session)
                }

                // Gráfica de Hipnograma interactiva
                hypnogramCardView

                // Barra porcentual apilada de distribución
                stackedDistributionBar

                // Desglose de cada fase de sueño frente a rangos saludables
                VStack(alignment: .leading, spacing: 12) {
                    Text("Desglose por Fases")
                        .font(.headline)
                        .foregroundColor(.white)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(viewModel.stageBreakdown) { item in
                            StagePillView(item: item)
                        }
                    }
                }

                // Información clínica sobre la arquitectura del sueño
                clinicalInsightsCard
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Profundidad del Sueño")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Encabezado
    private func sessionHeaderView(session: SleepSession) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(session.date.shortDateString)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            HStack(spacing: 16) {
                Label("\(session.startDate.timeString) - \(session.endDate.timeString)", systemImage: "clock")
                Label(session.totalAsleepDuration.hoursAndMinutesString, systemImage: "moon.fill")
                if let hr = session.averageHeartRate {
                    Label("\(Int(hr)) lpm", systemImage: "heart.fill")
                        .foregroundColor(.red.opacity(0.85))
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }

    // MARK: - Tarjeta del Hipnograma con Swift Charts
    private var hypnogramCardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Hipnograma de Arquitectura")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()

                if let sample = viewModel.selectedSample {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(sample.stage.color)
                            .frame(width: 8, height: 8)
                        Text("\(sample.stage.shortName) (\(sample.startDate.timeString))")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(8)
                } else {
                    Text("Arrastra para inspeccionar")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // Gráfica de niveles de profundidad
            Chart {
                ForEach(viewModel.hypnogramSamples) { sample in
                    // Área con gradiente de profundidad
                    AreaMark(
                        xStart: .value("Inicio", sample.startDate),
                        xEnd: .value("Fin", sample.endDate),
                        y: .value("Profundidad", sample.stage.depthLevel)
                    )
                    .foregroundStyle(sample.stage.color.opacity(0.40))

                    // Barra sólida para representar el tramo exacto
                    BarMark(
                        xStart: .value("Inicio", sample.startDate),
                        xEnd: .value("Fin", sample.endDate),
                        y: .value("Profundidad", sample.stage.depthLevel)
                    )
                    .foregroundStyle(sample.stage.color)
                }

                // Cursor de inspección interactivo
                if let selectedDate = viewModel.selectedDate {
                    RuleMark(x: .value("Hora seleccionada", selectedDate))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                        .foregroundStyle(Color.white)
                }
            }
            .chartYScale(domain: 0...4)
            .chartYAxis {
                AxisMarks(values: [1, 2, 3, 4]) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                        .foregroundStyle(Color.white.opacity(0.1))
                    AxisValueLabel {
                        if let intVal = value.as(Int.self) {
                            switch intVal {
                            case 1: Text("Profundo").font(.caption2).foregroundColor(SleepStage.deep.color)
                            case 2: Text("Core").font(.caption2).foregroundColor(SleepStage.core.color)
                            case 3: Text("REM").font(.caption2).foregroundColor(SleepStage.rem.color)
                            case 4: Text("Despierto").font(.caption2).foregroundColor(SleepStage.awake.color)
                            default: EmptyView()
                            }
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 2)) { _ in
                    AxisGridLine().foregroundStyle(Color.white.opacity(0.08))
                    AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .omitted)).minute())
                        .foregroundStyle(Color.secondary)
                }
            }
            .frame(height: 220)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let currentX = value.location.x - geometry[proxy.plotFrame!].origin.x
                                    if let date: Date = proxy.value(atX: currentX) {
                                        viewModel.selectDate(date)
                                    }
                                }
                                .onEnded { _ in
                                    viewModel.clearSelection()
                                }
                        )
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

    // MARK: - Barra Apilada de Distribución
    private var stackedDistributionBar: some View {
        guard let session = viewModel.session, session.totalAsleepDuration > 0 else {
            return AnyView(EmptyView())
        }

        let deepRatio = session.percentage(for: .deep)
        let coreRatio = session.percentage(for: .core)
        let remRatio = session.percentage(for: .rem)

        return AnyView(
            VStack(alignment: .leading, spacing: 8) {
                Text("Composición del Ciclo")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                GeometryReader { geo in
                    HStack(spacing: 3) {
                        Rectangle()
                            .fill(SleepStage.deep.color)
                            .frame(width: geo.size.width * CGFloat(deepRatio))

                        Rectangle()
                            .fill(SleepStage.core.color)
                            .frame(width: geo.size.width * CGFloat(coreRatio))

                        Rectangle()
                            .fill(SleepStage.rem.color)
                            .frame(width: geo.size.width * CGFloat(remRatio))
                    }
                    .cornerRadius(6)
                }
                .frame(height: 12)
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
        )
    }

    // MARK: - Información Clínica
    private var clinicalInsightsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Análisis de Arquitectura")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }

            Text("El sueño profundo repara los tejidos musculares y consolida el sistema inmune. El sueño REM consolida la memoria procedimental y el equilibrio emocional. Una secuencia armónica de ciclos de 90 minutos maximiza la recuperación celular.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineSpacing(3)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}
