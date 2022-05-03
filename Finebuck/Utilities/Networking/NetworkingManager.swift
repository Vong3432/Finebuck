//
//  NetworkingManager.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 03/05/2022.
//

import Foundation
import Combine

class NetworkingManager {
    
    enum NetworkingError: LocalizedError {
        case badUrlResponse(url: URL)
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .badUrlResponse(url: let url):
                return "[🔥] Bad response url: \(url)"
            case .unknown:
                return "[⚠️] Error occured"
            }
        }
    }
    
    static func download(url: URL) -> AnyPublisher<Data, Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .default)) // run in bg thread (?)
            .tryMap { try handleURLResposne(output: $0, url: url) }
            .receive(on: DispatchQueue.main) // pass it to UI thread
            .eraseToAnyPublisher() // makes return type more readable (the AnyPublisher<Data, Error>) instead of the real type from the original publisher.
    }
    
    static func handleURLResposne(output: URLSession.DataTaskPublisher.Output, url: URL) throws -> Data {
        guard let response = output.response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else {
            throw NetworkingError.badUrlResponse(url: url)
        }
        return output.data
    }
    
    static func handleCompletion(completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            break
        case .failure(let error):
            print(error.localizedDescription) // human readable error
            break
        }
    }
}
