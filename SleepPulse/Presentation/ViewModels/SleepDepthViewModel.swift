//
//  SleepDepthViewModel.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import Foundation
import SwiftUI
import Combine

/// Estructura para presentar cada fase con su duración, porcentaje y comparativa con el rango óptimo.
public struct StageAnalysisItem: Identifiable, Sendable {
    public var id: String { stage.id }
    public let stage: SleepStage
    public let duration: TimeInterval
    public let percentage: Double
    public let isWithinHealthyRange: Bool
    public let targetDescription: String
}

/// ViewModel para la pantalla especializada en Profundidad del Sueño e Hipnograma.
@MainActor
public final class SleepDepthViewModel: ObservableObject {
    @Published public var session: SleepSession?
    @Published public var selectedDate: Date? // Para inspección interactiva táctil en la gráfica
    @Published public var selectedSample: SleepSample?

    public init(session: SleepSession? = nil) {
        self.session = session
    }

    public func updateSession(_ session: SleepSession) {
        self.session = session
        self.selectedDate = nil
        self.selectedSample = nil
    }

    /// Muestras ordenadas para la gráfica de hipnograma
    public var hypnogramSamples: [SleepSample] {
        session?.hypnogramSamples ?? []
    }

    /// Desglose analítico de cada fase con respecto a los rangos saludables de referencia
    public var stageBreakdown: [StageAnalysisItem] {
        guard let session = session else { return [] }
        let stages: [SleepStage] = [.deep, .core, .rem, .awake]

        return stages.map { stage in
            let dur = session.duration(for: stage)
            let pct = session.percentage(for: stage)
            let range = stage.healthyReferenceRange
            let isWithin = range.contains(pct)

            let targetText = "\(Int(range.lowerBound * 100))% - \(Int(range.upperBound * 100))%"
            return StageAnalysisItem(
                stage: stage,
                duration: dur,
                percentage: pct,
                isWithinHealthyRange: isWithin,
                targetDescription: targetText
            )
        }
    }

    /// Número de despertares o interrupciones registradas
    public var awakeInterruptionsCount: Int {
        session?.samples.filter { $0.stage == .awake && $0.duration >= 180 }.count ?? 0
    }

    /// Encuentra la muestra correspondiente al tocar o arrastrar sobre la gráfica
    public func selectDate(_ date: Date) {
        self.selectedDate = date
        self.selectedSample = hypnogramSamples.first(where: {
            $0.startDate <= date && $0.endDate >= date
        })
    }

    public func clearSelection() {
        self.selectedDate = nil
        self.selectedSample = nil
    }
}
