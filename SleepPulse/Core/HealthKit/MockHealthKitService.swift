//
//  MockHealthKitService.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import Foundation

/// Servicio simulado que emula con alta precisión la estructura de datos
/// generada por un Apple Watch a lo largo de un año completo.
public final class MockHealthKitService: HealthKitServiceProtocol, @unchecked Sendable {
    public static let shared = MockHealthKitService()

    public var isHealthDataAvailable: Bool { true }
    public var shouldSucceedAuthorization: Bool = true

    private var cachedSessions: [SleepSession] = []

    public init() {
        self.cachedSessions = generateYearOfSleepSessions()
    }

    public func requestAuthorization() async throws -> Bool {
        try await Task.sleep(nanoseconds: 300_000_000) // 300ms de latencia simulada
        if shouldSucceedAuthorization {
            return true
        } else {
            throw HealthKitError.permissionDenied
        }
    }

    public func fetchSleepSessions(from startDate: Date, to endDate: Date) async throws -> [SleepSession] {
        try await Task.sleep(nanoseconds: 200_000_000)
        return cachedSessions.filter { $0.endDate >= startDate && $0.endDate <= endDate }
    }

    public func fetchLatestSleepSession() async throws -> SleepSession? {
        return cachedSessions.last
    }

    // MARK: - Generador Sintético de Ciclos Ultradianos de Sueño
    /// Emula arquitectura de sueño real:
    /// - Ciclos de 90 a 110 minutos.
    /// - Sueño profundo (Deep) predominante en el primer tercio de la noche.
    /// - Sueño REM predominante en el último tercio de la noche (madrugada).
    /// - Microdespertares normales de 2-5 minutos.
    private func generateYearOfSleepSessions() -> [SleepSession] {
        var sessions: [SleepSession] = []
        let calendar = Calendar.current
        let today = Date()

        for dayOffset in (0...365).reversed() {
            guard let sessionDate = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            // Variabilidad de hora de acostarse (ej. 23:15 +- 45 min)
            let bedtimeRandomMinutes = Int.random(in: -45...50)
            var bedtimeComponents = calendar.dateComponents([.year, .month, .day], from: sessionDate)
            bedtimeComponents.hour = 23
            bedtimeComponents.minute = 15 + bedtimeRandomMinutes
            
            guard let bedtime = calendar.date(from: bedtimeComponents) else { continue }
            
            // Duración objetivo de 6.5 a 8.5 horas
            let totalSleepMinutes = Double.random(in: 400...510) // 6.6h a 8.5h
            let sessionEndDate = bedtime.addingTimeInterval(totalSleepMinutes * 60)
            
            let samples = generateHypnogramSamples(startDate: bedtime, endDate: sessionEndDate)
            
            let session = SleepSession(
                id: UUID(),
                date: calendar.startOfDay(for: sessionEndDate),
                startDate: bedtime,
                endDate: sessionEndDate,
                samples: samples,
                averageHeartRate: Double.random(in: 52...64)
            )
            sessions.append(session)
        }

        return sessions
    }

    private func generateHypnogramSamples(startDate: Date, endDate: Date) -> [SleepSample] {
        var samples: [SleepSample] = []
        var currentTime = startDate
        let totalDuration = endDate.timeIntervalSince(startDate)

        // Pequeño despertar al inicio
        let initialAwakeDuration = TimeInterval.random(in: 300...600) // 5 a 10 min
        let awakeEnd = min(currentTime.addingTimeInterval(initialAwakeDuration), endDate)
        samples.append(SleepSample(startDate: currentTime, endDate: awakeEnd, stage: .awake))
        currentTime = awakeEnd

        var cycleIndex = 0

        while currentTime < endDate {
            cycleIndex += 1
            let progressThroughNight = currentTime.timeIntervalSince(startDate) / totalDuration // 0.0 a 1.0

            // 1. Fase Core inicial del ciclo (15 - 30 min)
            let coreDuration = TimeInterval.random(in: 15...30) * 60
            let coreEnd = min(currentTime.addingTimeInterval(coreDuration), endDate)
            samples.append(SleepSample(startDate: currentTime, endDate: coreEnd, stage: .core))
            currentTime = coreEnd
            guard currentTime < endDate else { break }

            // 2. Fase Deep (Más prolongada al inicio de la noche, disminuye hacia el final)
            let deepMinutes = (1.0 - progressThroughNight) * Double.random(in: 25...45)
            if deepMinutes > 5 {
                let deepEnd = min(currentTime.addingTimeInterval(deepMinutes * 60), endDate)
                samples.append(SleepSample(startDate: currentTime, endDate: deepEnd, stage: .deep))
                currentTime = deepEnd
                guard currentTime < endDate else { break }
            }

            // 3. Regreso a fase Core
            let core2Duration = TimeInterval.random(in: 10...20) * 60
            let core2End = min(currentTime.addingTimeInterval(core2Duration), endDate)
            samples.append(SleepSample(startDate: currentTime, endDate: core2End, stage: .core))
            currentTime = core2End
            guard currentTime < endDate else { break }

            // 4. Fase REM (Más prolongada hacia la mañana)
            let remMinutes = (progressThroughNight + 0.3) * Double.random(in: 18...38)
            let remEnd = min(currentTime.addingTimeInterval(remMinutes * 60), endDate)
            samples.append(SleepSample(startDate: currentTime, endDate: remEnd, stage: .rem))
            currentTime = remEnd
            guard currentTime < endDate else { break }

            // 5. Ocasional microdespertar entre ciclos (2 a 4 min)
            if Bool.random() {
                let microAwakeEnd = min(currentTime.addingTimeInterval(Double.random(in: 120...240)), endDate)
                samples.append(SleepSample(startDate: currentTime, endDate: microAwakeEnd, stage: .awake))
                currentTime = microAwakeEnd
            }
        }

        // Agregar muestra general 'inBed' envolvente para representar la permanencia en cama
        samples.append(SleepSample(startDate: startDate, endDate: endDate, stage: .inBed))

        return samples
    }
}
