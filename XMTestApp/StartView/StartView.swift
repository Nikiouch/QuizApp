//
//  ContentView.swift
//  XMTestApp
//
//  Created by Nikita Glavatckii on 15.11.23.
//

import SwiftUI

struct StartView<ViewModel: StartViewModelProtocol>: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.88, green: 0.88, blue: 0.89)
                    .ignoresSafeArea()
                VStack {
                    NavigationLink(destination: QuizView(viewModel: QuizViewModel(questions: viewModel.questions, networkManager: NetworkManager.shared))) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                        } else {
                            Text("Star survey")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchQuestions()
                }
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(viewModel: StartViewModel(networkManager: NetworkManager.shared))
    }
}
