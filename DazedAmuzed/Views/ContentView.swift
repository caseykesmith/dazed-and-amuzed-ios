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
                VibeSelectView(viewModel: viewModel)
            case .packSelect:
                PackSelectView(viewModel: viewModel)
            case .addPlayers:
                AddPlayersView(viewModel: viewModel)
            case .gamePlay:
                GamePlayView(viewModel: viewModel)
            case .judgeTurn:
                JudgeTurnView(viewModel: viewModel)
            case .results:
                ResultsView(viewModel: viewModel)
            case .pickWinner:
                PickWinnerView(viewModel: viewModel)
            case .giveSips:
                if let winner = viewModel.lastWinner {
                    GiveSipsView(viewModel: viewModel, winner: winner)
                } else {
                    GamePlayView(viewModel: viewModel)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
