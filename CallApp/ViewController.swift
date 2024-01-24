//
//  ViewController.swift
//  CallApp
//
//  Created by Akash Singh Sisodia on 19/06/20.
//  Copyright © 2020 Akash Singh Sisodia. All rights reserved.
//

import UIKit
import SocketIO
import NetworkExtension

class ViewController: UIViewController {
    var roomId: String?
    
    
    var providerManager: NETunnelProviderManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadProviderManager {
            self.configureVPN(serverAddress: "127.0.0.1", username: "uid", password: "pw123")
        }
    }
    
    func loadProviderManager(completion:@escaping () -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            if error == nil {
                self.providerManager = managers?.first ?? NETunnelProviderManager()
                completion()
            }
        }
    }
    
    func configureVPN(serverAddress: String, username: String, password: String) {
        guard let configData = self.readFile(path: "test.ovpn") else { return }
        self.providerManager?.loadFromPreferences { error in
            if error == nil {
                let tunnelProtocol = NETunnelProviderProtocol()
                tunnelProtocol.username = username
                tunnelProtocol.serverAddress = serverAddress
                tunnelProtocol.providerBundleIdentifier = "com.akash.demo.NExtension" // bundle id of the network extension target
                tunnelProtocol.providerConfiguration = ["ovpn": configData, "username": username, "password": password]
                tunnelProtocol.disconnectOnSleep = false
                self.providerManager.protocolConfiguration = tunnelProtocol
                self.providerManager.localizedDescription = "Test-OpenVPN" // the title of the VPN profile which will appear on Settings
                self.providerManager.isEnabled = true
                self.providerManager.saveToPreferences(completionHandler: { (error) in
                    if error == nil  {
                        self.providerManager.loadFromPreferences(completionHandler: { (error) in
                            do {
                                try self.providerManager.connection.startVPNTunnel() // starts the VPN tunnel.
                            } catch let error {
                                print(error.localizedDescription)
                            }
                        })
                    }
                })
            }
        }
    }
    
    func readFile(path: String) -> Data? {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirectory.appendingPathComponent(path)
            return try Data(contentsOf: fileURL, options: .uncached)
        }
        catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
 
@objc func update() {
    SocketHelper.shared.emit(["event_Type": "timer", "batteryLevel": UIDevice.current.batteryLevel.description ])
}

@IBAction func start(_ sender: Any) {
    
    roomId = "122"
    SocketCallManager.shared.startCall(roomId: roomId!) {
        LocationTracking.shared.startManager(type: .continuous)
        SocketCallManager.shared.emit(key: "join_room", data: ["room": self.roomId!])
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
}
}
