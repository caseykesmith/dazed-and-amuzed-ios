//
//  ResultsView.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler + Casey + Ella Rae on 2/11/26.
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
    
    var isTie: Bool {
        guard sortedPlayers.count >= 2 else { return false }
        return sortedPlayers[0].score == sortedPlayers[1].score
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
                        // Crown
                        Text("👑")
                            .font(.system(size: 56))
                        
                        // Winner Name
                        Text(isTie ? "It's a tie!" : "\(winner.name) wins!")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        if !isTie {
                            Text("\(winner.score) points")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }
                }
                
                Spacer()
                
                // Scoreboard
                VStack(spacing: 16) {
                    Text("FINAL STANDINGS")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(2)
                        .foregroundColor(AppTheme.textDim)
                    
                    VStack(spacing: 10) {
                        ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                            HStack(spacing: 14) {
                                // Rank
                                Text(rankEmoji(for: index))
                                    .font(.system(size: 24))
                                    .frame(width: 36)
                                
                                // Name
                                Text(player.name)
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(AppTheme.text)
                                
                                Spacer()
                                
                                // Score
                                Text("\(player.score)")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(index == 0 ? Color(hex: "FFD700") : AppTheme.textMuted)
                            }
                            .padding(16)
                            .background(index == 0 ? Color(hex: "FFD700").opacity(0.1) : AppTheme.card)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(index == 0 ? Color(hex: "FFD700").opacity(0.4) : AppTheme.border, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 14) {
                    Button {
                        viewModel.startGame()
                    } label: {
                        Text("Play Again 🎉")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(AppTheme.primaryGradient)
                            .cornerRadius(14)
                    }
                    
                    Button {
                        viewModel.resetGame()
                    } label: {
                        Text("Back to Home")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
                .padding(.horizontal, 24)
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
