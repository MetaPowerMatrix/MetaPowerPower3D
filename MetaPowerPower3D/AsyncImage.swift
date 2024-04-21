//
//  AsyncImage.swift
//  MetaPowerPower3D
//
//  Created by 石勇 on 2024/4/19.
//

import SwiftUI
import Combine

struct AsyncImage: View {
    @StateObject private var loader: ImageLoader
    
    init(url: URL?) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }
    
    var body: some View {
        switch loader.state {
        case .loading:
            ProgressView()
        case .success(let image):
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        case .failure(let error):
            Text("Error loading image: \(error.localizedDescription)")
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var state: ImageLoaderState = .loading
    
    private var cancellable: AnyCancellable?
    
    init(url: URL?) {
        guard let url = url else {
            state = .failure(URLError(.badURL))
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data in
                guard let image = UIImage(data: data) else {
                    throw NSError(domain: "imageDecode", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to decode image"])
                }
                return image
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.state = .failure(error)
                }
            }, receiveValue: { [weak self] image in
                self?.state = .success(image)
            })
    }
}

enum ImageLoaderState {
    case loading
    case success(UIImage)
    case failure(Error)
}
