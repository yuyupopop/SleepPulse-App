//
//  SleepPulseApp.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import SwiftUI

@main
struct SleepPulseApp: App {
    // Si el entorno se ejecuta en el simulador o sin HealthStore real disponible,
    // se conmuta con fluidez al servicio sintético realista para permitir el desarrollo continuo.
    private let healthKitService: HealthKitServiceProtocol = {
        #if targetEnvironment(simulator)
        return MockHealthKitService.shared
        #else
        return HealthKitManager.shared.isHealthDataAvailable ? HealthKitManager.shared : MockHealthKitService.shared
        #endif
    }()

    var body: some Scene {
        WindowGroup {
            DashboardView(
                viewModel: DashboardViewModel(
                    healthKitService: healthKitService
                )
            )
            .preferredColorScheme(.dark)
        }
    }
}
