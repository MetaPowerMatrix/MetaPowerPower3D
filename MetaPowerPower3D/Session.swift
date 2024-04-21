//
//  Session.swift
//  MetaPowerAssistant
//
//  Created by 石勇 on 2023/6/17.
//

import Foundation

public class Session : NSObject, ObservableObject {
    @Published var token: String
    @Published var id: String
    @Published var scene: String = "s0"
    @Published var sensor_level  = 0
    
    init(token: String, id: String) {
        self.token = token
        self.id = id
    }
}
