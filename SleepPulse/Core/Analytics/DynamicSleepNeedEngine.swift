//
//  DynamicSleepNeedEngine.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import Foundation

/// Motor de cálculo para la necesidad dinámica de sueño (Dynamic Sleep Need).
/// Adapta el descanso requerido combinando la necesidad basal del usuario,
/// el recargo por deuda de sueño acumulada y el gasto fisiológico del día.
public final class DynamicSleepNeedEngine: Sendable {
    public static let shared = DynamicSleepNeedEngine()

    /// Necesidad basal estándar en adultos (en horas)
    public let defaultBaselineHours: Double

    public init(defaultBaselineHours: Double = 8.0) {
        self.defaultBaselineHours = defaultBaselineHours
    }

    /// Calcula la necesidad dinámica para la noche actual:
    /// - `baselineHours`: Base genética/personal (por defecto 8h).
    /// - `accumulatedDebtHours`: Deuda acumulada de los últimos 14 días.
    /// - `recentExertionBonusHours`: Demanda extra por ejercicio/estrés (ej. 0.25h - 0.5h).
    public func calculateDynamicNeed(
        baselineHours: Double? = nil,
        accumulatedDebtHours: Double,
        recentExertionBonusHours: Double = 0.0
    ) -> Double {
        let base = baselineHours ?? defaultBaselineHours
        
        // Recargo de deuda: El cuerpo no puede recuperar 10 horas en una sola noche sin fragmentar el ciclo.
        // Se amortiza distribuyendo aproximadamente entre el 20% y 25% de la deuda acumulada.
        let debtRecoveryFactor = 0.22
        let debtSurcharge = min(accumulatedDebtHours * debtRecoveryFactor, 1.75) // Máximo +1h 45m de recargo
        
        // Exigencia total calculada
        let totalNeed = base + debtSurcharge + recentExertionBonusHours
        
        // Límites fisiológicos razonables (mínimo 6.5h, máximo 11h)
        return min(max(totalNeed, 6.5), 11.0)
    }
}
