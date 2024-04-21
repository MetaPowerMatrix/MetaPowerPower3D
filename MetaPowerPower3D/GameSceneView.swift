//
//  GameSceneView.swift
//  MetaPowerPower3D
//
//  Created by 石勇 on 2024/4/19.
//

import SwiftUI

extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }
}

struct GameSceneView: View {
    @Environment(\.gameInfo) private var game
    @Environment(\.userSession) private var user
    @ObservedObject var webSocketService = WebSocketService()
    @State private var showPreLevelConfirm = false
    @State private var showNextLevelConfirm = false
    @State private var showSendAnswerConfirm = false
    @State private var showRevealAnswerConfirm = false
    @State private var showAskCLueConfirm = false
    @State private var showImageDescriptionConfirm = false
    @State private var gameTownModel = GameTownModel()
    private let button_font_size = 26.0
    
    func handleEnterLevel(step: Int32){
        gameTownModel.joinGame(id: user.id, owner: game.roomInfo.owner, room_id: game.roomInfo.room_id, room_name: game.roomInfo.title, level: game.gameState.gameLevel, game: game)
    }
    func handleGenScene(step: Int32){
        gameTownModel.genScene(id: user.id, room_id: game.roomInfo.room_id, description: "", game: game)
    }
    func handleImageDescription(){
        gameTownModel.imageDescription(id: user.id, room_id: game.roomInfo.room_id, image_url: game.gameState.scene )
    }
    func handleRevealAnswer(){
        gameTownModel.revealAnswer(id: user.id, owner: game.roomInfo.owner, room_id: game.roomInfo.room_id, level: game.gameState.gameLevel)
    }
    func handleSendAnswer(){
        gameTownModel.sendAnswer(id: user.id, owner: game.roomInfo.owner, room_id: game.roomInfo.room_id, room_name: game.roomInfo.title, level: game.gameState.gameLevel, answer: "这个密室可以打破窗户逃脱'")
    }
    func handleAskClue(){
        gameTownModel.askClue(id: user.id, owner: game.roomInfo.owner, room_id: game.roomInfo.room_id, room_name: game.roomInfo.title, level: game.gameState.gameLevel, message: "水底是否有不明生物？", image_url: game.gameState.scene)
    }

    var body: some View {
        HStack{
            VStack{
                Text(game.roomInfo.title).fontWeight(.bold).font(.system(size: 36)).padding(10)
                Spacer(minLength: 30)
                HStack{
                    Button("询问线索", action: {self.showAskCLueConfirm = true}).alert("", isPresented: $showAskCLueConfirm) {
                        Text("是否询问这一关的线索，需要消耗1原力值").font(.system(size: button_font_size))
                        Button("确认"){
                            handleAskClue()
                        }.font(.system(size: button_font_size))
                        Button("取消", role: .cancel, action: {}).font(.system(size: button_font_size))
                    }.font(.system(size: button_font_size))
                    Button("发送答案"){self.showSendAnswerConfirm=true}.alert("",isPresented: $showSendAnswerConfirm) {
                        Text("是否发送答案，需要消耗5原力值").font(.system(size: button_font_size))
                        Button("确认"){
                            handleSendAnswer()
                        }.font(.system(size: button_font_size))
                        Button("取消", role: .cancel, action: {}).font(.system(size: button_font_size))
                    }.font(.system(size: button_font_size))
                }
                HStack{
                    Button("上一关"){
                        self.showPreLevelConfirm=true
                    }.alert("", isPresented: $showPreLevelConfirm) {
                        Text("是否返回上一关，需要消耗1原力值").font(.system(size: button_font_size))
                        Button("确认"){
                            handleEnterLevel(step: -1)
                        }.font(.system(size: button_font_size))
                        Button("取消", role: .cancel, action: {}).font(.system(size: button_font_size))
                    }.font(.system(size: button_font_size))
                    Button("下一关"){
                        self.showNextLevelConfirm = true
                    }.alert("切换关卡", isPresented: $showNextLevelConfirm) {
                        Text("是否进入下一关，需要消耗1原力值").font(.system(size: button_font_size))
                        Button("确认"){
                            handleEnterLevel(step: 1)
                        }.font(.system(size: button_font_size))
                        Button("取消", role: .cancel, action: {}).font(.system(size: button_font_size))
                    }.font(.system(size: button_font_size))
                }
                HStack{
                    Button("场景说明", action: {self.showImageDescriptionConfirm=true}).alert("", isPresented: $showImageDescriptionConfirm) {
                        Text("是否询问AI对该场景的描述，需要消耗5原力值").font(.system(size: button_font_size))
                        Button("确认"){
                            handleImageDescription()
                        }.font(.system(size: button_font_size))
                        Button("取消", role: .cancel, action: {}).font(.system(size: button_font_size))
                    }.font(.system(size: button_font_size))
                    Button("获取答案", action: {self.showRevealAnswerConfirm=true}).alert("",isPresented: $showRevealAnswerConfirm) {
                        Text("是否揭秘本关答案，需要消耗50原力值").font(.system(size: button_font_size))
                        Button("确认"){
                            handleRevealAnswer()
                        }.font(.system(size: button_font_size))
                        Button("取消", role: .cancel, action: {}).font(.system(size: button_font_size))
                    }.font(.system(size: button_font_size))
                }
                Spacer(minLength: 30)
                Text(gameTownModel.gameMessage.imageDescription).frame(width: 320, height: 600).font(.system(size: 28))
                    .opacity(gameTownModel.gameMessage.showMessageDialog ? 1 : 0)
                    .animation(.default, value: gameTownModel.gameMessage.showMessageDialog)
            }
            .frame(width:320)
            .alert(isPresented: $gameTownModel.gameMessage.showAlert) {
                switch gameTownModel.gameMessage.activeAlert {
                case .isWinner:
                    return Alert(title: Text(""), message: Text(""))
                case .isLastLevel:
                    return Alert(title: Text(""), message: Text("这是最后一关"))
                case .isFirstLevel:
                    return Alert(title: Text(""),message: Text("这是第一关"))
                case .isCover:
                    return Alert(title: Text(""),message: Text("请进入关卡，这里是封面"))
                case .notFountScene:
                    return Alert(title: Text(""),message: Text("AI还没有设定场景"))
                case .toGenScene:
                    return Alert(title: Text(""),message: Text("生成一个关卡的游戏场景，需要消耗5原力值"))
                case .toGenAnswer:
                    return Alert(title: Text(""),message: Text("生成当前关卡的答案，需要消耗5原力值"))
                }
            }
            Spacer(minLength: 20)
            AsyncImage(url: URL(string: game.gameState.scene))
                .aspectRatio(contentMode: .fit)
                .border(Color.black, width: 1)
                .eraseToAnyView()
                
        }
        .onAppear {
            webSocketService.connect()
        }
        .onDisappear {
            webSocketService.disconnect()
        }
    }
}
