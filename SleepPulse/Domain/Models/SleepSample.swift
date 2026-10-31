//
//  SleepSample.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import Foundation

/// Muestra o intervalo discreto de fase de sueño obtenido desde HealthKit.
public struct SleepSample: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public let startDate: Date
    public let endDate: Date
    public let stage: SleepStage
    public let sourceName: String

    public var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }

    public init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date,
        stage: SleepStage,
        sourceName: String = "Apple Watch"
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.stage = stage
        self.sourceName = sourceName
    }
}
