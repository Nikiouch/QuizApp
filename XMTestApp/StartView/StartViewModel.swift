//
//  StartViewModel.swift
//  XMTestApp
//
//  Created by Nikita Glavatckii on 15.11.23.
//

import Foundation

protocol StartViewModelProtocol: ObservableObject {
    var questions: [Question] { get }
    var isLoading: Bool { get }
    func fetchQuestions() async
}

class StartViewModel: StartViewModelProtocol {
    @Published var questions: [Question] = []
    @Published var isLoading = false
    
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func fetchQuestions() async {
        await MainActor.run {
            isLoading = true
        }
        do {
            let fetchedQuestions = try await networkManager.getQuestions()
            await MainActor.run {
                questions = fetchedQuestions
            }
        } catch {
            print("Error fetching questions: \(error)")
        }
        await MainActor.run {
            isLoading = false
        }
    }
}
