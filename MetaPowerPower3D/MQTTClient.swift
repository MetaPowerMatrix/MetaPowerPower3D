//
//  MQTTClient.swift
//  MetaPowerAssistant
//
//  Created by 石勇 on 2023/6/19.
//

//topic:
//"/metapower/translate/done",
//"/metapower/chat/done",
//"/metapower/3d/done",
//"/metapower/voice/done",
//"/metapower/music/done",
//"/metapower/pic/done",
//"/metapower/action/done",
//"/metapower/video/done",
//"/metapower/doc/done",
//"/metapower/sensor/done",


import Foundation
import CocoaMQTT
import MqttCocoaAsyncSocket

struct MQTTClient {
    private let clientID = "MetaPower-" + String(ProcessInfo().processIdentifier)
    private var mqttClient: CocoaMQTT5 = CocoaMQTT5(clientID: "MetaPowerAssistant", host: "api.metapowermatrix.ai", port: 3881)
    public var messageHandler: (String?) -> Void = { _ in }

    func didReceive(topic: String) {
        
        mqttClient.logLevel = .debug
        let connectProperties = MqttConnectProperties()
        connectProperties.topicAliasMaximum = 0
        connectProperties.sessionExpiryInterval = 0
        connectProperties.receiveMaximum = 100
        connectProperties.maximumPacketSize = 500
                
        mqttClient.connectProperties = connectProperties
        mqttClient.username = ""
        mqttClient.password = ""
        mqttClient.keepAlive = 300
        mqttClient.autoReconnect = true
//        mqttClient.allowUntrustCACertificate = true
        
        let lastWillMessage = CocoaMQTT5Message(topic: topic, string: "dieout")
        lastWillMessage.willResponseTopic = topic
        lastWillMessage.willExpiryInterval = .max
        lastWillMessage.willDelayInterval = 0
        lastWillMessage.qos = .qos1
        mqttClient.willMessage = lastWillMessage
//        mqttClient.delegate = self
        
        if mqttClient.connect(){
//            mqttClient.subscribe(topic, qos: .qos1)
            mqttClient.didReceiveMessage = { (mqtt: CocoaMQTT5, message: CocoaMQTT5Message, id: UInt16, publishData: MqttDecodePublish?) in
                print("Message received in topic \(message.topic) with payload \(message.string!)")
                self.messageHandler(message.string)
                if(publishData != nil){
                    print("publish.contentType \(String(describing: publishData!.contentType))")
                }
            }
//            mqttClient. = { (mqtt: CocoaMQTT5, err: Error?) in
//                print(err?.localizedDescription ?? "----diconnected----")
//            }
        }
    }
}


