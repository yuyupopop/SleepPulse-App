//
//  SleepPulseApp.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import SwiftUI

#if !SWIFT_PACKAGE
@main
#endif
public struct SleepPulseApp: App {
    public init() {}

    private let healthKitService: HealthKitServiceProtocol = {
        #if targetEnvironment(simulator)
        return MockHealthKitService.shared
        #else
        return HealthKitManager.shared.isHealthDataAvailable ? HealthKitManager.shared : MockHealthKitService.shared
        #endif
    }()

    public var body: some Scene {
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
