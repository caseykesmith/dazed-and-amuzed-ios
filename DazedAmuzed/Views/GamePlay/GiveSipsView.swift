//
//  GiveSipsView.swift
//  DazedAmuzed
//
//  Created by PJ on 3/29/26.
//


import SwiftUI

struct GiveSipsView: View {
    @ObservedObject var viewModel: GameViewModel
    let winner: Player
    
    var sipsToGive: Int {
        viewModel.players.first { $0.id == winner.id }?.score ?? 1
    }
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Title
                VStack(spacing: 20) {
                    Text("🍺")
                        .font(.system(size: 72))
                    
                    Text("\(winner.name) wins!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.text)
                    
                    VStack(spacing: 8) {
                        Text("Give out")
                            .font(.system(size: 18, design: .rounded))
                            .foregroundColor(AppTheme.textMuted)
                        
                        Text("\(sipsToGive) \(sipsToGive == 1 ? "SIP" : "SIPS")")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundColor(Color(hex: "FF9F0A"))
                        
                        Text("to anyone you choose")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(AppTheme.textDim)
                    }
                    .padding(.top, 8)
                }
                
                Spacer()
                
                // Continue Button
                Button {
                    // Check if game should end
                    if let target = viewModel.settings.gameLength.targetScore, sipsToGive >= target {
                        viewModel.goTo(.results)
                    } else {
                        viewModel.nextTurn()
                        viewModel.goTo(.gamePlay)
                    }
                } label: {
                    Text("Continue")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppTheme.primaryGradient)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    let vm = GameViewModel()
    vm.addPlayer(name: "Alex")
    vm.addPlayer(name: "Sam")
    vm.players[0].score = 3
    return GiveSipsView(viewModel: vm, winner: vm.players[0])
}
