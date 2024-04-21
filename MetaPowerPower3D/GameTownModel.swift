//
//  GameTownModel.swift
//  MetaPowerPower3D
//
//  Created by 石勇 on 2024/4/19.
//

import Foundation
import Combine

public class PortalRoom: NSObject, ObservableObject{
    @Published var roomInfo: PortalRoomInfo = PortalRoomInfo(owner: "", room_id: "", title: "", description: "", cover: "", town: "mishi")
    @Published var gameState: GameState = GameState(gameLevel: 0, scene: "")
}

public struct KolInfo: Identifiable {
    public var id: String
    public var name: String
    public var followers: [String]
}

public struct PortalRoomInfo: Decodable {
    public var owner: String
    public var room_id: String
    public var title: String
    public var description: String
    public var cover: String
    public var town: String
}
public struct GameAction: Codable {
    let id: String
    let owner: String
    let room_id: String
    let room_name: String
    let message: String
    let image_url: String
    let answer: String
    let level: Int32
}
public struct ImageDescription: Codable{
    public var id: String
    public var room_id: String
    public var scene: String
}
public struct ImageGen: Codable{
    public var id: String
    public var room_id: String
    public var description: String
}

struct SceneInfo: Decodable {
    public var sceneCount: Int32
    public var image_url: String
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        image_url = try container.decode(String.self)
        sceneCount = try container.decode(Int32.self)
    }
}
class GameTownModel: ObservableObject {
    @Published var rooms: [PortalRoomInfo] = []
    @Published var isLoading: Bool = false
    @Published var gameMessage: GameMessage = GameMessage()
    private var networkModel = NetworkModel()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchMishiRooms() {
        guard let url = URL(string: Constants.gameMishiRoomList) else { return }
        
        networkModel.fetchData(url: url)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error as NSError):
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] response in
                let jsonDecoder = JSONDecoder()
                DispatchQueue.main.async {
                    do {
                        self?.rooms = try jsonDecoder.decode([PortalRoomInfo].self, from: response.content.data(using: .utf8)!)
                    }catch{
                        print(error)
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    func joinGame(id: String, owner: String, room_id: String, room_name: String, level: Int32, game: PortalRoom) {
        isLoading = true

        let request = GameAction(id: id, owner: owner, room_id: room_id, room_name: room_name, message: "", image_url: "", answer:"", level:level)
        guard let url = URL(string: Constants.joinGame) else {
            isLoading = false
            return
        }
        
        networkModel.postData(url: url, request: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.isLoading = false
                case .failure(let error):
                    print("Error posting data: \(error)")
                    self.isLoading = false
                }
            }, receiveValue: { response in
                do{
                    let info = try JSONDecoder().decode([String].self, from: response.content.data(using: .utf8)!)
                    game.gameState.scene = info[1]
                }catch{
                    print(error)
                }
            })
            .store(in: &cancellables)
    }
    func askClue(id: String, owner: String, room_id: String, room_name: String, level: Int32, message: String, image_url: String) {
        isLoading = true

        let request = GameAction(id: id, owner: owner, room_id: room_id, room_name: room_name, message: message, image_url: image_url, answer:"", level:level)
        guard let url = URL(string: Constants.askClue) else {
            isLoading = false
            return
        }
        
        networkModel.postData(url: url, request: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("finished")
                    self.isLoading = false
                case .failure(let error):
                    print("failure")
                    print("Error posting data: \(error)")
                    self.isLoading = false
                }
            }, receiveValue: { response in
                print("received")
                do{
                    let clues: [String] = try JSONDecoder().decode([String].self, from: response.content.data(using: .utf8)!)
                    self.gameMessage.imageDescription = clues[0]
                    self.gameMessage.showMessageDialog = true
                }catch{
                    print(error)
                }
            })
            .store(in: &cancellables)
    }
    func imageDescription(id: String, room_id: String, image_url: String){
        isLoading = true

        let request = ImageDescription(id: id, room_id: room_id, scene: image_url)
        guard let url = URL(string: Constants.imageDesc) else {
            isLoading = false
            return
        }
        
        networkModel.postData(url: url, request: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.isLoading = false
                case .failure(let error):
                    print("Error posting data: \(error)")
                    self.isLoading = false
                }
            }, receiveValue: { response in
                self.gameMessage.imageDescription = response.content
                self.gameMessage.showMessageDialog = true
            })
            .store(in: &cancellables)
    }
    func sendAnswer(id: String, owner: String, room_id: String, room_name: String, level: Int32, answer: String){
        isLoading = true

        let request = GameAction(id: id, owner: owner, room_id: room_id, room_name: room_name, message: "", image_url: "", answer:answer, level:level)
        guard let url = URL(string: Constants.sendAnswer) else {
            isLoading = false
            return
        }
        
        networkModel.postData(url: url, request: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.isLoading = false
                case .failure(let error):
                    print("Error posting data: \(error)")
                    self.isLoading = false
                }
            }, receiveValue: { response in
                do {
                    let winners: [String] = try JSONDecoder().decode([String].self, from: response.content.data(using: .utf8)!)
                    self.gameMessage.activeAlert = .isWinner
                    self.gameMessage.showAlert = true
                }catch{
                    print(error)
                }
            })
            .store(in: &cancellables)
    }
    func genScene(id: String, room_id: String, description: String, game: PortalRoom){
        isLoading = true
        
        let request = ImageGen(id: id, room_id: room_id, description: description)
        guard let url = URL(string: Constants.genScene) else {
            isLoading = false
            return
        }
        
        networkModel.postData(url: url, request: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.isLoading = false
                case .failure(let error):
                    print("Error posting data: \(error)")
                    self.isLoading = false
                }
            }, receiveValue: { response in
                do {
                    let genInfo: [String] = try JSONDecoder().decode([String].self, from: response.content.data(using: .utf8)!)
                    game.gameState.scene = genInfo[0]
                    game.gameState.totalScenes += 1
                    game.gameState.gameLevel += 1
                }catch{
                    print(error)
                }
            })
            .store(in: &cancellables)
    }
    func genAnswer(id: String, room_id: String, level: Int32, image_url: String) {
        isLoading = true

        let request = GameAction(id: id, owner: "", room_id: room_id, room_name: "", message: "", image_url:image_url , answer:"", level:level)
        guard let url = URL(string: Constants.genAnswer) else {
            isLoading = false
            return
        }
        
        networkModel.postData(url: url, request: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.isLoading = false
                case .failure(let error):
                    print("Error posting data: \(error)")
                    self.isLoading = false
                }
            }, receiveValue: { response in
                do {
                    let standard_answers = try JSONDecoder().decode([String].self, from: response.content.data(using: .utf8)!)
                    self.gameMessage.imageDescription = standard_answers[0]
                    self.gameMessage.showMessageDialog = true
                }catch{
                    print(error)
                }
            })
            .store(in: &cancellables)
    }
    func revealAnswer(id: String, owner: String, room_id: String, level: Int32){
        isLoading = true
        
        let request = GameAction(id: id, owner: owner, room_id: room_id, room_name: "", message: "", image_url: "", answer:"", level:level)
        guard let url = URL(string: Constants.revealAnswer) else {
            isLoading = false
            return
        }
        
        networkModel.postData(url: url, request: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.isLoading = false
                case .failure(let error):
                    print("Error posting data: \(error)")
                    self.isLoading = false
                }
            }, receiveValue: { response in
                self.gameMessage.imageDescription = response.content
                self.gameMessage.showMessageDialog = true
            })
            .store(in: &cancellables)

    }
}
