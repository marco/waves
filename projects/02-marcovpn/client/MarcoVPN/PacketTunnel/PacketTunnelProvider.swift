//
//  PacketTunnelProvider.swift
//  PacketTunnel
//
//  Created by Marco on 12/30/21.
//

import NetworkExtension
import WireGuardKit

class PacketTunnelProvider: NEPacketTunnelProvider {
    // The WireGuard instance.
    private var wireguard: WireGuardAdapter? = nil

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // Construct a new WireGuard instance with this `PacketTunnelProvider`.
        wireguard = WireGuardAdapter(with: self, logHandler: { level, log in print(log) })

        // Construct the configuration for the server.
        var peerConfig = PeerConfiguration(publicKey: SERVER_PUBLIC_KEY)
        peerConfig.allowedIPs = [IPAddressRange(from: "0.0.0.0/0")!]
        peerConfig.endpoint = SERVER_ENDPOINT

        // Construct the configuration for the client.
        var interfaceConfig = InterfaceConfiguration(privateKey: CLIENT_PRIVATE_KEY)
        interfaceConfig.dns = [CLIENT_DNS]
        interfaceConfig.addresses = [CLIENT_IP]

        // Construct a new `TunnelConfiguration` using the configuration
        // instances.
        let tunnelConfig = TunnelConfiguration(name: "Wireguard", interface: interfaceConfig, peers: [peerConfig])

        // Finally, start WireGuard and call `completionHandler` when ready.
        wireguard?.start(tunnelConfiguration: tunnelConfig, completionHandler: { error in
            NSLog(error?.localizedDescription ?? "")
            completionHandler(error)
        })
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Stop WireGuard and call `completionHandler` when ready.
        wireguard?.stop(completionHandler: { error in
            NSLog(error?.localizedDescription ?? "")
            completionHandler()
        })
    }

    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }

    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }

    override func wake() {
        // Add code here to wake up.
    }
}
