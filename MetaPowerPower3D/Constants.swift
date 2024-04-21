//
//  Constants.swift
//  MetaPowerPower3D
//
//  Created by 石勇 on 2024/4/19.
//
import Foundation

struct Constants {
    static let apiBaseURL = "https://api.metapowermatrix.ai"
    static let gameMishiRoomList = apiBaseURL + "/api/town/game/rooms/game"
    static let genScene = apiBaseURL + "/api/town/generate/scene"
    static let genAnswer = apiBaseURL + "/api/town/game/answer/image"
    static let joinGame = apiBaseURL + "/api/town/join/game"
    static let askClue = apiBaseURL + "/api/town/game/clue"
    static let imageDesc = apiBaseURL + "/api/town/image/description"
    static let revealAnswer = apiBaseURL + "/api/town/game/reveal/answer"
    static let sendAnswer = apiBaseURL + "/api/town/game/send/answer"
    // Add other global constants as needed
}
