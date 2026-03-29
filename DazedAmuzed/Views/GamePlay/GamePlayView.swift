//
//  GamePlayView.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import SwiftUI

struct GamePlayView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showVibeSwitch = false
    
    let cardTypes: [(name: String, icon: String, color: Color, category: QuestionCategory)] = [
        ("Debate", "🔥", Color(hex: "FF6B35"), .debates),
        ("Would You Rather", "⚖️", Color(hex: "FF2D78"), .wouldYouRather),
        ("Story Time", "💬", Color(hex: "7B68EE"), .stories),
        ("Most Likely To", "👀", Color(hex: "9ACD32"), .exposed),
        ("Mini Game", "🎲", Color(hex: "20B2AA"), .reflection),
        ("Confess", "🫣", Color(hex: "FFD700"), .drinkIf)
    ]
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    Button {
                        viewModel.resetGame()
                    } label: {
                        Text("End Game")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppTheme.textDim)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Vibe Mode Banner
                Button {
                    showVibeSwitch = true
                } label: {
                    HStack {
                        HStack(spacing: 8) {
                            Text(vibeEmoji)
                                .font(.system(size: 20))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(vibeTitle)
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(vibeColor)
                                Text("Tap to switch vibe")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(AppTheme.textDim)
                            }
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Text("Change")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(AppTheme.textMuted)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }
                    .padding(16)
                    .background(vibeColor.opacity(0.15))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(vibeColor.opacity(0.4), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                // Round & Rules
                HStack {
                    HStack(spacing: 8) {
                        Text("Round \(viewModel.roundNumber)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppTheme.textMuted)
                        
                        // Progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(AppTheme.card)
                                    .frame(height: 4)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(AppTheme.primaryGradient)
                                    .frame(width: geo.size.width * progress, height: 4)
                            }
                        }
                        .frame(width: 60, height: 4)
                    }
                    
                    Spacer()
                    
                    Button {
                        // Show rules
                    } label: {
                        HStack(spacing: 4) {
                            Text("📖")
                            Text("Rules")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(AppTheme.textMuted)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Judge Section
                VStack(spacing: 12) {
                    // Judge Badge
                    HStack(spacing: 6) {
                        Text("👑")
                            .font(.system(size: 14))
                        Text("JUDGE")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .tracking(2)
                    }
                    .foregroundColor(Color(hex: "FFD700"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(hex: "FFD700").opacity(0.2))
                    .cornerRadius(20)
                    
                    // Player Name
                    if let player = viewModel.currentPlayer {
                        Text(player.name)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.text)
                    }
                    
                    Text("Pick a card type")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(AppTheme.textDim)
                }
                .padding(.top, 24)
                
                // Card Type Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(cardTypes, id: \.name) { card in
                        CardTypeButton(
                            name: card.name,
                            icon: card.icon,
                            color: card.color,
                            subtitle: card.name == "Mini Game" || card.name == "Confess" ? "No points" : nil
                        ) {
                            viewModel.selectedPacks = [card.category]
                            viewModel.nextQuestion()
                            viewModel.goTo(.judgeTurn)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // Extension Packs Teaser
                HStack(spacing: 12) {
                    // Music Trivia (locked)
                    ExtensionPackMini(icon: "🎵", name: "Music Trivia", isLocked: true)
                    
                    // Unlock More
                    Button {
                        // Show extension packs
                    } label: {
                        HStack(spacing: 8) {
                            Text("🎁")
                            Text("Unlock More")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(AppTheme.cyan)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.card)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.cyan.opacity(0.5), lineWidth: 1)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                        )
                    }
                }
                .padding(.horizontal, 24)
                
                // Score Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(viewModel.players.enumerated()), id: \.element.id) { index, player in
                            ScoreChip(
                                name: player.name,
                                score: player.score,
                                isJudge: index == viewModel.currentPlayerIndex
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 16)
            }
        }
        .sheet(isPresented: $showVibeSwitch) {
            VibeSwitchSheet(viewModel: viewModel)
        }
    }
    
    var vibeEmoji: String {
        switch viewModel.vibe {
        case .party: return "🎉"
        case .deep: return "🌙"
        case .mixed: return "✨"
        }
    }
    
    var vibeTitle: String {
        switch viewModel.vibe {
        case .party: return "Party Mode"
        case .deep: return "Deep Mode"
        case .mixed: return "Best of Both"
        }
    }
    
    var vibeColor: Color {
        switch viewModel.vibe {
        case .party: return Color(hex: "FF9500")
        case .deep: return Color(hex: "5AC8FA")
        case .mixed: return Color(hex: "BF5AF2")
        }
    }
    
    var progress: CGFloat {
        // Simple progress based on round
        min(CGFloat(viewModel.roundNumber) / 10.0, 1.0)
    }
}

// MARK: - Card Type Button
struct CardTypeButton: View {
    let name: String
    let icon: String
    let color: Color
    let subtitle: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(icon)
                    .font(.system(size: 28))
                
                Text(name)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                    .multilineTextAlignment(.center)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(AppTheme.textDim)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(color.opacity(0.12))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(color.opacity(0.4), lineWidth: 1)
            )
        }
    }
}

// MARK: - Extension Pack Mini
struct ExtensionPackMini: View {
    let icon: String
    let name: String
    let isLocked: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Text(icon)
                    .font(.system(size: 20))
                    .opacity(isLocked ? 0.5 : 1)
                
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.textDim)
                        .offset(x: 12, y: -8)
                }
            }
            
            Text(name)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(AppTheme.textDim)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppTheme.card)
        .cornerRadius(12)
    }
}

// MARK: - Score Chip
struct ScoreChip: View {
    let name: String
    let score: Int
    let isJudge: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            if isJudge {
                Text("👑")
                    .font(.system(size: 12))
            }
            Text(name)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.text)
            Text("\(score)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(isJudge ? Color(hex: "FFD700") : AppTheme.textMuted)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(isJudge ? Color(hex: "FFD700").opacity(0.15) : AppTheme.card)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isJudge ? Color(hex: "FFD700").opacity(0.4) : AppTheme.border, lineWidth: 1)
        )
    }
}

// MARK: - Vibe Switch Sheet
struct VibeSwitchSheet: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Switch Vibe")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.text)
                    .padding(.top, 24)
                
                VStack(spacing: 12) {
                    VibeOptionRow(emoji: "🎉", title: "Party Mode", isSelected: viewModel.vibe == .party) {
                        viewModel.vibe = .party
                        dismiss()
                    }
                    VibeOptionRow(emoji: "🌙", title: "Deep Mode", isSelected: viewModel.vibe == .deep) {
                        viewModel.vibe = .deep
                        dismiss()
                    }
                    VibeOptionRow(emoji: "✨", title: "Best of Both", isSelected: viewModel.vibe == .mixed) {
                        viewModel.vibe = .mixed
                        dismiss()
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }
}

struct VibeOptionRow: View {
    let emoji: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(emoji)
                    .font(.system(size: 24))
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.text)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.purple)
                }
            }
            .padding(16)
            .background(AppTheme.card)
            .cornerRadius(12)
        }
    }
}

#Preview {
    let vm = GameViewModel()
    vm.addPlayer(name: "P")
    vm.addPlayer(name: "C")
    vm.addPlayer(name: "Dani")
    vm.startGame()
    return GamePlayView(viewModel: vm)
}
