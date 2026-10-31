//
//  Timeframe.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import Foundation

/// Periodos de análisis requeridos para la agregación de estadísticas de sueño.
public enum Timeframe: String, CaseIterable, Identifiable, Sendable {
    case day = "Día"
    case week = "Semana"
    case month = "Mes"
    case year = "Año"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .day: return "Diario"
        case .week: return "Semanal"
        case .month: return "Mensual"
        case .year: return "Anual"
        }
    }

    /// Rango de fechas correspondiente al periodo tomando como referencia una fecha base
    public func dateInterval(for referenceDate: Date = Date(), calendar: Calendar = .current) -> DateInterval {
        switch self {
        case .day:
            let start = calendar.startOfDay(for: referenceDate)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? referenceDate
            return DateInterval(start: start, end: end)
        case .week:
            let end = calendar.startOfDay(for: referenceDate).addingTimeInterval(86400)
            let start = calendar.date(byAdding: .day, value: -7, to: end) ?? referenceDate
            return DateInterval(start: start, end: end)
        case .month:
            let end = calendar.startOfDay(for: referenceDate).addingTimeInterval(86400)
            let start = calendar.date(byAdding: .day, value: -30, to: end) ?? referenceDate
            return DateInterval(start: start, end: end)
        case .year:
            let end = calendar.startOfDay(for: referenceDate).addingTimeInterval(86400)
            let start = calendar.date(byAdding: .year, value: -1, to: end) ?? referenceDate
            return DateInterval(start: start, end: end)
        }
    }
}
