//
//  MetaPowerPower3DApp.swift
//  MetaPowerPower3D
//
//  Created by 石勇 on 2024/4/19.
//

import SwiftUI

@main
struct MetaPowerPower3DApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
