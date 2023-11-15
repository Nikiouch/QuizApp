//
//  QuizView.swift
//  XMTestApp
//
//  Created by Nikita Glavatckii on 15.11.23.
//

import SwiftUI

struct QuizView<ViewModel: QuizViewModelProtocol>: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel: ViewModel
    
    @State private var answer: String = ""
    @State private var bannerTimer: Timer?
    
    private var showBanner: Bool {
        viewModel.status == .submitted
    }
    
    private var submitButtonDisabled: Bool {
        viewModel.currentAnswer != nil || answer.isEmpty || viewModel.status == .inProgress
    }
    
    private var answered: Bool {
        viewModel.currentAnswer != nil
    }
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Const.color
                .ignoresSafeArea()
            VStack(spacing: 0) {
                navigationBar
                questionSubmitted
                questionSection
                submitButton
                    .padding(.top, 20)
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private var navigationBar: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
            }
            .padding()
            Spacer()
            Text("Question \(viewModel.currentQuestion?.id ?? 0)/\(viewModel.questionsCount)")
            Spacer()
            Button {
                viewModel.previousQuestion()
                answer = viewModel.currentAnswer?.answer ?? ""
            } label: {
                Text("Previous")
            }
            .disabled(!viewModel.isTherePreviousQuestion || viewModel.status == .inProgress)
            .padding()
            Button {
                viewModel.nextQuestion()
                answer = viewModel.currentAnswer?.answer ?? ""
            } label: {
                Text("Next")
            }
            .disabled(!viewModel.isThereNextQuestion || viewModel.status == .inProgress)
            .padding()
        }
    }
    
    private var questionSubmitted: some View {
        Text("Questions submitted: \(viewModel.questionsSubmitted)")
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(.white)
    }
    
    private var questionSection: some View {
        VStack() {
            if showBanner {
                getBannerFor(state: answered ? .success : .failed)
            } else {
                Text(viewModel.currentQuestion?.question ?? "")
                    .padding(.top, 5)
            }
            TextField("Type here for an answer...", text: $answer)
                .multilineTextAlignment(.center)
                .disabled(answered)
        }
    }
    
    private var submitButton: some View {
        Button {
            Task {
                await viewModel.submitAnswer(with: answer)
            }
        } label: {
            Text(answered ? "Already submitted" : "Submit")
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding(.vertical, 15)
        }
        .disabled(submitButtonDisabled || showBanner)
        .background(.white)
        .cornerRadius(8)
        .padding()
    }
}

// MARK: Banner
extension QuizView {
    private func getBannerFor(state: BannerState) -> some View {
        HStack {
            Text(state.title)
                .padding(.leading, 20)
                .font(.system(size: 25))
                .fontWeight(.bold)
            Spacer()
            if state == .failed {
                Button("RETRY") {
                    Task {
                        await viewModel.submitAnswer(with: answer)
                    }
                }
                .font(.system(size: 15))
                .foregroundColor(.black)
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 2)
                )
                .padding(.trailing, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(state.color)
        .onAppear {
            startBannerTimer()
        }
        .onDisappear {
            stopBannerTimer()
        }
    }
    
    enum BannerState {
        case success
        case failed
        
        var color: Color {
            switch self {
            case .success:
                return .green
            case .failed:
                return .red
            }
        }
        
        var title: String {
            switch self {
            case .success:
                return "Success"
            case .failed:
                return "Failure!"
            }
        }
    }
    
    private func startBannerTimer() {
        bannerTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
            withAnimation {
                viewModel.changeStatusToReady()
            }
        }
    }
    
    private func stopBannerTimer() {
        guard bannerTimer != nil else { return }
        bannerTimer?.invalidate()
        bannerTimer = nil
    }
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView(viewModel: QuizViewModel(questions: [], networkManager: NetworkManager.shared))
    }
}

fileprivate enum Const {
    static var color: Color {
        Color(red: 0.88, green: 0.88, blue: 0.89)
    }
}
