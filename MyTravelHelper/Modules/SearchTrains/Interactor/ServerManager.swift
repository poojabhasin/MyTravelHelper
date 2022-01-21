//
//  ServerManager.swift
//  MyTravelHelper
//
//  Created by Pooja on 19/01/22.
//  Copyright © 2022 Sample. All rights reserved.
//

import Foundation
import XMLParsing

protocol ServerManagerProtocol{
    func request<T: Decodable>(config : URLSessionConfiguration ,
                               router: ServerRequest,
                               completion: @escaping (Result<T,NetworkError>) -> ())
}

enum NetworkError: String,Error {
    case badURL
    case parsingError
    case badRequest = "400"
    case internalServerError = "500"
    case unknownError
    
    var description:String{
        switch self{
        case .badURL:
            return "Inavlid URL"
        case .parsingError:
            return "Unable to parse response"
        case .badRequest:
            return "Invalid Request"
        case .internalServerError:
            return "Internal Server Error"
        case .unknownError:
            return "Something went wrong!Please try again"
        }
    }
}

struct ServerManager:ServerManagerProtocol {
    // This function is responsible for all the API calls to remote server
    func request<T: Decodable>(config : URLSessionConfiguration = .default,
                               router: ServerRequest,
                               completion: @escaping (Result<T,NetworkError>) -> ()) {
        do {
            if let request = try router.request(){
                let task = URLSession(configuration: config).dataTask(with: request) { (data, urlResponse, error) in
                    
                    if error != nil {
                        completion(.failure(.badURL))
                        return
                    }
                    
                    guard let data = data else {
                        completion(.failure(.badRequest))
                        return
                    }
                    
                    do {
                        let result = try XMLDecoder().decode(T.self, from: data)
                        completion(.success(result))
                    } catch {
                        completion(.failure(.parsingError))
                    }
                }
                task.resume()
            }
        } catch {
            completion(.failure(.badRequest))
        }
    }
}
