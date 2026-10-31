//
//  Date+Extensions.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import Foundation

public extension Date {
    /// Devuelve el inicio del día según el calendario actual
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Devuelve el fin del día (23:59:59)
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    /// Formatea la hora en formato legible corto (ej. "23:15" o "7:45")
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }

    /// Formatea la fecha de manera abreviada (ej. "31 oct" o "Lun 12")
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }

    /// Nombre del día de la semana (ej. "Lun", "Mar")
    var weekdayShort: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale.current
        return formatter.string(from: self).capitalized
    }

    /// Minutos desde la medianoche para cálculo de consistencia
    var minutesFromMidnight: Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        return Double(hour * 60 + minute)
    }

    /// Minutos normalizados centrados alrededor de la noche (para acostarse entre 20:00 y 04:00)
    /// Para evitar el salto 23:59 -> 00:01:
    /// Las horas 18:00 - 24:00 se mapean a 1080 - 1440.
    /// Las horas 00:00 - 12:00 se mapean a 1440 - 2160 (+24h).
    var continuousNightMinutes: Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        if hour < 12 {
            return Double((hour + 24) * 60 + minute)
        } else {
            return Double(hour * 60 + minute)
        }
    }
}
