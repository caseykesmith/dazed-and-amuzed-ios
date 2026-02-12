//
//  ContentView.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        Group {
            switch viewModel.screen {
            case .home:
                HomeView(viewModel: viewModel)
            case .playMode:
                PlayModeView(viewModel: viewModel)
                HomeView(viewModel: viewModel)
            case .vibeSelect:
                HomeView(viewModel: viewModel)
            case .packSelect:
                HomeView(viewModel: viewModel)
            case .addPlayers:
                HomeView(viewModel: viewModel)
            case .gamePlay:
                HomeView(viewModel: viewModel)
            case .judgeTurn:
                HomeView(viewModel: viewModel)
            case .results:
                HomeView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
