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
    @State private var hasSelectedWinner = false
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Fixed Header
                VStack(spacing: 12) {
                    // Back button
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
                    
                    // Title
                    Text("👑")
                        .font(.system(size: 48))
                    
                    Text("Who won this round?")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.text)
                    
                    Text("Pick the best answer")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(AppTheme.textDim)
                }
                .padding(.bottom, 20)
                
                // Scrollable Player List
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.players) { player in
                            Button {
                                selectWinner(player)
                            } label: {
                                HStack(spacing: 16) {
                                    Text(player.emoji)
                                        .font(.system(size: 32))
                                        .frame(width: 40)
                                    
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
                }
                
                // Fixed Footer
                VStack(spacing: 12) {
                    Button {
                        viewModel.nextTurn()
                        viewModel.goTo(.gamePlay)
                    } label: {
                        Text("Skip — No clear winner")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    
                    Button {
                        viewModel.goTo(.results)
                    } label: {
                        Text("End Game & See Results")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(AppTheme.pink)
                    }
                }
                .padding(.vertical, 20)
                .padding(.bottom, 20)
            }
            
            // Confetti overlay
            if showConfetti {
                GeometryReader { geo in
                    ZStack {
                        ForEach(confettiParticles) { particle in
                            ConfettiPiece(particle: particle)
                        }
                    }
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }
        }
    }
    
    private func selectWinner(_ player: Player) {
        guard !hasSelectedWinner else { return }
        hasSelectedWinner = true
        
        HapticsService.success()
        
        viewModel.awardPoint(to: player)
        viewModel.lastWinner = player
        
        let newScore = viewModel.players.first { $0.id == player.id }?.score ?? 0
        
        triggerConfetti()
        
        if let target = viewModel.settings.gameLength.targetScore, newScore >= target {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                viewModel.goTo(.results)
            }
        } else {
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
        
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        for _ in 0..<80 {
            let particle = ConfettiParticle(
                color: colors.randomElement()!,
                size: CGFloat.random(in: 8...14),
                position: CGPoint(
                    x: CGFloat.random(in: 0...screenWidth),
                    y: -20
                ),
                opacity: 1.0,
                rotation: Double.random(in: 0...360),
                finalX: CGFloat.random(in: -150...150),
                finalY: screenHeight + 100
            )
            confettiParticles.append(particle)
        }
        
        for i in confettiParticles.indices {
            let delay = Double.random(in: 0...0.4)
            let duration = Double.random(in: 1.5...2.5)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeIn(duration: duration)) {
                    confettiParticles[i].position.y = confettiParticles[i].finalY
                    confettiParticles[i].position.x += confettiParticles[i].finalX
                    confettiParticles[i].rotation += Double.random(in: 360...720)
                }
                
                withAnimation(.easeIn(duration: duration * 0.7).delay(duration * 0.5)) {
                    confettiParticles[i].opacity = 0
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            showConfetti = false
            confettiParticles = []
        }
    }
}

// MARK: - Real Confetti Piece
struct ConfettiPiece: View {
    let particle: ConfettiParticle
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size * 1.5)
            .rotationEffect(.degrees(particle.rotation))
            .position(particle.position)
            .opacity(particle.opacity)
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    var position: CGPoint
    var opacity: Double
    var rotation: Double
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
