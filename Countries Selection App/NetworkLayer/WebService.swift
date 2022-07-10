//
//  WebService.swift
//  Countries Selection App
//
//  Created by Ahmadreza on 12/30/21.
//

import Foundation

class WebService {
    
    enum RequestError: Error {
        case parsingIssue
        case wrongResponse
        case unknown
    }

    static let shared = WebService()
    
    func getAllCountries(comple: @escaping (Result<[Country], Error>)->()) {
        let url = URL(string: "https://restcountries.com/v3.1/all")!
        getRequest(url: url, responseType: [Country].self, comple: comple)
    }
}

// MARK: - Base API Call Function
extension WebService {
    
    /// Use this function to get all the simple get request calls
    private func getRequest<T:Decodable>(url: URL, responseType: T.Type, comple: @escaping (Result<T, Error>)->()) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            guard let data = data else { return }
            if error == nil {
                do {
                    let parsedResponse = try JSONDecoder().decode(responseType.self, from: data)
                    comple(.success(parsedResponse))
                } catch {
                    print("WebService getRequest error 1: " + error.localizedDescription)
                    comple(.failure(RequestError.parsingIssue))
                }
            } else {
                print("WebService getRequest error 2: " + error.debugDescription)
                comple(.failure(RequestError.wrongResponse))
            }
        }).resume()
    }
}
