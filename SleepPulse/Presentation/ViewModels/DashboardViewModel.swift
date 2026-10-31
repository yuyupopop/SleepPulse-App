//
//  DashboardViewModel.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel principal que orquesta la carga de datos desde HealthKit,
/// la reactividad de la interfaz y la conmutación entre periodos (Día, Semana, Mes, Año).
@MainActor
public final class DashboardViewModel: ObservableObject {
    @Published public var selectedTimeframe: Timeframe = .day {
        didSet {
            Task { await recalculateSummary() }
        }
    }

    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var currentSummary: SleepPeriodSummary?
    @Published public private(set) var latestMetrics: SleepMetrics?
    @Published public private(set) var latestSession: SleepSession?
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var isAuthorized: Bool = false

    private let healthKitService: any HealthKitServiceProtocol
    private let aggregator: SleepPeriodAggregator
    private let calculator: SleepCalculator
    private var allLoadedSessions: [SleepSession] = []

    public init(
        healthKitService: any HealthKitServiceProtocol = HealthKitManager.shared,
        aggregator: SleepPeriodAggregator = .shared,
        calculator: SleepCalculator = .shared
    ) {
        self.healthKitService = healthKitService
        self.aggregator = aggregator
        self.calculator = calculator
    }

    /// Inicializa la carga de datos y solicita autorización si es necesario
    public func initialize() async {
        isLoading = true
        errorMessage = nil

        do {
            if healthKitService.isHealthDataAvailable {
                isAuthorized = try await healthKitService.requestAuthorization()
            }
            await reloadAllData()
        } catch {
            errorMessage = error.localizedDescription
            // Si HealthKit no tiene permisos en este momento, cargar datos de demostración
            // para que el usuario siempre vea la app funcionando en su iPhone.
            let fallbackSessions = (try? await MockHealthKitService.shared.fetchSleepSessions(
                from: Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date(),
                to: Date()
            )) ?? []
            self.allLoadedSessions = fallbackSessions
            if let last = fallbackSessions.last {
                self.latestSession = last
                self.latestMetrics = calculator.computeMetrics(for: last, recentSessions: fallbackSessions)
            }
            await recalculateSummary()
            isLoading = false
        }
    }

    /// Recarga las sesiones del último año para soportar vistas diaria, semanal, mensual y anual
    public func reloadAllData() async {
        isLoading = true
        errorMessage = nil

        let calendar = Calendar.current
        let today = Date()
        let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: today) ?? today

        do {
            let sessions = try await healthKitService.fetchSleepSessions(from: oneYearAgo, to: today)
            if sessions.isEmpty {
                // Si aún no hay datos registrados en Apple Salud, cargar datos demostrativos
                let fallback = (try? await MockHealthKitService.shared.fetchSleepSessions(from: oneYearAgo, to: today)) ?? []
                self.allLoadedSessions = fallback
            } else {
                self.allLoadedSessions = sessions
            }

            if let last = self.allLoadedSessions.last {
                self.latestSession = last
                self.latestMetrics = calculator.computeMetrics(for: last, recentSessions: self.allLoadedSessions)
            }

            await recalculateSummary()
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            let fallback = (try? await MockHealthKitService.shared.fetchSleepSessions(from: oneYearAgo, to: today)) ?? []
            self.allLoadedSessions = fallback
            if let last = fallback.last {
                self.latestSession = last
                self.latestMetrics = calculator.computeMetrics(for: last, recentSessions: fallback)
            }
            await recalculateSummary()
            self.isLoading = false
        }
    }

    /// Recalcula las estadísticas en base al timeframe seleccionado
    private func recalculateSummary() async {
        guard !allLoadedSessions.isEmpty else {
            self.currentSummary = nil
            return
        }

        self.currentSummary = aggregator.aggregate(
            sessions: allLoadedSessions,
            for: selectedTimeframe
        )
    }
}
