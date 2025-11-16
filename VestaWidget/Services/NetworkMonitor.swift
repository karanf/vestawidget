//
//  NetworkMonitor.swift
//  VestaWidget
//
//  Service for monitoring network connectivity status
//  Helps provide better error messages and offline handling
//

import Foundation
import Network

/// Monitors network connectivity and provides reachability status
/// Uses Apple's Network framework for accurate connectivity detection
@MainActor
class NetworkMonitor: ObservableObject {

    // MARK: - Published Properties

    /// Whether the device is currently connected to a network
    @Published private(set) var isConnected = true

    /// Whether the connection is expensive (cellular data)
    @Published private(set) var isExpensive = false

    /// Current connection type
    @Published private(set) var connectionType: ConnectionType = .unknown

    // MARK: - Types

    /// Type of network connection
    enum ConnectionType {
        case wifi
        case cellular
        case wired
        case unknown
    }

    // MARK: - Private Properties

    /// Network path monitor from Network framework
    private let monitor: NWPathMonitor

    /// Queue for monitoring updates
    private let queue = DispatchQueue(label: "com.vestawidget.networkmonitor")

    // MARK: - Singleton

    /// Shared instance for app-wide access
    static let shared = NetworkMonitor()

    // MARK: - Initialization

    /// Private initializer to enforce singleton pattern
    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }

    // MARK: - Public Methods

    /// Starts monitoring network connectivity
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                self?.updateStatus(with: path)
            }
        }
        monitor.start(queue: queue)
    }

    /// Stops monitoring network connectivity
    func stopMonitoring() {
        monitor.cancel()
    }

    // MARK: - Private Methods

    /// Updates connection status based on network path
    /// - Parameter path: Current network path from monitor
    private func updateStatus(with path: NWPath) {
        // Update connection status
        isConnected = path.status == .satisfied

        // Update expense status
        isExpensive = path.isExpensive

        // Determine connection type
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .wired
        } else {
            connectionType = .unknown
        }
    }

    // MARK: - Computed Properties

    /// User-friendly description of connection status
    var statusDescription: String {
        if !isConnected {
            return "No internet connection"
        }

        switch connectionType {
        case .wifi:
            return "Connected via Wi-Fi"
        case .cellular:
            return "Connected via cellular"
        case .wired:
            return "Connected via ethernet"
        case .unknown:
            return "Connected"
        }
    }

    /// Whether the app should avoid heavy network operations
    /// True if offline or on expensive connection
    var shouldConserveData: Bool {
        return !isConnected || isExpensive
    }
}

// MARK: - Reachability Error

/// Error thrown when network is not available
struct NetworkUnavailableError: LocalizedError {
    var errorDescription: String? {
        return AppConstants.ErrorMessages.noInternet
    }

    var recoverySuggestion: String? {
        return "Please check your network settings and try again."
    }
}
