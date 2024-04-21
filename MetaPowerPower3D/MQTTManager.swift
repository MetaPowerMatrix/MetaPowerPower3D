//
//  MQTTManager.swift
//  SwiftUI_MQTT
//
//  Created by Anoop M on 2021-01-19.
//

import Foundation

import CocoaMQTT
import Combine

final class MQTTManager: ObservableObject {
    private var mqttClient: CocoaMQTT5?
    private var identifier: String!
    private var host: String!
    private var topics: [String]!
    private var username: String!
    private var password: String!
    public var messageHandler: (String?) -> Void = { _ in }

    @Published var currentAppState = MQTTAppState()
    private var anyCancellable: AnyCancellable?
    // Private Init
    init() {
        // Workaround to support nested Observables, without this code changes to state is not propagated
        anyCancellable = currentAppState.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    // MARK: Shared Instance

    private static let _shared = MQTTManager()

    // MARK: - Accessors

    class func shared() -> MQTTManager {
        return _shared
    }

    func initializeMQTT(host: String = "api.metapowermatrix.ai", port: UInt16 = 3881, identifier: String = "MetaPowerAssistant",
                        topic: [String], username: String? = nil, password: String? = nil, handler: @escaping (String?) -> Void) {
        // If any previous instance exists then clean it
        if mqttClient != nil {
            mqttClient = nil
        }
        self.identifier = identifier
        self.host = host
        self.username = username
        self.password = password
        let clientID = "\(identifier)-" + String(ProcessInfo().processIdentifier)
        self.topics = topic
        self.messageHandler = handler

        // TODO: Guard
        mqttClient = CocoaMQTT5(clientID: clientID, host: host, port: port)
        
//        mqttClient?.logLevel = .debug
        let connectProperties = MqttConnectProperties()
        connectProperties.topicAliasMaximum = 0
        connectProperties.sessionExpiryInterval = 0
        connectProperties.receiveMaximum = 100
        connectProperties.maximumPacketSize = 500
        mqttClient?.connectProperties = connectProperties
        
        // If a server has username and password, pass it here
        if let finalusername = self.username, let finalpassword = self.password {
            mqttClient?.username = finalusername
            mqttClient?.password = finalpassword
        }
//设置客户端断开连接前发送的最后一条消息
//        let lastWillMessage = CocoaMQTT5Message(topic: topic, string: "dieout")
//        lastWillMessage.willResponseTopic = topic
//        lastWillMessage.willExpiryInterval = .max
//        lastWillMessage.willDelayInterval = 0
//        lastWillMessage.qos = .qos1
//        mqttClient?.willMessage = lastWillMessage

        mqttClient?.keepAlive = 10
        mqttClient?.autoReconnect = true
        mqttClient?.delegate = self
    }

    func connect() {
        if let success = mqttClient?.connect(), success {
            currentAppState.setAppConnectionState(state: .connecting)
        } else {
            currentAppState.setAppConnectionState(state: .disconnected)
        }
    }

    func subscribe(topics: [MqttSubscription]) {
        mqttClient?.subscribe(topics)
    }

//    func publish(with message: String) {
//        mqttClient?.publish(topic, withString: message, qos: .qos1, properties: MqttPublishProperties())
//    }

    func disconnect() {
        mqttClient?.disconnect()
    }

    /// Unsubscribe from a topic
    func unSubscribe(topics: [MqttSubscription]) {
        mqttClient?.unsubscribe(topics)
    }

//    /// Unsubscribe from a topic
//    func unSubscribeFromCurrentTopic() {
//        mqttClient?.unsubscribe(topic)
//    }
    
    func currentHost() -> String? {
        return host
    }
    
    func isSubscribed() -> Bool {
       return currentAppState.appConnectionState.isSubscribed
    }
    
    func isConnected() -> Bool {
        return currentAppState.appConnectionState.isConnected
    }
    
    func connectionStateMessage() -> String {
        return currentAppState.appConnectionState.description
    }
}

extension MQTTManager: CocoaMQTT5Delegate {
    func mqtt5(_ mqtt5: CocoaMQTT5, didConnectAck ack: CocoaMQTTCONNACKReasonCode, connAckData: MqttDecodeConnAck?) {
//        TRACE("ack: \(ack)")
        
        if ack == .success {
            currentAppState.setAppConnectionState(state: .connected)

            var filters = [MqttSubscription]()
            for topic_string in self.topics {
                let filter = MqttSubscription(topic: topic_string, qos: .qos1)
                filters.append(filter)
            }            
            mqtt5.subscribe(filters)
        }
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishMessage message: CocoaMQTT5Message, id: UInt16) {
        TRACE("message: \(message.string.description), id: \(id)")
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishAck id: UInt16, pubAckData: MqttDecodePubAck?) {
        TRACE("didPublishAck: \(id)")
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishRec id: UInt16, pubRecData: MqttDecodePubRec?) {
        TRACE("didPublishRec: \(id)")
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveMessage message: CocoaMQTT5Message, id: UInt16, publishData: MqttDecodePublish?) {
//        TRACE("message: \(message.string.description), id: \(id)")
        self.messageHandler(message.string)
        currentAppState.setReceivedMessage(text: message.string.description)
    }
    
    func mqtt5(_ mqtt5:CocoaMQTT5, didSubscribeTopics success: NSDictionary, failed: [String], subAckData: MqttDecodeSubAck?) {
        TRACE("topic: \(success)")
        currentAppState.setAppConnectionState(state: .connectedSubscribed)
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didUnsubscribeTopics topics: [String], UnsubAckData: MqttDecodeUnsubAck?) {
        TRACE("topic: \(topics)")
        currentAppState.setAppConnectionState(state: .connectedUnSubscribed)
        currentAppState.clearData()
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveDisconnectReasonCode reasonCode: CocoaMQTTDISCONNECTReasonCode) {
        TRACE("\(reasonCode.rawValue.description)")
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveAuthReasonCode reasonCode: CocoaMQTTAUTHReasonCode) {
        TRACE("\(reasonCode.rawValue.description)")
    }
    
    func mqtt5DidPing(_ mqtt5: CocoaMQTT5) {
        TRACE("mqtt5DidPing")
    }
    
    func mqtt5DidReceivePong(_ mqtt5: CocoaMQTT5) {
        TRACE("mqtt5DidReceivePong")
    }
    
    func mqtt5DidDisconnect(_ mqtt5: CocoaMQTT5, withError err: Error?) {
        TRACE("mqtt5DidDisconnect: \(err.description)")
        currentAppState.setAppConnectionState(state: .disconnected)
    }
}

extension MQTTManager {
    func TRACE(_ message: String = "", fun: String = #function) {
        let names = fun.components(separatedBy: ":")
        var prettyName: String
        if names.count == 1 {
            prettyName = names[0]
        } else {
            prettyName = names[1]
        }

        if fun == "mqttDidDisconnect(_:withError:)" {
            prettyName = "didDisconect"
        }

        print("[TRACE] [\(prettyName)]: \(message)")
    }
}

extension Optional {
    // Unwrap optional value for printing log only
    var description: String {
        if let wraped = self {
            return "\(wraped)"
        }
        return ""
    }
}
