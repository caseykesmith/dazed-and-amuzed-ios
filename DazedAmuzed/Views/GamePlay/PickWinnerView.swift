//
//  PickWinnerView.swift
//  DazedAmuzed
//
//  Created by PJ on 3/29/26.
//


import SwiftUI

struct PickWinnerView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showConfetti = false
    @State private var confettiParticles: [ConfettiParticle] = []
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button {
                        viewModel.goTo(.judgeTurn)
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
                
                // Title
                VStack(spacing: 12) {
                    Text("👑")
                        .font(.system(size: 48))
                    
                    Text("Who won this round?")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.text)
                    
                    Text("Pick the best answer")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(AppTheme.textDim)
                }
                
                Spacer()
                
                // Player Selection
                VStack(spacing: 12) {
                    ForEach(viewModel.players) { player in
                        Button {
                            selectWinner(player)
                        } label: {
                            HStack(spacing: 16) {
                                Text(player.emoji)
                                    .font(.system(size: 32))
                                
                                Text(player.name)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(AppTheme.text)
                                
                                Spacer()
                                
                                Text("\(player.score) pts")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(AppTheme.textMuted)
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textDim)
                            }
                            .padding(18)
                            .background(AppTheme.card)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(AppTheme.border, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Skip
                Button {
                    viewModel.nextTurn()
                    viewModel.goTo(.gamePlay)
                } label: {
                    Text("Skip — No clear winner")
                        .font(.system(size: 15, design: .rounded))
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
            
            // Confetti overlay
            if showConfetti {
                GeometryReader { geo in
                    ZStack {
                        ForEach(confettiParticles) { particle in
                            Text(particle.emoji)
                                .font(.system(size: particle.size))
                                .position(particle.position)
                                .opacity(particle.opacity)
                        }
                    }
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }
        }
    }
    
    private func selectWinner(_ player: Player) {
        // Award the point
        viewModel.awardPoint(to: player)
        viewModel.lastWinner = player
        
        // Get the updated score
        let newScore = viewModel.players.first { $0.id == player.id }?.score ?? 0
        
        // Show confetti
        triggerConfetti()
        
        // Check if game should end
        if let target = viewModel.settings.gameLength.targetScore, newScore >= target {
            // Game over - go to results after confetti
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                viewModel.goTo(.results)
            }
        } else {
            // Continue game after confetti
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if viewModel.settings.drinkingMode {
                    viewModel.goTo(.giveSips)
                } else {
                    viewModel.nextTurn()
                    viewModel.goTo(.gamePlay)
                }
            }
        }
    }
    
    private func triggerConfetti() {
        showConfetti = true
        confettiParticles = []
        
        let emojis = ["🎉", "🎊", "✨", "⭐", "🌟", "💫", "🥳", "👑", "🔥", "💜"]
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Create particles
        for _ in 0..<50 {
            let particle = ConfettiParticle(
                emoji: emojis.randomElement()!,
                size: CGFloat.random(in: 20...40),
                position: CGPoint(
                    x: CGFloat.random(in: 0...screenWidth),
                    y: -50
                ),
                opacity: 1.0,
                finalX: CGFloat.random(in: -100...100),
                finalY: screenHeight + 100
            )
            confettiParticles.append(particle)
        }
        
        // Animate particles
        for i in confettiParticles.indices {
            let delay = Double.random(in: 0...0.3)
            let duration = Double.random(in: 1.2...2.0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeIn(duration: duration)) {
                    confettiParticles[i].position.y = confettiParticles[i].finalY
                    confettiParticles[i].position.x += confettiParticles[i].finalX
                }
                
                withAnimation(.easeIn(duration: duration * 0.7).delay(duration * 0.4)) {
                    confettiParticles[i].opacity = 0
                }
            }
        }
        
        // Hide confetti view after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            showConfetti = false
            confettiParticles = []
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let emoji: String
    let size: CGFloat
    var position: CGPoint
    var opacity: Double
    var finalX: CGFloat
    var finalY: CGFloat
}

#Preview {
    let vm = GameViewModel()
    vm.addPlayer(name: "Alex")
    vm.addPlayer(name: "Sam")
    vm.addPlayer(name: "Jordan")
    vm.startGame()
    return PickWinnerView(viewModel: vm)
}
