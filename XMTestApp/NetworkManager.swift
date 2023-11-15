//
//  NetworkManager.swift
//  XMTestApp
//
//  Created by Nikita Glavatckii on 15.11.23.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalid
}

protocol NetworkManagerProtocol {
    func getQuestions() async throws -> [Question]
    func postQuestion(answer: Answer) async throws -> Bool
}

class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager()
    
    private init() { }
    private let urlString = "https://xm-assignment.web.app/"
    
    func getQuestions() async throws -> [Question] {
        guard let url = URL(string: urlString.appending("questions")) else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode([Question].self, from: data)
        } catch {
            throw NetworkError.invalidResponse
        }
        
    }
    
    func postQuestion(answer: Answer) async throws -> Bool {
        guard let url = URL(string: urlString.appending("question/submit")) else {
            throw NetworkError.invalidURL
        }
        
        let encoder = JSONEncoder()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            let object = try encoder.encode(answer)
            request.httpBody = object
        } catch {
            throw NetworkError.invalidResponse
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        if let response = response as? HTTPURLResponse, response.statusCode == 200 {
            return true
        }
        
        return false
    }
}
