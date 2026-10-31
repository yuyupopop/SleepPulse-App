//
//  HealthKitServiceProtocol.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import Foundation

/// Protocolo que abstrae el acceso a HealthKit para permitir inyección de dependencias,
/// pruebas unitarias e instantáneas en SwiftUI Canvas sin requerir hardware físico.
public protocol HealthKitServiceProtocol: Sendable {
    /// Indica si HealthKit está disponible en el dispositivo actual
    var isHealthDataAvailable: Bool { get }

    /// Solicita autorización para leer datos de análisis de sueño y ritmo cardíaco
    func requestAuthorization() async throws -> Bool

    /// Obtiene las sesiones de sueño dentro de un intervalo temporal determinado
    func fetchSleepSessions(from startDate: Date, to endDate: Date) async throws -> [SleepSession]

    /// Obtiene la sesión de sueño más reciente
    func fetchLatestSleepSession() async throws -> SleepSession?
}
