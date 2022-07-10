//
//  Repository.swift
//  Countries Selection App
//
//  Created by Ahmadreza on 7/10/22.
//

import Foundation

class Repository {
    
    static let shared = Repository()
    
    private init() {}
    
    func getAllCountries(comple: @escaping (Result<[Country], WebService.RequestError>)->()) {
        getLocalDataIfPossible(for: "getAllCountries", withType: [Country].self) { [weak self] result in
            switch result {
            case .success(_):
                comple(result)
            case .failure(_):
                self?.getAndSaveAndContinue(for: "getAllCountries", withType: [Country].self, comple: comple)
            }
        }
    }
}

// MARK: - Base Functionality
extension Repository {
    
    private func getAndSaveAndContinue<T:Decodable>(for requestName: String, withType: T.Type, comple: @escaping (Result<T, WebService.RequestError>)->()) {
        WebService.shared.getAllCountries { response in
            switch response {
            case .success(let data):
                let convertedData = try? JSONEncoder().encode(data)
                UserDefaults.standard.set(convertedData, forKey: requestName)   // MARK: Saving request data
                UserDefaults.standard.set(Date(), forKey: requestName + "date") // MARK: Saving request time
                comple(.success(data as! T))
            case .failure(let error):
                comple(.failure(error))
            }
        }
    }
    
    private func getLocalDataIfPossible<T:Decodable>(for requestName: String, withType: T.Type, comple: @escaping (Result<T, WebService.RequestError>)->()) {
        let repositoryDataDeadlineInSeconds: Double = 300
        if let savedDate = UserDefaults.standard.object(forKey: requestName + "date") as? Date {
            if savedDate > Date().addingTimeInterval(-repositoryDataDeadlineInSeconds) {
                if let data = UserDefaults.standard.data(forKey: requestName) {
                    if let data = try? JSONDecoder().decode(withType, from: data) {
                        comple(.success(data))
                    } else {
                        comple(.failure(.repositoryIssue))
                    }
                } else {
                    comple(.failure(.repositoryIssue))
                }
            } else {
                comple(.failure(.repositoryIssue))
            }
        } else {
            comple(.failure(.repositoryIssue))
        }
    }
}
