//
//  QuizViewModel.swift
//  XMTestApp
//
//  Created by Nikita Glavatckii on 15.11.23.
//

import Foundation

//
//  StartViewModel.swift
//  XMTestApp
//
//  Created by Nikita Glavatckii on 15.11.23.
//

import Foundation

protocol QuizViewModelProtocol: ObservableObject {
    var questionsCount: Int { get }
    var currentQuestion: Question? { get }
    var currentAnswer: Answer? { get }
    var questionsSubmitted: Int { get }
    var isThereNextQuestion: Bool { get }
    var isTherePreviousQuestion: Bool { get }
    var status: SubmitStatus { get }
    
    func submitAnswer(with text: String) async
    func nextQuestion()
    func previousQuestion()
    func changeStatusToReady()
}

enum SubmitStatus {
    case ready
    case inProgress
    case submitted
}

class QuizViewModel: QuizViewModelProtocol {
    @Published var isThereNextQuestion = false
    @Published var isTherePreviousQuestion = false
    @Published var currentQuestion: Question?
    @Published var currentAnswer: Answer?
    @Published var questionsSubmitted = 0
    @Published var status: SubmitStatus = .ready
    
    private var answers = [Answer]()
    private let networkManager: NetworkManagerProtocol
    private let questions: [Question]
    
    var questionsCount: Int {
        questions.count
    }
    
    init(questions: [Question], networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
        self.questions = questions
        if let question = questions.first {
            currentQuestion = question
            if questions.count > 1 {
                isThereNextQuestion = true
            }
        }
    }
    
    func submitAnswer(with text: String) async {
        guard let id = currentQuestion?.id else { return }
        
        await MainActor.run {
            status = .inProgress
        }
        do {
            let answer =  Answer(id: id, answer: text)
            let isSuccess = try await networkManager.postQuestion(answer: answer)
            await MainActor.run {
                if isSuccess {
                    answers.append(answer)
                    currentAnswer = answer
                    questionsSubmitted = answers.count
                }
            }
        } catch {
            print("Error while post the answer: \(error)")
        }
        await MainActor.run {
            status = .submitted
        }
    }
    
    func nextQuestion() {
        guard let id = currentQuestion?.id, id + 1 <= questions.count else {
            return
        }
        questionChanged(newID: id + 1)
        isTherePreviousQuestion = true
    }
    
    func previousQuestion() {
        guard let id = currentQuestion?.id, id - 1 >= 1 else {
            return
        }
        questionChanged(newID: id - 1)
        isThereNextQuestion = true
    }
    
    func changeStatusToReady() {
        status = .ready
    }
    
    private func questionChanged(newID: Int) {
        currentQuestion = questions[newID - 1]
        currentAnswer = answers.first { $0.id == newID }
        isThereNextQuestion = newID + 1 <= questions.count
        isTherePreviousQuestion = newID - 1 >= 1
        status = .ready
    }
}
