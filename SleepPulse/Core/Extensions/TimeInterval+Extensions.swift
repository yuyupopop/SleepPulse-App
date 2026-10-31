//
//  TimeInterval+Extensions.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import Foundation

public extension TimeInterval {
    /// Convierte el intervalo a formato horas y minutos "7h 45m"
    var hoursAndMinutesString: String {
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }

    /// Valor en horas con decimales (ej. 7.5 para 7 horas y media)
    var inHours: Double {
        return self / 3600.0
    }
}

public extension Double {
    /// Formatea horas con formato "Xh Ym"
    var formattedHoursAndMinutes: String {
        let totalMinutes = Int((self * 60).rounded())
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }

    /// Formatea porcentaje como "92%"
    var formattedPercentage: String {
        return "\(Int((self * 100).rounded()))%"
    }
}
