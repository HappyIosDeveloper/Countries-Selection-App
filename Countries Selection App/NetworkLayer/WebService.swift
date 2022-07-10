//
//  WebService.swift
//  Countries Selection App
//
//  Created by Ahmadreza on 12/30/21.
//

import Foundation

class WebService {
    
    enum RequestError: Error { case parsingIssue, wrongResponse, unknown }
    enum HTTPMethod: String { case get, post, put }

    static let shared = WebService()
    
    func getAllCountries(comple: @escaping (Result<[Country], RequestError>)->()) {
        let url = URL(string: "https://restcountries.com/v3.1/all")!
        baseRequest(url: url, method: .get, responseType: [Country].self, comple: comple)
    }
}

// MARK: - Base API Call Function
extension WebService {
    
    private func baseRequest<T:Decodable>(url: URL, method: HTTPMethod, responseType: T.Type, comple: @escaping (Result<T, RequestError>)->()) {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue.uppercased()
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let data = data else { return }
            if error == nil {
                do {
                    let parsedResponse = try JSONDecoder().decode(responseType.self, from: data)
                    comple(.success(parsedResponse))
                } catch {
                    print("WebService getRequest error 1: " + error.localizedDescription)
                    comple(.failure(.parsingIssue))
                }
            } else {
                print("WebService getRequest error 2: " + error.debugDescription)
                comple(.failure(.wrongResponse))
            }
        }).resume()
    }
}
