//
//  XMTestAppApp.swift
//  XMTestApp
//
//  Created by Nikita Glavatckii on 15.11.23.
//

import SwiftUI

@main
struct XMTestAppApp: App {
    var body: some Scene {
        WindowGroup {
            StartView(viewModel: StartViewModel(networkManager: NetworkManager.shared))
        }
    }
}
