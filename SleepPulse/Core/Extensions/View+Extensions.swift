//
//  View+Extensions.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import SwiftUI

public extension View {
    /// Aplica navigationBarTitleDisplayMode(.inline) únicamente en plataformas que lo soportan (iOS/watchOS)
    /// evitando fallos de compilación en pruebas multiplataforma (macOS).
    @ViewBuilder
    func inlineNavigationTitle() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}
