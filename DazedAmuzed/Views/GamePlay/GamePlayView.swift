//
//  GamePlayView.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import SwiftUI

struct GamePlayView: View {
    @ObservedObject var viewModel: GameViewModel
    @StateObject private var store = StoreKitService.shared
    @State private var showVibeSwitch = false
    @State private var showRules = false
    @State private var showExtensionPacks = false

    let baseCategories: [QuestionCategory] = [
        .debates, .wouldYouRather, .stories, .reflection, .exposed, .drinkIf
    ]

    var purchasedExtensionPacks: [QuestionCategory] {
        let packs: [(QuestionCategory, String)] = [
            (.musicTrivia, StoreKitService.musicTrivia),
            (.reunion, StoreKitService.reunion),
            (.bachelorette, StoreKitService.bachelorette),
            (.couplesNight, StoreKitService.couplesNight),
            (.afterDark, StoreKitService.afterDark),
            (.firstDate, StoreKitService.firstDate),
        ]
        return packs.filter { store.hasAccess(to: $0.1) }.map { $0.0 }
    }

    var allCategories: [QuestionCategory] {
        baseCategories + purchasedExtensionPacks
    }

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    Button {
                        viewModel.goTo(.results)
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
                        Text("Round \(viewModel.currentRound)")
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
                        showRules = true
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
                
                ScrollView(showsIndicators: false) {
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
                        ForEach(allCategories, id: \.self) { category in
                            CardTypeButton(
                                name: category.displayName,
                                icon: category.icon,
                                color: category.color,
                                subtitle: nil
                            ) {
                                viewModel.selectCategory(category)
                                HapticsService.light()
                                viewModel.goTo(.judgeTurn)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                }
                
                // Extension Packs Teaser
                if !store.hasPremium {
                    HStack(spacing: 12) {
                        // Music Trivia (locked)
                        Button {
                            showExtensionPacks = true
                        } label: {
                            ExtensionPackMini(icon: "🎵", name: "Music Trivia", isLocked: true)
                        }

                        // Unlock More
                        Button {
                            showExtensionPacks = true
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
                                    .stroke(AppTheme.cyan, style: StrokeStyle(lineWidth: 1, dash: [6]))
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                // Score Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(viewModel.players.enumerated()), id: \.element.id) { index, player in
                            ScoreChip(
                                name: player.name,
                                emoji: player.emoji,
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
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showRules) {
            RulesSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showExtensionPacks) {
            ExtensionPacksView(viewModel: viewModel)
        }
    }
    
    var vibeEmoji: String {
        switch viewModel.vibeMode {
        case .party: return "🎉"
        case .chill: return "🌙"
        case .mixed: return "✨"
        }
    }
    
    var vibeTitle: String {
        switch viewModel.vibeMode {
        case .party: return "Party Mode"
        case .chill: return "Go Deep"
        case .mixed: return "Best of Both"
        }
    }
    
    var vibeColor: Color {
        switch viewModel.vibeMode {
        case .party: return Color(hex: "FF9500")
        case .chill: return Color(hex: "5AC8FA")
        case .mixed: return Color(hex: "BF5AF2")
        }
    }
    
    var progress: CGFloat {
        min(CGFloat(viewModel.currentRound) / 10.0, 1.0)
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
    let emoji: String
    let score: Int
    let isJudge: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Text(emoji)
                .font(.system(size: 14))
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
                    VibeOptionRow(emoji: "🎉", title: "Party Mode", isSelected: viewModel.vibeMode == .party) {
                        viewModel.vibeMode = .party
                        dismiss()
                    }
                    VibeOptionRow(emoji: "🌙", title: "Go Deep", isSelected: viewModel.vibeMode == .chill) {
                        viewModel.vibeMode = .chill
                        dismiss()
                    }
                    VibeOptionRow(emoji: "✨", title: "Best of Both", isSelected: viewModel.vibeMode == .mixed) {
                        viewModel.vibeMode = .mixed
                        dismiss()
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
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

// MARK: - Rules Sheet
struct RulesSheet: View {
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("📖 How to Play")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.text)
                    .padding(.top, 24)
                
                VStack(alignment: .leading, spacing: 16) {
                    RuleRow(number: "1", text: "The **Judge** picks a card type")
                    RuleRow(number: "2", text: "Everyone else answers or debates")
                    RuleRow(number: "3", text: "Judge picks their favorite")
                    RuleRow(number: "4", text: "Winner gets a point")
                    RuleRow(number: "5", text: "First to target score wins!")
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
}

struct RuleRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(number)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(AppTheme.purple)
                .cornerRadius(14)
            
            Text(.init(text))
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(AppTheme.text)
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
