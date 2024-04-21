//
//  MetaPowerPower3DApp.swift
//  MetaPowerPower3D
//
//  Created by 石勇 on 2024/4/19.
//

import SwiftUI

@main
struct MetaPowerPower3DApp: App {
    @ObservedObject var session = Session(token: "我富的流油", id: "c6348a54-0958-49bd-af2c-a38817866fe3")
    @ObservedObject var game = PortalRoom()
    
    var body: some Scene {
        WindowGroup {
            ContentView().withSession(session).withGame(game)
        }.defaultSize(width: 1800, height: 1000)

        WindowGroup("mishi", id: "game_scene"){
            GameSceneView().withGame(game).withSession(session)
        }.defaultSize(width: 1800, height: 2048, depth: 0.6)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
