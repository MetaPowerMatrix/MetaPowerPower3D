//
//  WebSocketManager.swift
//  MetaPowerPower3D
//
//  Created by 石勇 on 2024/4/21.
//

import Foundation

class WebSocketManager: ObservableObject {
    let url: URL = URL(from: "wss://ws.metapowermatrix.ai/mqtt")
    @Published var isConnected = false
    var webSocketTask: URLSessionWebSocketTask?
    var cancellables = Set<AnyCancellable>()
    
//    init(url: URL) {
//        self.url = url
//    }
    
    func connect() {
        let urlRequest = URLRequest(url: url)
        let session = URLSession(configuration: .default)
        
        webSocketTask = session.webSocketTask(with: urlRequest)
        webSocketTask?.resume()
        
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                print("Received message: \(message)")
            case .failure(let error):
                print("WebSocket error: \(error.localizedDescription)")
                self?.isConnected = false
            }
        }
        
        webSocketTask?.statePublisher
            .sink { [weak self] state in
                switch state {
                case .connecting:
                    print("WebSocket connecting")
                case .connected:
                    print("WebSocket connected")
                    self?.isConnected = true
                case .disconnected:
                    print("WebSocket disconnected")
                    self?.isConnected = false
                @unknown default:
                    print("WebSocket unknown state")
                }
            }
            .store(in: &cancellables)
    }
    
    func send(_ data: Data) {
        webSocketTask?.send(.data(data)) { error in
            if let error = error {
                print("Error sending data: \(error.localizedDescription)")
            }
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}
