//
//  JudgeTurnView.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import SwiftUI

struct JudgeTurnView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button {
                        viewModel.goTo(.gamePlay)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.textMuted)
                    }
                    Spacer()
                }
                .padding(.horizontal, AppTheme.paddingLarge)
                
                Spacer()
                
                // Title
                VStack(spacing: 8) {
                    Text("👑")
                        .font(.system(size: 48))
                    
                    Text("Who won this round?")
                        .font(AppTheme.headlineFont)
                        .foregroundColor(AppTheme.text)
                    
                    Text("Pick the best answer")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.textMuted)
                }
                
                Spacer()
                
                // Player Selection
                VStack(spacing: 12) {
                    ForEach(viewModel.players) { player in
                        Button {
                            viewModel.awardPoint(to: player)
                            viewModel.nextTurn()
                            viewModel.goTo(.gamePlay)
                        } label: {
                            HStack(spacing: 16) {
                                Text(player.emoji)
                                    .font(.system(size: 32))
                                
                                Text(player.name)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(AppTheme.text)
                                
                                Spacer()
                                
                                Text("\(player.score) pts")
                                    .font(AppTheme.bodyFont)
                                    .foregroundColor(AppTheme.textMuted)
                            }
                            .padding(16)
                            .background(AppTheme.card)
                            .cornerRadius(AppTheme.cornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .stroke(AppTheme.border, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, AppTheme.paddingLarge)
                
                Spacer()
                
                // Skip - No Winner
                Button {
                    viewModel.nextTurn()
                    viewModel.goTo(.gamePlay)
                } label: {
                    Text("Skip - No clear winner")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.textMuted)
                }
                
                // End Game
                Button {
                    viewModel.goTo(.results)
                } label: {
                    Text("End Game & See Results")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.pink)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    let vm = GameViewModel()
    vm.addPlayer(name: "Alex")
    vm.addPlayer(name: "Sam")
    vm.addPlayer(name: "Jordan")
    vm.startGame()
    return JudgeTurnView(viewModel: vm)
}