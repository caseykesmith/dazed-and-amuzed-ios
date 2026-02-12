//
//  ResultsView.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import SwiftUI

struct ResultsView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var sortedPlayers: [Player] {
        viewModel.players.sorted { $0.score > $1.score }
    }
    
    var winner: Player? {
        sortedPlayers.first
    }
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Winner Section
                if let winner = winner {
                    VStack(spacing: 16) {
                        Text("👑")
                            .font(.system(size: 64))
                        
                        Text(winner.emoji)
                            .font(.system(size: 72))
                        
                        Text("\(winner.name) wins!")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.primaryGradient)
                        
                        Text("\(winner.score) points")
                            .font(AppTheme.headlineFont)
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
                
                Spacer()
                
                // Scoreboard
                VStack(spacing: 12) {
                    Text("Final Standings")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textDim)
                        .textCase(.uppercase)
                        .tracking(2)
                    
                    ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                        HStack(spacing: 16) {
                            // Rank
                            Text(rankEmoji(for: index))
                                .font(.system(size: 24))
                                .frame(width: 32)
                            
                            Text(player.emoji)
                                .font(.system(size: 24))
                            
                            Text(player.name)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(AppTheme.text)
                            
                            Spacer()
                            
                            Text("\(player.score)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(index == 0 ? AppTheme.yellow : AppTheme.textMuted)
                        }
                        .padding(14)
                        .background(index == 0 ? AppTheme.cardElevated : AppTheme.card)
                        .cornerRadius(AppTheme.cornerRadius)
                    }
                }
                .padding(.horizontal, AppTheme.paddingLarge)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button {
                        viewModel.startGame()
                    } label: {
                        Text("Play Again")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(AppTheme.primaryGradient)
                            .cornerRadius(AppTheme.cornerRadius)
                    }
                    
                    Button {
                        viewModel.resetGame()
                    } label: {
                        Text("Back to Home")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
                .padding(.horizontal, AppTheme.paddingLarge)
                .padding(.bottom, 40)
            }
        }
    }
    
    func rankEmoji(for index: Int) -> String {
        switch index {
        case 0: return "🥇"
        case 1: return "🥈"
        case 2: return "🥉"
        default: return "\(index + 1)."
        }
    }
}

#Preview {
    let vm = GameViewModel()
    vm.addPlayer(name: "Alex")
    vm.addPlayer(name: "Sam")
    vm.addPlayer(name: "Jordan")
    vm.players[0].score = 5
    vm.players[1].score = 3
    vm.players[2].score = 7
    return ResultsView(viewModel: vm)
}