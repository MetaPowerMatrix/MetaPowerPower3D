//
//  GameState.swift
//  MetaPowerPower3D
//
//  Created by 石勇 on 2024/4/21.
//

import Foundation

public class GameState : ObservableObject{
    public var totalScenes: Int32 = 2
    public var gameLevel: Int32
    public var scene: String
    
    init(gameLevel: Int32, scene: String) {
        self.gameLevel = gameLevel
        self.scene = scene
    }
}
