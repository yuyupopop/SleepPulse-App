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

    private let healthKitService: any HealthKitServiceProtocol = {
        #if targetEnvironment(simulator)
        return MockHealthKitService.shared
        #else
        if HealthKitManager.shared.isHealthDataAvailable {
            return HealthKitManager.shared
        } else {
            return MockHealthKitService.shared
        }
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
