//
//  SleepStage.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import Foundation
import SwiftUI
import HealthKit

/// Representa las distintas fases y estados de sueño registrados por Apple Watch / HealthKit.
public enum SleepStage: String, CaseIterable, Identifiable, Codable, Sendable {
    case deep = "Profundo"
    case core = "Esencial / Ligero"
    case rem = "REM"
    case awake = "Despierto"
    case unspecified = "Dormido (General)"
    case inBed = "En Cama"

    public var id: String { rawValue }

    /// Nivel numérico de profundidad para graficar el hipnograma.
    /// Deep (1) en la base, Core (2), REM (3), Despierto (4) arriba.
    public var depthLevel: Int {
        switch self {
        case .deep: return 1
        case .core: return 2
        case .rem: return 3
        case .awake: return 4
        case .unspecified: return 2
        case .inBed: return 0
        }
    }

    /// Color temático representativo de la fase
    public var color: Color {
        switch self {
        case .deep:
            return Color(red: 0.15, green: 0.25, blue: 0.65) // Azul marino profundo
        case .core:
            return Color(red: 0.25, green: 0.55, blue: 0.95) // Celeste vibrante
        case .rem:
            return Color(red: 0.55, green: 0.35, blue: 0.95) // Violeta eléctrico
        case .awake:
            return Color(red: 0.95, green: 0.45, blue: 0.35) // Coral / Naranja
        case .unspecified:
            return Color(red: 0.40, green: 0.50, blue: 0.70)
        case .inBed:
            return Color(white: 0.3)
        }
    }

    /// Nombre amigable corto
    public var shortName: String {
        switch self {
        case .deep: return "Profundo"
        case .core: return "Esencial"
        case .rem: return "REM"
        case .awake: return "Despierto"
        case .unspecified: return "Dormido"
        case .inBed: return "En cama"
        }
    }

    /// Icono SF Symbol correspondiente
    public var icon: String {
        switch self {
        case .deep: return "moon.zzz.fill"
        case .core: return "moon.fill"
        case .rem: return "sparkles"
        case .awake: return "eye.fill"
        case .unspecified: return "bed.double.fill"
        case .inBed: return "bed.double"
        }
    }

    /// Rango de referencia saludable estándar en adultos (% del tiempo total de sueño)
    public var healthyReferenceRange: ClosedRange<Double> {
        switch self {
        case .deep: return 0.15...0.25 // 15% - 25%
        case .core: return 0.45...0.60 // 45% - 60%
        case .rem: return 0.20...0.25  // 20% - 25%
        case .awake: return 0.05...0.12 // 5% - 12% (del tiempo en cama)
        default: return 0.0...1.0
        }
    }

    /// Inicialización a partir del valor entero de HKCategoryValueSleepAnalysis
    public init?(hkValue: Int) {
        if #available(iOS 16.0, *) {
            switch hkValue {
            case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                self = .deep
            case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                self = .core
            case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                self = .rem
            case HKCategoryValueSleepAnalysis.awake.rawValue:
                self = .awake
            case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
                self = .unspecified
            case HKCategoryValueSleepAnalysis.inBed.rawValue:
                self = .inBed
            default:
                return nil
            }
        } else {
            switch hkValue {
            case HKCategoryValueSleepAnalysis.inBed.rawValue:
                self = .inBed
            case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
                self = .unspecified
            case HKCategoryValueSleepAnalysis.awake.rawValue:
                self = .awake
            default:
                return nil
            }
        }
    }
}
