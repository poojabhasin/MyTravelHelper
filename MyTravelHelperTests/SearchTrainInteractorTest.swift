//
//  SearchTrainInteractorTest.swift
//  MyTravelHelperTests
//
//  Created by Pooja on 21/01/22.
//  Copyright © 2022 Sample. All rights reserved.
//

import Foundation
@testable import MyTravelHelper
import XCTest


typealias StationListFetchBlock = ([Station]) -> Void
typealias StationTrainFetchBlock = ([StationTrain]?) -> Void


class ServerManagerMock:ServerManagerProtocol{
    
    func request<T>(config: URLSessionConfiguration, router: ServerRequest, completion: @escaping (Result<T, NetworkError>) -> ()) where T : Decodable {
        XCTAssertNotNil(router)
        XCTAssertNotNil(config)
        
        switch router {
        case .fetchAllStations:
            let station = Station(desc: "Belfast Central", latitude: 54.6123, longitude: -5.91744, code: "BFSTC", stationId: 205)
            let testStationList = Stations(stationsList: [station])
            completion(.success(testStationList as! T))
        
        case .fetchTrainsFromSource(let code):
            let stationTrain = StationTrain(trainCode: "BFSTC", fullName: "Belfast Central", stationCode: code, trainDate: "20012022", dueIn: 5, lateBy: 5, expArrival: "", expDeparture: "")
            let mockStationData = StationData(trainsList: [stationTrain])
            completion(.success(mockStationData as! T))
            
        case .fetchTrainsMovement(let trainCode, _):
            let trainMovement = TrainMovement(trainCode: trainCode, locationCode: "205", locationFullName: "Belfast Central", expDeparture: "Lisburn")
            let trainMovementdata = TrainMovementsData(trainMovements: [trainMovement])
            completion(.success(trainMovementdata as! T))
        }
    }
}

class InteractorMock:InteractorToPresenterProtocol{
    
    var stationListFetchBlock : StationListFetchBlock?
    var stationTrainFetchBlock : StationTrainFetchBlock?
    
    func stationListFetched(list: [Station]) {
        self.stationListFetchBlock?(list)
    }
    
    func fetchedTrainsList(trainsList: [StationTrain]?) {
        self.stationTrainFetchBlock?(trainsList)
    }
    
    func showNoTrainAvailbilityFromSource() {
        // no use
    }
    
    func showNoInterNetAvailabilityMessage() {
        //no use
    }
}


class SearchTrainInteractorTest:XCTestCase{
    

    func testFetchAllStation_success(){
        let fetchStationExpectation = self.expectation(description: "Fetch station expectation")
       
        let trainInteractor = SearchTrainInteractor()
        
        let serverManagerMock = ServerManagerMock()
        let interactorMock = InteractorMock()
        
        trainInteractor.serverManager = serverManagerMock
        trainInteractor.presenter = interactorMock
        
        interactorMock.stationListFetchBlock = {(station) in
            XCTAssertNotNil(station)
            XCTAssertEqual(station.first?.stationDesc, "Belfast Central")
            fetchStationExpectation.fulfill()
        }
        
        interactorMock.stationTrainFetchBlock = {(train) in
            XCTFail()
        }
        
        trainInteractor.fetchallStations()
        
        self.waitForExpectations(timeout: 10.0)
    }
    
    func testFetchTrainList_success(){
        let fetchStationExpectation = self.expectation(description: "Fetch station expectation")
       
        let trainInteractor = SearchTrainInteractor()
        
        let serverManagerMock = ServerManagerMock()
        let interactorMock = InteractorMock()
        
        trainInteractor.serverManager = serverManagerMock
        trainInteractor.presenter = interactorMock
        
        interactorMock.stationListFetchBlock = {(station) in
            XCTFail()

        }
        
        interactorMock.stationTrainFetchBlock = {(train) in
            XCTAssertNotNil(train)
            XCTAssertEqual(train?.first?.stationFullName, "Belfast Central")
            fetchStationExpectation.fulfill()

        }
        
        trainInteractor.fetchTrainsFromSource(sourceCode: "205", destinationCode: "205")
        
        self.waitForExpectations(timeout: 10.0)
    }
    
}

