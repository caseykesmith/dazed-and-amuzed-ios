//
//  GamePlayView.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import SwiftUI

struct GamePlayView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button {
                        viewModel.resetGame()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    
                    Spacer()
                    
                    Text("Round \(viewModel.roundNumber)")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textMuted)
                    
                    Spacer()
                    
                    // Placeholder for balance
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, AppTheme.paddingLarge)
                
                // Current Player
                if let player = viewModel.currentPlayer {
                    HStack(spacing: 8) {
                        Text(player.emoji)
                            .font(.system(size: 24))
                        Text("\(player.name)'s turn")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.text)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(AppTheme.card)
                    .cornerRadius(20)
                }
                
                Spacer()
                
                // Question Card
                if let question = viewModel.currentQuestion {
                    QuestionCard(question: question)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button {
                        viewModel.goTo(.judgeTurn)
                    } label: {
                        Text("Everyone Answered")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(AppTheme.primaryGradient)
                            .cornerRadius(AppTheme.cornerRadius)
                    }
                    
                    Button {
                        viewModel.nextQuestion()
                    } label: {
                        Text("Skip Question")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
                .padding(.horizontal, AppTheme.paddingLarge)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Question Card Component
struct QuestionCard: View {
    let question: Question
    
    var cardColor: Color {
        switch question.category {
        case .debates: return AppTheme.orange
        case .stories: return AppTheme.cyan
        case .reflection: return AppTheme.purple
        case .wouldYouRather: return AppTheme.pink
        case .exposed: return AppTheme.yellow
        case .drinkIf: return AppTheme.green
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Category Label
            HStack(spacing: 6) {
                Text(question.category.icon)
                Text(question.category.displayName.uppercased())
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(2)
            }
            .foregroundColor(cardColor)
            
            // Question Text
            Text(question.text)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.text)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
            
            // Vibe indicator
            Text(question.vibe == .party ? "🎉 Party" : "🌙 Deep")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.textDim)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                .fill(AppTheme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                .stroke(cardColor.opacity(0.5), lineWidth: 2)
        )
        .padding(.horizontal, AppTheme.paddingLarge)
    }
}

#Preview {
    let vm = GameViewModel()
    vm.addPlayer(name: "Alex")
    vm.addPlayer(name: "Sam")
    vm.startGame()
    return GamePlayView(viewModel: vm)
}