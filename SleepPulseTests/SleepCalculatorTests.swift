//
//  SleepCalculatorTests.swift
//  SleepPulseTests
//
//  Created by Antigravity on 31/10/2026.
//

import XCTest
@testable import SleepPulse

final class SleepCalculatorTests: XCTestCase {
    var sut: SleepCalculator!
    var dynamicNeedEngine: DynamicSleepNeedEngine!

    override func setUp() {
        super.setUp()
        dynamicNeedEngine = DynamicSleepNeedEngine(defaultBaselineHours: 8.0)
        sut = SleepCalculator(dynamicNeedEngine: dynamicNeedEngine)
    }

    override func tearDown() {
        sut = nil
        dynamicNeedEngine = nil
        super.tearDown()
    }

    // MARK: - 1. Pruebas de Rendimiento del Sueño (Sleep Performance)
    func testSleepPerformanceCalculation() {
        // Durmió 7.2 horas con una necesidad dinámica de 8.0 horas -> 90.0%
        let performance = sut.calculatePerformance(actualHours: 7.2, dynamicNeedHours: 8.0)
        XCTAssertEqual(performance, 0.90, accuracy: 0.001)

        // Durmió 8.5 horas con necesidad de 8.0 -> 106.25%
        let surplusPerf = sut.calculatePerformance(actualHours: 8.5, dynamicNeedHours: 8.0)
        XCTAssertEqual(surplusPerf, 1.0625, accuracy: 0.001)

        // Manejo seguro de divisor cero
        let zeroPerf = sut.calculatePerformance(actualHours: 7.0, dynamicNeedHours: 0.0)
        XCTAssertEqual(zeroPerf, 0.0)
    }

    // MARK: - 2. Pruebas de Eficiencia del Sueño (Sleep Efficiency)
    func testSleepEfficiencyCalculation() {
        // En cama: 8 horas (28800 seg), dormido: 7.2 horas (25920 seg) -> 90%
        let asleepSeconds: TimeInterval = 7.2 * 3600
        let inBedSeconds: TimeInterval = 8.0 * 3600
        let efficiency = sut.calculateEfficiency(asleepSeconds: asleepSeconds, inBedSeconds: inBedSeconds)
        
        XCTAssertEqual(efficiency, 0.90, accuracy: 0.001)

        // Caso límite: tiempo en cama cero
        let zeroEfficiency = sut.calculateEfficiency(asleepSeconds: 0, inBedSeconds: 0)
        XCTAssertEqual(zeroEfficiency, 0.0)
    }

    // MARK: - 3. Pruebas de Consistencia (Sleep Consistency)
    func testSleepConsistencyWithRegularSchedule() {
        let calendar = Calendar.current
        let baseDate = Date()
        var sessions: [SleepSession] = []

        // Crear 7 días con acostarse exactamente a las 23:00 y despertar a las 07:00
        for i in 0..<7 {
            let sessionDate = calendar.date(byAdding: .day, value: -i, to: baseDate)!
            var startComps = calendar.dateComponents([.year, .month, .day], from: sessionDate)
            startComps.hour = 23
            startComps.minute = 0
            let start = calendar.date(from: startComps)!
            let end = start.addingTimeInterval(8 * 3600) // 07:00

            let sample = SleepSample(startDate: start, endDate: end, stage: .core)
            sessions.append(SleepSession(date: end, startDate: start, endDate: end, samples: [sample]))
        }

        let result = sut.calculateConsistency(sessions: sessions)
        // Desviación cero = 100% de consistencia (1.0)
        XCTAssertEqual(result.bedtimeVarianceMin, 0.0, accuracy: 0.001)
        XCTAssertEqual(result.wakeVarianceMin, 0.0, accuracy: 0.001)
        XCTAssertEqual(result.score, 1.0, accuracy: 0.001)
    }

    func testSleepConsistencyWithIrregularSchedule() {
        let calendar = Calendar.current
        let baseDate = Date()
        var sessions: [SleepSession] = []

        // Simular horarios erráticos alternando entre 22:00 y 02:30 (+4.5 horas de variación)
        let hours = [22, 2, 23, 1, 22, 3, 23]
        for (i, hour) in hours.enumerated() {
            let sessionDate = calendar.date(byAdding: .day, value: -i, to: baseDate)!
            var startComps = calendar.dateComponents([.year, .month, .day], from: sessionDate)
            startComps.hour = hour
            startComps.minute = 0
            let start = calendar.date(from: startComps)!
            let end = start.addingTimeInterval(7 * 3600)

            let sample = SleepSample(startDate: start, endDate: end, stage: .core)
            sessions.append(SleepSession(date: end, startDate: start, endDate: end, samples: [sample]))
        }

        let result = sut.calculateConsistency(sessions: sessions)
        XCTAssertGreaterThan(result.bedtimeVarianceMin, 60.0) // Desviación mayor a 1 hora
        XCTAssertLessThan(result.score, 0.70) // Consistencia significativamente degradada
    }

    // MARK: - 4. Pruebas de Deuda de Sueño (Sleep Debt)
    func testSleepDebtAccumulationOver14Days() {
        let calendar = Calendar.current
        let baseDate = Date()
        var sessions: [SleepSession] = []

        // Simular 14 días durmiendo solo 6 horas por noche frente a una necesidad basal de 8 horas (déficit de 2h/día)
        for i in 0..<14 {
            let dayDate = calendar.date(byAdding: .day, value: -i, to: baseDate)!
            let start = dayDate
            let end = start.addingTimeInterval(6 * 3600) // 6 horas

            let sample = SleepSample(startDate: start, endDate: end, stage: .core)
            sessions.append(SleepSession(date: end, startDate: start, endDate: end, samples: [sample]))
        }

        let debt = sut.calculateSleepDebt(sessionsInPast14Days: sessions, baselineNeedHours: 8.0)
        // La deuda acumulada debe ser alta (> 8 horas)
        XCTAssertGreaterThan(debt, 8.0)
    }

    // MARK: - 5. Necesidad Dinámica adaptada a Deuda
    func testDynamicSleepNeedIncreasesWithDebt() {
        let baseNeed = 8.0
        let zeroDebtNeed = dynamicNeedEngine.calculateDynamicNeed(baselineHours: baseNeed, accumulatedDebtHours: 0.0)
        XCTAssertEqual(zeroDebtNeed, 8.0)

        // Con 4 horas de deuda acumulada
        let highDebtNeed = dynamicNeedEngine.calculateDynamicNeed(baselineHours: baseNeed, accumulatedDebtHours: 4.0)
        // Debe agregar recargo amortizado (aprox 22% de 4h = +0.88h)
        XCTAssertGreaterThan(highDebtNeed, baseNeed)
        XCTAssertEqual(highDebtNeed, 8.88, accuracy: 0.05)
    }
}
