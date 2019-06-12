//
//  Server.swift
//  SoxProxy
//
//  Created by Luo Sheng on 15/10/3.
//  Copyright © 2015年 Pop Tap. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
import NetworkExtension

open class Server: NSObject, GCDAsyncSocketDelegate, ConnectionDelegate, Proxyable {
    
    fileprivate let socket: GCDAsyncSocket
    fileprivate var connections = Set<Connection>()
    public var proxyServer: NEProxyServer?
    
    open var host: String! {
        get {
            return socket.localHost
        }
    }
    
    open var port: UInt16 {
        get {
            return socket.localPort
        }
    }
    
    public init(port: UInt16) throws {
        socket = GCDAsyncSocket(delegate: nil, delegateQueue: DispatchQueue.global(qos: .utility))
        super.init()
        socket.delegate = self
        try socket.accept(onPort: port)
    }
    
    deinit {
        disconnectAll()
    }
    
    func disconnectAll() {
        connections.forEach { $0.disconnect() }
    }
    
    // MARK: - GCDAsyncSocketDelegate
    
    @objc open func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        let connection = Connection(socket: newSocket)
        connection.delegate = self
        connection.server = self
        connections.insert(connection)
    }
    
    // MARK: - SOCKSConnectionDelegate
    
    func connectionDidClose(_ connection: Connection) {
        connections.remove(connection)
    }
}


