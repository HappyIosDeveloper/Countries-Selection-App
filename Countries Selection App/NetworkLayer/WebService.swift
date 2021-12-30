//
//  WebService.swift
//  Countries Selection App
//
//  Created by Ahmadreza on 12/30/21.
//

import Foundation

class WebService {
    
    static let shared = WebService()
    
    func getAllCountries(comple: @escaping ([Country])->()) {
        let url = URL(string: "https://restcountries.com/v3.1/all")!
        getRequest(url: url, responseType: [Country].self, comple: { data in
            comple(data ?? [])
        })
    }
}

// MARK: - Base API Call Functions
extension WebService {
    
    /// Use this function to get all the simple get request calls
    private func getRequest<T:Decodable>(url: URL, responseType: T.Type, comple: @escaping (T?)->()) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            guard let data = data else { return }
            do {
                let parsedResponse = try JSONDecoder().decode(responseType.self , from: data)
                comple(parsedResponse)
            } catch {
                print("WebService getRequest error: " + error.localizedDescription)
                comple(nil)
            }
        }).resume()
    }
}
