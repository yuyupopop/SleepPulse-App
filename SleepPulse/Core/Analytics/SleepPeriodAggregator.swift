//
//  SleepPeriodAggregator.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import Foundation

/// Agrega y consolida sesiones de sueño para periodos Diarios, Semanales, Mensuales y Anuales.
public final class SleepPeriodAggregator: Sendable {
    public static let shared = SleepPeriodAggregator()
    private let calculator: SleepCalculator

    public init(calculator: SleepCalculator = .shared) {
        self.calculator = calculator
    }

    /// Genera el resumen agregado para el timeframe solicitado
    public func aggregate(
        sessions: [SleepSession],
        for timeframe: Timeframe,
        referenceDate: Date = Date(),
        baselineNeedHours: Double = 8.0,
        calendar: Calendar = .current
    ) -> SleepPeriodSummary {
        let interval = timeframe.dateInterval(for: referenceDate, calendar: calendar)
        let filteredSessions = sessions.filter {
            $0.endDate >= interval.start && $0.endDate <= interval.end
        }.sorted(by: { $0.startDate < $1.startDate })

        switch timeframe {
        case .day:
            return aggregateDay(
                sessions: filteredSessions,
                allSessions: sessions,
                interval: interval,
                baselineNeed: baselineNeedHours
            )
        case .week:
            return aggregateWeek(
                sessions: filteredSessions,
                allSessions: sessions,
                interval: interval,
                baselineNeed: baselineNeedHours,
                calendar: calendar
            )
        case .month:
            return aggregateMonth(
                sessions: filteredSessions,
                allSessions: sessions,
                interval: interval,
                baselineNeed: baselineNeedHours,
                calendar: calendar
            )
        case .year:
            return aggregateYear(
                sessions: filteredSessions,
                interval: interval,
                baselineNeed: baselineNeedHours,
                calendar: calendar
            )
        }
    }

    // MARK: - Resumen Diario
    private func aggregateDay(
        sessions: [SleepSession],
        allSessions: [SleepSession],
        interval: DateInterval,
        baselineNeed: Double
    ) -> SleepPeriodSummary {
        guard let primarySession = sessions.last ?? allSessions.last else {
            return emptySummary(timeframe: .day, interval: interval)
        }

        let metrics = calculator.computeMetrics(
            for: primarySession,
            recentSessions: allSessions,
            baselineNeedHours: baselineNeed
        )

        let stageDistribution = computeDistribution(for: [primarySession])

        let dataPoint = TrendDataPoint(
            date: primarySession.endDate,
            label: "Hoy",
            sleepHours: primarySession.totalAsleepDuration.inHours,
            inBedHours: primarySession.totalInBedDuration.inHours,
            performance: metrics.performance,
            efficiency: metrics.efficiency,
            deepSleepHours: primarySession.duration(for: .deep).inHours,
            coreSleepHours: primarySession.duration(for: .core).inHours,
            remSleepHours: primarySession.duration(for: .rem).inHours,
            awakeHours: primarySession.duration(for: .awake).inHours
        )

        return SleepPeriodSummary(
            timeframe: .day,
            interval: interval,
            averagePerformance: metrics.performance,
            averageEfficiency: metrics.efficiency,
            consistencyScore: metrics.consistency,
            currentSleepDebtHours: metrics.sleepDebtHours,
            averageSleepHours: primarySession.totalAsleepDuration.inHours,
            averageTimeInBedHours: primarySession.totalInBedDuration.inHours,
            stageDistribution: stageDistribution,
            dataPoints: [dataPoint],
            primarySession: primarySession
        )
    }

    // MARK: - Resumen Semanal
    private func aggregateWeek(
        sessions: [SleepSession],
        allSessions: [SleepSession],
        interval: DateInterval,
        baselineNeed: Double,
        calendar: Calendar
    ) -> SleepPeriodSummary {
        guard !sessions.isEmpty else {
            return emptySummary(timeframe: .week, interval: interval)
        }

        var dataPoints: [TrendDataPoint] = []
        var totalPerf: Double = 0
        var totalEff: Double = 0
        var totalSleep: Double = 0
        var totalInBed: Double = 0

        for session in sessions {
            let metrics = calculator.computeMetrics(for: session, recentSessions: allSessions, baselineNeedHours: baselineNeed)
            totalPerf += metrics.performance
            totalEff += metrics.efficiency
            totalSleep += session.totalAsleepDuration.inHours
            totalInBed += session.totalInBedDuration.inHours

            dataPoints.append(TrendDataPoint(
                date: session.endDate,
                label: session.endDate.weekdayShort,
                sleepHours: session.totalAsleepDuration.inHours,
                inBedHours: session.totalInBedDuration.inHours,
                performance: metrics.performance,
                efficiency: metrics.efficiency,
                deepSleepHours: session.duration(for: .deep).inHours,
                coreSleepHours: session.duration(for: .core).inHours,
                remSleepHours: session.duration(for: .rem).inHours,
                awakeHours: session.duration(for: .awake).inHours
            ))
        }

        let count = Double(sessions.count)
        let consistency = calculator.calculateConsistency(sessions: sessions).score
        let debt = calculator.calculateSleepDebt(sessionsInPast14Days: allSessions, baselineNeedHours: baselineNeed)

        return SleepPeriodSummary(
            timeframe: .week,
            interval: interval,
            averagePerformance: totalPerf / count,
            averageEfficiency: totalEff / count,
            consistencyScore: consistency,
            currentSleepDebtHours: debt,
            averageSleepHours: totalSleep / count,
            averageTimeInBedHours: totalInBed / count,
            stageDistribution: computeDistribution(for: sessions),
            dataPoints: dataPoints,
            primarySession: sessions.last
        )
    }

    // MARK: - Resumen Mensual
    private func aggregateMonth(
        sessions: [SleepSession],
        allSessions: [SleepSession],
        interval: DateInterval,
        baselineNeed: Double,
        calendar: Calendar
    ) -> SleepPeriodSummary {
        guard !sessions.isEmpty else {
            return emptySummary(timeframe: .month, interval: interval)
        }

        var dataPoints: [TrendDataPoint] = []
        var totalPerf: Double = 0
        var totalEff: Double = 0
        var totalSleep: Double = 0
        var totalInBed: Double = 0

        for session in sessions {
            let metrics = calculator.computeMetrics(for: session, recentSessions: allSessions, baselineNeedHours: baselineNeed)
            totalPerf += metrics.performance
            totalEff += metrics.efficiency
            totalSleep += session.totalAsleepDuration.inHours
            totalInBed += session.totalInBedDuration.inHours

            dataPoints.append(TrendDataPoint(
                date: session.endDate,
                label: session.endDate.shortDateString,
                sleepHours: session.totalAsleepDuration.inHours,
                inBedHours: session.totalInBedDuration.inHours,
                performance: metrics.performance,
                efficiency: metrics.efficiency,
                deepSleepHours: session.duration(for: .deep).inHours,
                coreSleepHours: session.duration(for: .core).inHours,
                remSleepHours: session.duration(for: .rem).inHours,
                awakeHours: session.duration(for: .awake).inHours
            ))
        }

        let count = Double(sessions.count)
        let consistency = calculator.calculateConsistency(sessions: Array(sessions.suffix(14))).score
        let debt = calculator.calculateSleepDebt(sessionsInPast14Days: Array(sessions.suffix(14)), baselineNeedHours: baselineNeed)

        return SleepPeriodSummary(
            timeframe: .month,
            interval: interval,
            averagePerformance: totalPerf / count,
            averageEfficiency: totalEff / count,
            consistencyScore: consistency,
            currentSleepDebtHours: debt,
            averageSleepHours: totalSleep / count,
            averageTimeInBedHours: totalInBed / count,
            stageDistribution: computeDistribution(for: sessions),
            dataPoints: dataPoints,
            primarySession: sessions.last
        )
    }

    // MARK: - Resumen Anual
    private func aggregateYear(
        sessions: [SleepSession],
        interval: DateInterval,
        baselineNeed: Double,
        calendar: Calendar
    ) -> SleepPeriodSummary {
        guard !sessions.isEmpty else {
            return emptySummary(timeframe: .year, interval: interval)
        }

        // Agrupar por mes
        var monthlyBuckets: [Int: [SleepSession]] = [:]
        for session in sessions {
            let month = calendar.component(.month, from: session.endDate)
            monthlyBuckets[month, default: []].append(session)
        }

        var dataPoints: [TrendDataPoint] = []
        let sortedMonths = monthlyBuckets.keys.sorted()

        var totalPerf: Double = 0
        var totalEff: Double = 0
        var totalSleep: Double = 0
        var totalInBed: Double = 0

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"

        for month in sortedMonths {
            guard let monthSessions = monthlyBuckets[month], !monthSessions.isEmpty else { continue }
            let mCount = Double(monthSessions.count)
            let avgSleep = monthSessions.reduce(0) { $0 + $1.totalAsleepDuration.inHours } / mCount
            let avgInBed = monthSessions.reduce(0) { $0 + $1.totalInBedDuration.inHours } / mCount
            let avgEff = monthSessions.reduce(0) {
                $0 + calculator.calculateEfficiency(asleepSeconds: $1.totalAsleepDuration, inBedSeconds: $1.totalInBedDuration)
            } / mCount
            let avgPerf = avgSleep / baselineNeed

            totalPerf += avgPerf
            totalEff += avgEff
            totalSleep += avgSleep
            totalInBed += avgInBed

            let representativeDate = monthSessions.first?.endDate ?? Date()
            dataPoints.append(TrendDataPoint(
                date: representativeDate,
                label: monthFormatter.string(from: representativeDate).capitalized,
                sleepHours: avgSleep,
                inBedHours: avgInBed,
                performance: avgPerf,
                efficiency: avgEff
            ))
        }

        let count = Double(max(sortedMonths.count, 1))
        let consistency = calculator.calculateConsistency(sessions: Array(sessions.suffix(14))).score
        let debt = calculator.calculateSleepDebt(sessionsInPast14Days: Array(sessions.suffix(14)), baselineNeedHours: baselineNeed)

        return SleepPeriodSummary(
            timeframe: .year,
            interval: interval,
            averagePerformance: totalPerf / count,
            averageEfficiency: totalEff / count,
            consistencyScore: consistency,
            currentSleepDebtHours: debt,
            averageSleepHours: totalSleep / count,
            averageTimeInBedHours: totalInBed / count,
            stageDistribution: computeDistribution(for: sessions),
            dataPoints: dataPoints,
            primarySession: sessions.last
        )
    }

    // MARK: - Cálculos auxiliares
    private func computeDistribution(for sessions: [SleepSession]) -> [SleepStage: Double] {
        var totalPerStage: [SleepStage: TimeInterval] = [
            .deep: 0, .core: 0, .rem: 0, .awake: 0
        ]
        var totalAsleep: TimeInterval = 0

        for session in sessions {
            totalPerStage[.deep, default: 0] += session.duration(for: .deep)
            totalPerStage[.core, default: 0] += session.duration(for: .core)
            totalPerStage[.rem, default: 0] += session.duration(for: .rem)
            totalPerStage[.awake, default: 0] += session.duration(for: .awake)
            totalAsleep += session.totalAsleepDuration
        }

        guard totalAsleep > 0 else { return [:] }

        return [
            .deep: (totalPerStage[.deep] ?? 0) / totalAsleep,
            .core: (totalPerStage[.core] ?? 0) / totalAsleep,
            .rem: (totalPerStage[.rem] ?? 0) / totalAsleep,
            .awake: (totalPerStage[.awake] ?? 0) / totalAsleep
        ]
    }

    private func emptySummary(timeframe: Timeframe, interval: DateInterval) -> SleepPeriodSummary {
        SleepPeriodSummary(
            timeframe: timeframe,
            interval: interval,
            averagePerformance: 0,
            averageEfficiency: 0,
            consistencyScore: 0,
            currentSleepDebtHours: 0,
            averageSleepHours: 0,
            averageTimeInBedHours: 0,
            stageDistribution: [:],
            dataPoints: [],
            primarySession: nil
        )
    }
}
