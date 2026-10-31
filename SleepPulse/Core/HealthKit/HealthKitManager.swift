//
//  HealthKitManager.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import Foundation
import HealthKit

public enum HealthKitError: LocalizedError {
    case notAvailableOnDevice
    case permissionDenied
    case missingUsageDescription
    case queryFailed(String)

    public var errorDescription: String? {
        switch self {
        case .notAvailableOnDevice:
            return "HealthKit no está disponible en este dispositivo."
        case .permissionDenied:
            return "El acceso a los datos de Apple Salud ha sido denegado o no está configurado."
        case .missingUsageDescription:
            return "Falta NSHealthShareUsageDescription en Info.plist."
        case .queryFailed(let reason):
            return "Error al consultar HealthKit: \(reason)"
        }
    }
}

/// Implementación en producción del servicio HealthKit para iOS y Apple Watch.
public final class HealthKitManager: HealthKitServiceProtocol, @unchecked Sendable {
    public static let shared = HealthKitManager()

    public var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    public init() {}

    private func getHealthStore() throws -> HKHealthStore {
        guard isHealthDataAvailable else {
            throw HealthKitError.notAvailableOnDevice
        }
        return HKHealthStore()
    }

    /// Solicita permisos para acceder a las muestras de análisis de sueño registradas por Apple Watch
    public func requestAuthorization() async throws -> Bool {
        // Verificación previa de seguridad para evitar excepciones de Objective-C
        guard Bundle.main.object(forInfoDictionaryKey: "NSHealthShareUsageDescription") != nil else {
            throw HealthKitError.missingUsageDescription
        }

        let store = try getHealthStore()

        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthKitError.queryFailed("Identificador .sleepAnalysis no disponible")
        }

        var typesToRead: Set<HKObjectType> = [sleepType]
        if let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) {
            typesToRead.insert(heartRateType)
        }

        return try await withCheckedThrowingContinuation { continuation in
            store.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }

    /// Obtiene las sesiones de sueño dentro de una ventana temporal
    public func fetchSleepSessions(from startDate: Date, to endDate: Date) async throws -> [SleepSession] {
        let store = try getHealthStore()

        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthKitError.queryFailed("Identificador .sleepAnalysis inválido")
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let samples: [HKCategorySample] = try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let categorySamples = (results as? [HKCategorySample]) ?? []
                continuation.resume(returning: categorySamples)
            }
            store.execute(query)
        }

        return groupSamplesIntoSessions(samples)
    }

    /// Obtiene la última sesión de sueño registrada
    public func fetchLatestSleepSession() async throws -> SleepSession? {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -3, to: endDate) ?? endDate
        let sessions = try await fetchSleepSessions(from: startDate, to: endDate)
        return sessions.last
    }

    // MARK: - Algoritmo de Segmentación y Agrupación en Sesiones de Sueño
    private func groupSamplesIntoSessions(_ samples: [HKCategorySample]) -> [SleepSession] {
        guard !samples.isEmpty else { return [] }

        let domainSamples: [SleepSample] = samples.compactMap { sample in
            guard let stage = SleepStage(hkValue: sample.value) else { return nil }
            return SleepSample(
                id: sample.uuid,
                startDate: sample.startDate,
                endDate: sample.endDate,
                stage: stage,
                sourceName: sample.sourceRevision.source.name
            )
        }.sorted(by: { $0.startDate < $1.startDate })

        guard !domainSamples.isEmpty else { return [] }

        var sessions: [SleepSession] = []
        var currentSessionSamples: [SleepSample] = []
        let maxGapBetweenSamples: TimeInterval = 3.0 * 3600

        for sample in domainSamples {
            if let lastSample = currentSessionSamples.last {
                let gap = sample.startDate.timeIntervalSince(lastSample.endDate)
                if gap > maxGapBetweenSamples {
                    if let session = createSession(from: currentSessionSamples) {
                        sessions.append(session)
                    }
                    currentSessionSamples = [sample]
                } else {
                    currentSessionSamples.append(sample)
                }
            } else {
                currentSessionSamples.append(sample)
            }
        }

        if let finalSession = createSession(from: currentSessionSamples) {
            sessions.append(finalSession)
        }

        return sessions
    }

    private func createSession(from samples: [SleepSample]) -> SleepSession? {
        guard let first = samples.first, let last = samples.last else { return nil }
        let start = first.startDate
        let end = samples.map(\.endDate).max() ?? last.endDate
        
        return SleepSession(
            date: Calendar.current.startOfDay(for: end),
            startDate: start,
            endDate: end,
            samples: samples
        )
    }
}
