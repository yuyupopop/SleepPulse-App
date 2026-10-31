//
//  DashboardView.swift
//  SleepPulse
//
//  Created by Antigravity on 31/10/2026.
//

import SwiftUI

/// Pantalla principal de la aplicación.
/// Centraliza la visualización de datos de Apple Watch / Apple Salud,
/// el selector de periodos (Día, Semana, Mes, Año) y las métricas biométricas.
public struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    @StateObject private var depthViewModel = SleepDepthViewModel()

    public init(viewModel: DashboardViewModel = DashboardViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if viewModel.isLoading && viewModel.currentSummary == nil {
                    ProgressView("Analizando datos de Apple Salud...")
                        .tint(.performanceAccent)
                        .foregroundColor(.white)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Selector de Temporalidad (Día, Semana, Mes, Año)
                            timeframePicker

                            // Mensaje de advertencia si no hay autorización de HealthKit
                            if !viewModel.isAuthorized && viewModel.errorMessage == nil {
                                authorizationBanner
                            }

                            // Banner de error si ocurre alguno
                            if let error = viewModel.errorMessage {
                                errorBanner(message: error)
                            }

                            // Contenido Principal según el Periodo
                            if let summary = viewModel.currentSummary {
                                PeriodSummaryView(
                                    summary: summary,
                                    latestMetrics: viewModel.latestMetrics,
                                    depthViewModel: depthViewModel
                                )
                            } else {
                                emptyStateView
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.reloadAllData()
                    }
                }
            }
            .navigationTitle("SleepPulse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await viewModel.reloadAllData() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.performanceAccent)
                    }
                }
            }
            .task {
                await viewModel.initialize()
                if let last = viewModel.latestSession {
                    depthViewModel.updateSession(last)
                }
            }
            .onChange(of: viewModel.latestSession) { newSession in
                if let session = newSession {
                    depthViewModel.updateSession(session)
                }
            }
        }
    }

    // MARK: - Selector de Periodo
    private var timeframePicker: some View {
        Picker("Periodo", selection: $viewModel.selectedTimeframe) {
            ForEach(Timeframe.allCases) { timeframe in
                Text(timeframe.title).tag(timeframe)
            }
        }
        .pickerStyle(.segmented)
        .padding(.vertical, 4)
    }

    // MARK: - Banner de Autorización
    private var authorizationBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .foregroundColor(.pink)
                Text("Permiso de Apple Salud Requerido")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }

            Text("SleepPulse requiere acceso de lectura a los datos de análisis de sueño registrados por tu Apple Watch.")
                .font(.caption)
                .foregroundColor(.secondary)

            Button {
                Task { await viewModel.initialize() }
            } label: {
                Text("Conectar con Apple Salud")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.performanceAccent)
                    .cornerRadius(10)
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.pink.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Banner de Error
    private func errorBanner(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.caption)
                .foregroundColor(.white)
            Spacer()
        }
        .padding(12)
        .background(Color.orange.opacity(0.15))
        .cornerRadius(12)
    }

    // MARK: - Estado Vacío
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bed.double.circle")
                .font(.system(size: 56))
                .foregroundColor(.secondary)

            Text("No se encontraron registros de sueño")
                .font(.headline)
                .foregroundColor(.white)

            Text("Asegúrate de llevar tu Apple Watch al dormir para registrar automáticamente tus fases de sueño.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 60)
    }
}

#Preview {
    DashboardView(
        viewModel: DashboardViewModel(
            healthKitService: MockHealthKitService.shared
        )
    )
}
