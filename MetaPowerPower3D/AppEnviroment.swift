//
//  AppEnviroment.swift
//  MetaPowerAssistant
//
//  Created by 石勇 on 2023/6/18.
//

import Foundation
import SwiftUI

private struct UserTokenKey: EnvironmentKey {
    static let defaultValue = ""
}

private struct UserSessionKey: EnvironmentKey {
    static let defaultValue = Session(token: "", id: "")
}

private struct GameInfoKey: EnvironmentKey {
    static let defaultValue = PortalRoom()
}

// 2. Extend the environment with our property
extension EnvironmentValues {
    var userToken: String {
        get { self[UserTokenKey.self] }
        set { self[UserTokenKey.self] = newValue }
    }
    var userSession: Session {
        get { self[UserSessionKey.self] }
        set { self[UserSessionKey.self] = newValue }
    }
    var gameInfo: PortalRoom {
        get { self[GameInfoKey.self] }
        set { self[GameInfoKey.self] = newValue }
    }
}

