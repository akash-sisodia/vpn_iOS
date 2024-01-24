//
//  SocketCallManager.swift
//  CallApp
//
//  Created by Akash Singh Sisodia on 22/04/20.
//  Copyright © 2020 Akash Singh Sisodia. All rights reserved.
//

import Foundation
import SocketIO


protocol SocketClientDelegate: class {
    func socketClient(_ client: SocketHelper, didChange state: SocketIOStatus)
    func socketClient(_ client: SocketHelper, didJoin room: String)
    func socketClientDidFail()
    func socketClientDidReceiveNewPeer()
    func socketClient(_ client: SocketHelper, didReceiveOffer offer: [AnyHashable: Any])
    func socketClient(_ client: SocketHelper, didReceiveAnswer answer: [AnyHashable: Any])
    func socketClient(_ client: SocketHelper, didReceiveICE candidate: [AnyHashable: Any])
}

class SocketCallManager {
    
    var callBackChat: ((NSDictionary?) -> Void)?
    var callBackTyping: (() -> (Void))?
    var callBackOnline: (() -> (Void))?
    var connectionStateHandler: ((SocketIOStatus)->Void)?
    var delegate: SocketClientDelegate?
    var opponentId: String?
    var roomId: String?

    static let shared: SocketCallManager = {
        let instance = SocketCallManager()
        return instance
    }()
    
    func startCall(roomId: String, _ connectionHandler: @escaping ()->()) {
        
        self.roomId = roomId
        
        SocketHelper.shared.callbackRegisterOnEvents = {
            
            self.registerReceivingEvents()
        }
        
        SocketHelper.shared.connect()

        SocketHelper.shared.connectionStateHandler = { state in
            
            switch state {
            case .connected:
                connectionHandler()
            default:
                break
            }
        }
    }
    
    func emit(key: String, data: HTTPParameters) {
        
        guard SocketHelper.shared.state == .connected else {
            print("socket is not connected, failed to Chat.")
            return
        }
        
        SocketHelper.shared.socket?.emit(key, data)
    }
    
    func registerReceivingEvents() {
        
        SocketHelper.shared.socket?.connect()
    }
}
