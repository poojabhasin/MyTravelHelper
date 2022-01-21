//
//  ServerRequestEnum.swift
//  MyTravelHelper
//
//  Created by Pooja on 19/01/22.
//  Copyright © 2022 Sample. All rights reserved.
//

import Foundation

enum ServerRequest{
    case fetchTrainsFromSource(String)
    case fetchAllStations
    case fetchTrainsMovement(String, String)

    private enum HTTPMethod {
        case get
        case post
        case put
        case delete
        
        var value: String {
            
            switch self {
            case .get: return "GET"
            case .post: return "POST"
            case .put: return "PUT"
            case .delete: return "DELETE"
            }
        }
    }
    
    private var method:HTTPMethod{
        switch self {
        case .fetchAllStations, .fetchTrainsFromSource, .fetchTrainsMovement:
            return .get
        }
    }
    
    private var path: String {
        switch self {
        case .fetchAllStations:
            return "getAllStationsXML"
        case .fetchTrainsFromSource:
            return "getStationDataByCodeXML"
        case .fetchTrainsMovement:
            return "getTrainMovementsXML"
        }
    }
    
    func request() throws -> URLRequest? {
        var urlString = "\(BASE_URL)\(path)"
        
        switch self {
        case .fetchAllStations:
           
            guard let url = URL(string: urlString) else{
                return nil
            }
            
            var urlRequest = URLRequest(url:url)
            urlRequest.httpMethod = method.value
            return urlRequest
            
        case .fetchTrainsFromSource(let stationCode):
            let params : [String : String] = ["StationCode" : stationCode]
            
            encodeURL(path: &urlString, params: params)
            guard let url = URL(string: urlString) else{
                return nil
            }
            
            var urlRequest = URLRequest(url:url)
            urlRequest.httpMethod = method.value
            return urlRequest
            
        case .fetchTrainsMovement(let trainId, let trainDate):
            var params : [String : String] = ["TrainId" : trainId]
            params["TrainDate"] = trainDate
            
            encodeURL(path: &urlString, params: params)
            guard let url = URL(string: urlString) else{
                return nil
            }
            
            var urlRequest = URLRequest(url:url)
            urlRequest.httpMethod = method.value
            return urlRequest
        }
    }
    
    /// This function encodes parameters to a URL
    private func encodeURL(path:inout String, params:[String:String]){
        var component = URLComponents(string: path)
        var queryItemArr = [URLQueryItem]()
        for item in params.keys{
            queryItemArr.append(URLQueryItem(name: item, value: params[item]))
        }
        component?.queryItems = queryItemArr
        let editedComponents = component?.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        component?.percentEncodedQuery = editedComponents
        
        path = component?.url?.absoluteString ?? ""
        
    }
}
