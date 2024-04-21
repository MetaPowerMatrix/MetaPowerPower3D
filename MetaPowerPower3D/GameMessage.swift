//
//  GameMessage.swift
//  MetaPowerPower3D
//
//  Created by 石勇 on 2024/4/21.
//

import Foundation

public enum ActiveAlert {
    case isWinner, isFirstLevel, isLastLevel, isCover, notFountScene, toGenScene, toGenAnswer
}

public struct GameMessage{
    public var activeAlert: ActiveAlert = .isWinner
    public var showAlert = false
    public var imageDescription: String = "欢迎进入密室世界"
    public var showMessageDialog: Bool = true
}
