//
//  SleepMetrics.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import Foundation
import SwiftUI

/// Estado cualitativo de una métrica para retroalimentación visual en la UI.
public enum MetricStatus: String, Codable, Sendable {
    case optimal = "Óptimo"
    case good = "Bueno"
    case fair = "Aceptable"
    case low = "Atención requerida"

    public var color: Color {
        switch self {
        case .optimal: return Color.green
        case .good: return Color.cyan
        case .fair: return Color.orange
        case .low: return Color.red
        }
    }

    public var systemIcon: String {
        switch self {
        case .optimal: return "checkmark.circle.fill"
        case .good: return "hand.thumbsup.fill"
        case .fair: return "exclamationmark.circle.fill"
        case .low: return "exclamationmark.triangle.fill"
        }
    }
}

/// Conjunto de métricas principales calculadas para una sesión o periodo de sueño.
public struct SleepMetrics: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public let date: Date
    
    // MARK: - Las 4 Métricas Clave Requeridas
    
    /// 1. Rendimiento del sueño (Sleep Performance)
    /// Porcentaje (0.0 - 1.0) que indica qué parte de la necesidad de descanso dinámica se cubrió.
    public let performance: Double
    
    /// 2. Eficiencia del sueño (Sleep Efficiency)
    /// Porcentaje (0.0 - 1.0) del tiempo en cama en el que realmente se estuvo dormido. Ideal >= 90%.
    public let efficiency: Double
    
    /// 3. Consistencia (Consistency)
    /// Puntuación (0.0 - 1.0) que evalúa la regularidad de los horarios de acostarse y levantarse.
    public let consistency: Double
    
    /// 4. Deuda de sueño (Sleep Debt)
    /// Déficit de descanso acumulado en los últimos 14 días (en horas).
    public let sleepDebtHours: Double

    // MARK: - Datos Complementarios
    /// Necesidad dinámica calculada para la noche (en horas)
    public let dynamicNeedHours: Double
    
    /// Horas reales dormidas
    public let actualSleepHours: Double
    
    /// Horas totales en cama
    public let timeInBedHours: Double
    
    /// Desviación estándar de hora de acostarse (en minutos)
    public let bedtimeVarianceMinutes: Double
    
    /// Desviación estándar de hora de despertar (en minutos)
    public let wakeVarianceMinutes: Double

    public init(
        id: UUID = UUID(),
        date: Date,
        performance: Double,
        efficiency: Double,
        consistency: Double,
        sleepDebtHours: Double,
        dynamicNeedHours: Double,
        actualSleepHours: Double,
        timeInBedHours: Double,
        bedtimeVarianceMinutes: Double = 0,
        wakeVarianceMinutes: Double = 0
    ) {
        self.id = id
        self.date = date
        self.performance = min(max(performance, 0.0), 1.5) // Acotado a valores realistas
        self.efficiency = min(max(efficiency, 0.0), 1.0)
        self.consistency = min(max(consistency, 0.0), 1.0)
        self.sleepDebtHours = max(0.0, sleepDebtHours)
        self.dynamicNeedHours = dynamicNeedHours
        self.actualSleepHours = actualSleepHours
        self.timeInBedHours = timeInBedHours
        self.bedtimeVarianceMinutes = bedtimeVarianceMinutes
        self.wakeVarianceMinutes = wakeVarianceMinutes
    }

    // MARK: - Evaluaciones de Estado

    public var performanceStatus: MetricStatus {
        if performance >= 0.90 { return .optimal }
        if performance >= 0.75 { return .good }
        if performance >= 0.60 { return .fair }
        return .low
    }

    public var efficiencyStatus: MetricStatus {
        if efficiency >= 0.90 { return .optimal }
        if efficiency >= 0.85 { return .good }
        if efficiency >= 0.75 { return .fair }
        return .low
    }

    public var consistencyStatus: MetricStatus {
        if consistency >= 0.85 { return .optimal }
        if consistency >= 0.70 { return .good }
        if consistency >= 0.55 { return .fair }
        return .low
    }

    public var debtStatus: MetricStatus {
        if sleepDebtHours <= 1.0 { return .optimal }
        if sleepDebtHours <= 3.0 { return .good }
        if sleepDebtHours <= 6.0 { return .fair }
        return .low
    }
}
