//
//  ContentView.swift
//  Shared
//
//  Created by Marco on 12/30/21.
//

import SwiftUI
import NetworkExtension

struct ContentView: View {
    @State var isEnabled = false

    var body: some View {
        ZStack {
            Image("Background").frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 0) {
                Text("MarcoVPN")
                    .font(.system(size: 56, weight: .black, design: .default))
                    .kerning(-3)
                    .foregroundColor(.white)

                Button(
                    action: {
                        Task {
                            await toggleVPN()
                        }
                    },
                    label: {
                        if isEnabled {
                            Image("Pause")
                        } else {
                            Image("Play")
                        }
                    }
                )
            }
        }
    }

    init() {
        loadState()
    }

    /// Returns either an existing `NETunnelProviderManager` or a newly
    /// constructed one if the VPN configuration has not been previously
    /// saved.
    ///
    /// - Returns: The `NETunnelProviderManager`.
    func getManager() async -> NETunnelProviderManager {
        do {
            let managers = try await NETunnelProviderManager.loadAllFromPreferences()

            if managers.count > 0 {
                return managers[0]
            }

            return NETunnelProviderManager()
        } catch {
            return NETunnelProviderManager()
        }
    }

    /// Loads the initial state for this `ContentView`.
    func loadState() {
        Task {
            let manager = await getManager()
            isEnabled = manager.connection.status == .connected
        }
    }

    /// Toggles the VPN state. If disabled, the VPN will be enabled. If
    /// enabled, the VPN will be disabled.
    ///
    /// Starting the VPN involves the following steps:
    /// 1. Loading or constructing a `NETunnelProviderManager`.
    /// 2. Configuring the protocol.
    /// 3. Saving the configuration.
    /// 4. Loading the new configuration.
    /// 5. Starting the VPN.
    func toggleVPN() async {
        // Get or construct the `NETunnelProviderManager`.
        let manager = await getManager()

        switch manager.connection.status {
        case .connected:
            // If the VPN is connected, disconnect.
            manager.connection.stopVPNTunnel()
            isEnabled = false
        case .disconnected, .invalid:
            // Otherwise, construct a new protocol and define the packet
            // tunnel and endpoint to use.
            let configuration = NETunnelProviderProtocol()
            configuration.providerBundleIdentifier = "insert-organization-identifier.insert-app-identifier.PacketTunnel"
            configuration.serverAddress = SERVER_ENDPOINT_STRING
            configuration.providerConfiguration = [:]

            // Set the manager's configuration and mark it as enabled.
            manager.protocolConfiguration = configuration
            manager.localizedDescription = "MarcoVPN"
            manager.isEnabled = true

            do {
                // Attempt to save the new manager to preferences.
                try await manager.saveToPreferences()
            } catch {
                print("Error saving preferences:", error)
                return
            }

            do {
                // Now, load the manager from preferences.
                let loadedManagers = try await NETunnelProviderManager.loadAllFromPreferences()

                // Add an observer for debugging purposes.
                NotificationCenter.default.addObserver(
                    forName: .NEVPNStatusDidChange,
                    object: nil,
                    queue: nil
                ) { notification in
                    print(
                        "Tunnel status updated:",
                        loadedManagers[0].connection.status.rawValue
                    )
                }

                // Start the VPN.
                try loadedManagers[0].connection.startVPNTunnel()
                isEnabled = true

                print("Started tunnel successfully.")
            } catch {
                print("Error loading and starting tunnel:", error)
                return
            }
        default:
            break
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
