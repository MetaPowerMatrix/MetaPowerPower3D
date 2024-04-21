//
//  NetworkModel.swift
//  MetaPowerPower3D
//
//  Created by 石勇 on 2024/4/19.
//

import Foundation
import Combine

enum NetworkError: Error {
    case badStatusCode(Int)
    case other(Error)
}
struct ServerResponse: Codable {
    public var code: String
    public var content: String
}
class NetworkModel {
    func fetchData(url: URL) -> AnyPublisher<ServerResponse, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: ServerResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    func postData<T: Codable>(url: URL, request: T) -> AnyPublisher<ServerResponse, Error> {
        let jsonEncoder = JSONEncoder()
        
        do{
            let jsonData = try jsonEncoder.encode(request)
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonData
            
            return URLSession.shared.dataTaskPublisher(for: urlRequest)
                .tryMap { data, response in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw NetworkError.other(URLError(.badServerResponse))
                    }
                    guard httpResponse.statusCode == 200 else {
                        throw NetworkError.badStatusCode(httpResponse.statusCode)
                    }
                    return data
                }
                .decode(type: ServerResponse.self, decoder: JSONDecoder())
                .eraseToAnyPublisher()
        } catch {
            print(error)
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    func postRawData<T: Codable>(url: URL, request: T){
        let jsonEncoder = JSONEncoder()
        
        do {
            let jsonData = try jsonEncoder.encode(request)
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: urlRequest){data, response, error in
                print("Received response: \(String(describing: response))")
                print("Received error: \(String(describing: data))")
                print("Received data: \(String(describing: error))")
            }
            print("Starting task")
            task.resume()
            print("Task started")
        } catch {
            print(error)
        }
    }
    func downloadFile(from url: URL, to filename: String?, completion: @escaping (URL?, Error?) -> Void) {
        if filename == nil {
            completion(nil, nil)
        }
        let task = URLSession.shared.downloadTask(with: url) { (tempURL, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("code \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    if let tempURL = tempURL {
                        let fileManager = FileManager.default
                        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let localURL = documentsURL.appendingPathComponent(filename!)
                        
                        do {
                            if fileManager.fileExists(atPath: localURL.path) {
                                try fileManager.removeItem(at: localURL)
                            }
                            try fileManager.moveItem(at: tempURL, to: localURL)
                            completion(localURL, nil)
                        } catch {
                            completion(nil, error)
                        }
                    } else {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
}
