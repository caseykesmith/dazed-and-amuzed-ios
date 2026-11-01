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
            case .setup:
                SetupView(viewModel: viewModel)
            case .gamePlay:
                GamePlayView(viewModel: viewModel)
            case .results:
                CoronationView(viewModel: viewModel)
            case .crownCard:
                CrownCardView(viewModel: viewModel)
            case .pickWinner:
                PickWinnerView(viewModel: viewModel)
            case .passPhone:
                PassPhoneView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
