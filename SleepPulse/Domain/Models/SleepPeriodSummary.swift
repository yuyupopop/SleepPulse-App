//
//  SleepPeriodSummary.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import Foundation

/// Punto de datos resumido para graficar series temporales (diarias, semanales o mensuales).
public struct TrendDataPoint: Identifiable, Codable, Sendable {
    public let id: UUID
    public let date: Date
    public let label: String
    public let sleepHours: Double
    public let inBedHours: Double
    public let performance: Double
    public let efficiency: Double
    public let deepSleepHours: Double
    public let coreSleepHours: Double
    public let remSleepHours: Double
    public let awakeHours: Double

    public init(
        id: UUID = UUID(),
        date: Date,
        label: String,
        sleepHours: Double,
        inBedHours: Double,
        performance: Double,
        efficiency: Double,
        deepSleepHours: Double = 0,
        coreSleepHours: Double = 0,
        remSleepHours: Double = 0,
        awakeHours: Double = 0
    ) {
        self.id = id
        self.date = date
        self.label = label
        self.sleepHours = sleepHours
        self.inBedHours = inBedHours
        self.performance = performance
        self.efficiency = efficiency
        self.deepSleepHours = deepSleepHours
        self.coreSleepHours = coreSleepHours
        self.remSleepHours = remSleepHours
        self.awakeHours = awakeHours
    }
}

/// Resumen estadístico consolidado para un periodo (Día, Semana, Mes, Año).
public struct SleepPeriodSummary: Identifiable, Sendable {
    public let id: UUID
    public let timeframe: Timeframe
    public let interval: DateInterval
    public let averagePerformance: Double
    public let averageEfficiency: Double
    public let consistencyScore: Double
    public let currentSleepDebtHours: Double
    public let averageSleepHours: Double
    public let averageTimeInBedHours: Double
    public let stageDistribution: [SleepStage: Double] // Porcentajes promedio
    public let dataPoints: [TrendDataPoint]
    public let primarySession: SleepSession? // Sesión detallada más reciente (para el hipnograma diario)

    public init(
        id: UUID = UUID(),
        timeframe: Timeframe,
        interval: DateInterval,
        averagePerformance: Double,
        averageEfficiency: Double,
        consistencyScore: Double,
        currentSleepDebtHours: Double,
        averageSleepHours: Double,
        averageTimeInBedHours: Double,
        stageDistribution: [SleepStage: Double],
        dataPoints: [TrendDataPoint],
        primarySession: SleepSession? = nil
    ) {
        self.id = id
        self.timeframe = timeframe
        self.interval = interval
        self.averagePerformance = averagePerformance
        self.averageEfficiency = averageEfficiency
        self.consistencyScore = consistencyScore
        self.currentSleepDebtHours = currentSleepDebtHours
        self.averageSleepHours = averageSleepHours
        self.averageTimeInBedHours = averageTimeInBedHours
        self.stageDistribution = stageDistribution
        self.dataPoints = dataPoints
        self.primarySession = primarySession
    }
}
