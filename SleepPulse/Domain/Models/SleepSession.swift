//
//  SleepSession.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import Foundation

/// Representa una sesión completa de sueño (normalmente nocturna).
public struct SleepSession: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public let date: Date // Fecha de referencia de la sesión (ej. fecha del despertar)
    public let startDate: Date
    public let endDate: Date
    public let samples: [SleepSample]
    public let averageHeartRate: Double?

    public init(
        id: UUID = UUID(),
        date: Date,
        startDate: Date,
        endDate: Date,
        samples: [SleepSample],
        averageHeartRate: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.startDate = startDate
        self.endDate = endDate
        self.samples = samples.sorted(by: { $0.startDate < $1.startDate })
        self.averageHeartRate = averageHeartRate
    }

    /// Duración total en cama (en segundos). Si existen muestras `inBed`, se calcula la unión;
    /// de lo contrario, el intervalo total entre el inicio y el fin de la sesión.
    public var totalInBedDuration: TimeInterval {
        let inBedSamples = samples.filter { $0.stage == .inBed }
        if !inBedSamples.isEmpty {
            return inBedSamples.reduce(0) { $0 + $1.duration }
        }
        return max(0, endDate.timeIntervalSince(startDate))
    }

    /// Duración total dormido (excluye `awake` e `inBed`)
    public var totalAsleepDuration: TimeInterval {
        samples
            .filter { $0.stage != .awake && $0.stage != .inBed }
            .reduce(0) { $0 + $1.duration }
    }

    /// Duración en segundos para una fase determinada
    public func duration(for stage: SleepStage) -> TimeInterval {
        samples
            .filter { $0.stage == stage }
            .reduce(0) { $0 + $1.duration }
    }

    /// Porcentaje de una fase respecto al tiempo total dormido (para Deep, Core, REM)
    /// o respecto al tiempo en cama (para Awake).
    public func percentage(for stage: SleepStage) -> Double {
        if stage == .awake {
            let inBed = totalInBedDuration
            return inBed > 0 ? (duration(for: .awake) / inBed) : 0.0
        }
        let totalAsleep = totalAsleepDuration
        guard totalAsleep > 0 else { return 0.0 }
        return duration(for: stage) / totalAsleep
    }

    /// Muestras de etapas de sueño válidas para graficar el hipnograma (excluye `inBed` directo)
    public var hypnogramSamples: [SleepSample] {
        samples.filter { $0.stage != .inBed }
    }
}
