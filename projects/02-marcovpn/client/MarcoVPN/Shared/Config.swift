//
//  Config.swift
//  PacketTunnel
//
//  Created by Marco on 12/30/21.
//

import Foundation
import WireGuardKit

// The client's WireGuard private key.
let CLIENT_PRIVATE_KEY = PrivateKey(base64Key:  "[insert client private key]")!

// The client's virtual IP address for WireGuard.
let CLIENT_IP = IPAddressRange(from: "[insert client IP address]")!

// The DNS server to use for the client.
let CLIENT_DNS = DNSServer(from: "1.1.1.1")!

// The server's WireGuard public key.
let SERVER_PUBLIC_KEY = PublicKey(base64Key:  "[insert server public key]")!

// The server's IP address and port, such as "1.2.3.4:51820" or similar.
let SERVER_ENDPOINT_STRING = "[insert server endpoint]"

// The server's endpoint, generated from `SERVER_ENDPOINT_STRING`.
let SERVER_ENDPOINT = Endpoint(from: SERVER_ENDPOINT_STRING)
