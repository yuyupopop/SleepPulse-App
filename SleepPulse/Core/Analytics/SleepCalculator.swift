//
//  SleepCalculator.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import Foundation

/// Motor de analítica de sueño que computa las 4 métricas clave:
/// Rendimiento, Eficiencia, Consistencia y Deuda de sueño.
public final class SleepCalculator: Sendable {
    public static let shared = SleepCalculator()

    private let dynamicNeedEngine: DynamicSleepNeedEngine

    public init(dynamicNeedEngine: DynamicSleepNeedEngine = .shared) {
        self.dynamicNeedEngine = dynamicNeedEngine
    }

    // MARK: - 1. Rendimiento del Sueño (Sleep Performance)
    /// Calcula qué porcentaje de la necesidad de descanso del cuerpo se cubrió:
    /// (Horas dormidas / Necesidad dinámica) * 100%
    public func calculatePerformance(actualHours: Double, dynamicNeedHours: Double) -> Double {
        guard dynamicNeedHours > 0 else { return 0.0 }
        return actualHours / dynamicNeedHours
    }

    // MARK: - 2. Eficiencia del Sueño (Sleep Efficiency)
    /// Mide el porcentaje del tiempo total pasado en la cama en el que realmente se estuvo dormido.
    /// Lo ideal es un 90% o más.
    public func calculateEfficiency(asleepSeconds: TimeInterval, inBedSeconds: TimeInterval) -> Double {
        guard inBedSeconds > 0 else { return 0.0 }
        let efficiency = asleepSeconds / inBedSeconds
        return min(max(efficiency, 0.0), 1.0)
    }

    // MARK: - 3. Consistencia (Consistency)
    /// Evalúa la regularidad con la que la persona se acuesta y se levanta comparando
    /// los horarios de los últimos días (ventana habitual de 7 días).
    /// Devuelve una tupla con la puntuación de 0.0 a 1.0 y las desviaciones típicas en minutos.
    public func calculateConsistency(sessions: [SleepSession]) -> (score: Double, bedtimeVarianceMin: Double, wakeVarianceMin: Double) {
        guard sessions.count >= 2 else {
            // Sin datos suficientes para calcular dispersión
            return (score: 0.85, bedtimeVarianceMin: 0, wakeVarianceMin: 0)
        }

        // Obtener minutos normalizados continuos nocturnos para hora de acostarse
        let bedtimes = sessions.map { $0.startDate.continuousNightMinutes }
        let wakeTimes = sessions.map { $0.endDate.minutesFromMidnight }

        let bedtimeStdDev = standardDeviation(bedtimes)
        let wakeStdDev = standardDeviation(wakeTimes)

        // Escalamiento del score:
        // Si ambas desviaciones son 0 minutos -> 100% consistencia.
        // Si la desviación media combinada es de 30 min -> ~90%
        // Si la desviación es >= 150 min (2.5 horas de desfase) -> decae hacia 30% o menos.
        let combinedVariance = (bedtimeStdDev + wakeStdDev) / 2.0
        let penaltyPerMinute = 1.0 / 180.0 // 180 minutos de desviación llevan la penalización al 100%
        let score = max(0.0, 1.0 - (combinedVariance * penaltyPerMinute))

        return (score: score, bedtimeVarianceMin: bedtimeStdDev, wakeVarianceMin: wakeStdDev)
    }

    // MARK: - 4. Deuda de Sueño (Sleep Debt)
    /// Calcula el déficit de descanso acumulado a lo largo de los últimos 14 días
    /// en comparación con lo que el cuerpo realmente requería.
    /// Para cada día dentro de la ventana de 14 días:
    /// Deficit_i = max(0, Target_i - Actual_i). Si un día duerme de más,
    /// se descuenta parcialmente la deuda acumulada existente.
    public func calculateSleepDebt(
        sessionsInPast14Days: [SleepSession],
        baselineNeedHours: Double = 8.0,
        calendar: Calendar = .current
    ) -> Double {
        guard !sessionsInPast14Days.isEmpty else { return 0.0 }

        // Agrupar sesiones por día de calendario (tomando la fecha de fin/despertar)
        var dailySleep: [Date: Double] = [:]
        for session in sessionsInPast14Days {
            let dayKey = calendar.startOfDay(for: session.endDate)
            dailySleep[dayKey, default: 0.0] += session.totalAsleepDuration.inHours
        }

        // Simulación temporal acumulativa en los 14 días
        // Se aplica un factor de decay fisiológico natural (la deuda muy vieja de hace 12 días
        // impacta ligeramente menos que la de ayer).
        let sortedDays = dailySleep.keys.sorted()
        var runningDebt: Double = 0.0

        for day in sortedDays {
            let sleptHours = dailySleep[day] ?? baselineNeedHours
            let delta = baselineNeedHours - sleptHours

            if delta > 0 {
                // Déficit: aumenta la deuda
                runningDebt += delta
            } else {
                // Superávit: amortiza hasta el 50% del exceso de sueño contra la deuda acumulada
                // (no se puede "almacenar" sueño infinito a futuro, pero sí amortizar deuda)
                let surplus = abs(delta)
                runningDebt = max(0.0, runningDebt - (surplus * 0.5))
            }

            // Factor de decay metabólico diario (aprox 3% por día)
            runningDebt *= 0.97
        }

        // Acotar la deuda a un rango fisiológico medible (máx. 14 horas de deuda)
        return min(max(runningDebt, 0.0), 14.0)
    }

    // MARK: - Cálculo Consolidado
    /// Calcula el conjunto completo de métricas para la sesión actual considerando el historial reciente.
    public func computeMetrics(
        for session: SleepSession,
        recentSessions: [SleepSession],
        baselineNeedHours: Double = 8.0
    ) -> SleepMetrics {
        // Filtrar sesiones de los últimos 14 días (hasta la sesión actual)
        let fourteenDaysAgo = Calendar.current.date(byAdding: .day, value: -14, to: session.endDate) ?? session.endDate
        let sessionsLast14Days = recentSessions.filter { $0.endDate >= fourteenDaysAgo && $0.endDate <= session.endDate }

        // 1. Calcular deuda previa acumulada
        let sleepDebt = calculateSleepDebt(sessionsInPast14Days: sessionsLast14Days, baselineNeedHours: baselineNeedHours)

        // 2. Calcular necesidad dinámica para esta sesión
        let dynamicNeed = dynamicNeedEngine.calculateDynamicNeed(
            baselineHours: baselineNeedHours,
            accumulatedDebtHours: sleepDebt
        )

        // 3. Rendimiento
        let actualHours = session.totalAsleepDuration.inHours
        let performance = calculatePerformance(actualHours: actualHours, dynamicNeedHours: dynamicNeed)

        // 4. Eficiencia
        let efficiency = calculateEfficiency(
            asleepSeconds: session.totalAsleepDuration,
            inBedSeconds: session.totalInBedDuration
        )

        // 5. Consistencia (usando los últimos 7 días)
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: session.endDate) ?? session.endDate
        let sessionsLast7Days = recentSessions.filter { $0.endDate >= sevenDaysAgo && $0.endDate <= session.endDate }
        let consistencyResult = calculateConsistency(sessions: sessionsLast7Days.isEmpty ? [session] : sessionsLast7Days)

        return SleepMetrics(
            date: session.date,
            performance: performance,
            efficiency: efficiency,
            consistency: consistencyResult.score,
            sleepDebtHours: sleepDebt,
            dynamicNeedHours: dynamicNeed,
            actualSleepHours: actualHours,
            timeInBedHours: session.totalInBedDuration.inHours,
            bedtimeVarianceMinutes: consistencyResult.bedtimeVarianceMin,
            wakeVarianceMinutes: consistencyResult.wakeVarianceMin
        )
    }

    // MARK: - Funciones Estadísticas de Apoyo
    private func standardDeviation(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0.0 }
        let mean = values.reduce(0, +) / Double(values.count)
        let sumSquaredDifferences = values.reduce(0) { $0 + pow($1 - mean, 2) }
        return sqrt(sumSquaredDifferences / Double(values.count - 1))
    }
}
