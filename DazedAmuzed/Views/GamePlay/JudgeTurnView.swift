//
//  JudgeTurnView.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import SwiftUI

struct JudgeTurnView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var cardColor: Color {
        guard let question = viewModel.currentQuestion else { return AppTheme.pink }
        switch question.category {
        case .debates: return Color(hex: "FF6B35")
        case .wouldYouRather: return Color(hex: "FF2D78")
        case .stories: return Color(hex: "7B68EE")
        case .exposed: return Color(hex: "9ACD32")
        case .reflection: return Color(hex: "20B2AA")
        case .drinkIf: return Color(hex: "FFD700")
        }
    }
    
    var categoryName: String {
        guard let question = viewModel.currentQuestion else { return "" }
        return question.category.displayName.uppercased()
    }
    
    var categoryIcon: String {
        guard let question = viewModel.currentQuestion else { return "" }
        return question.category.icon
    }
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button {
                        viewModel.goTo(.gamePlay)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.left")
                            Text("Back")
                        }
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(AppTheme.textMuted)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // Category Label
                HStack(spacing: 6) {
                    Text(categoryIcon)
                    Text(categoryName)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .tracking(2)
                }
                .foregroundColor(cardColor)
                
                // Question Card
                if let question = viewModel.currentQuestion {
                    VStack(spacing: 16) {
                        Text(question.text)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.text)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(28)
                    .frame(maxWidth: .infinity)
                    .background(cardColor.opacity(0.1))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(cardColor, lineWidth: 2)
                    )
                    .padding(.horizontal, 24)
                }
                
                // Instructions
                Text("Pick one. Explain why. Best logic wins.")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(AppTheme.textDim)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppTheme.card)
                    .cornerRadius(12)
                
                Spacer()
                
                // Go Button
                Button {
                    viewModel.goTo(.pickWinner)
                } label: {
                    Text("Go →")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(AppTheme.primaryGradient)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                
                // Skip
                Button {
                    viewModel.nextQuestion()
                } label: {
                    Text("Skip this one")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(AppTheme.textDim)
                }
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    let vm = GameViewModel()
    vm.addPlayer(name: "Alex")
    vm.addPlayer(name: "Sam")
    vm.startGame()
    return JudgeTurnView(viewModel: vm)
}
