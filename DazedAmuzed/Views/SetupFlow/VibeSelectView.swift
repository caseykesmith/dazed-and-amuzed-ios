//
//  VibeSelectView.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import SwiftUI

struct VibeSelectView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var drinkingMode = false
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Set the vibe")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.text)
                        
                        Text("We'll curate the perfect mix")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(AppTheme.textDim)
                    }
                    .padding(.top, 40)
                    
                    // Vibe Options
                    VStack(spacing: 16) {
                        VibeCard(
                            emoji: "🎉",
                            title: "Party Mode",
                            subtitle: "Say no more.",
                            isSelected: viewModel.vibe == .party,
                            badgeText: "POPULAR",
                            accentColor: Color(hex: "FF9500")
                        ) {
                            viewModel.vibe = .party
                        }
                        
                        VibeCard(
                            emoji: "🌙",
                            title: "Go Deep",
                            subtitle: "The conversations you'll remember.",
                            isSelected: viewModel.vibe == .deep,
                            badgeText: nil,
                            accentColor: Color(hex: "5AC8FA")
                        ) {
                            viewModel.vibe = .deep
                        }
                        
                        VibeCard(
                            emoji: "✨",
                            title: "Best of Both",
                            subtitle: "Start fun, end meaningful.",
                            isSelected: viewModel.vibe == .mixed,
                            badgeText: nil,
                            accentColor: Color(hex: "BF5AF2")
                        ) {
                            viewModel.vibe = .mixed
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // How to Play
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text("📖")
                            Text("How to Play")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(AppTheme.text)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HowToPlayRow(number: "1", text: "Take turns being the **Judge** — they pick a card type")
                            HowToPlayRow(number: "2", text: "Everyone else answers, debates, or votes")
                            HowToPlayRow(number: "3", text: "Judge picks their favorite — winner gets a 🪙 **token**")
                            
                            HStack(alignment: .top, spacing: 8) {
                                Text("🏆")
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Most points wins!")
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(AppTheme.textMuted)
                                    Text("Choose your game length later.")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "FFD60A"))
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(AppTheme.card)
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    
                    // Drinking Mode Toggle
                    HStack {
                        HStack(spacing: 12) {
                            Text("🍺")
                                .font(.system(size: 24))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Drinking Mode")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "FF9F0A"))
                                
                                Text("21+ · Drink Responsibly")
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(Color(hex: "FF9F0A").opacity(0.7))
                            }
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $drinkingMode)
                            .tint(Color(hex: "FF9F0A"))
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "FF9F0A").opacity(0.15))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "FF9F0A").opacity(0.5), lineWidth: 1.5)
                    )
                    .padding(.horizontal, 24)
                    
                    // Disclaimer
                    Text("By enabling Drinking Mode, you confirm you are 21+ years old. Please drink responsibly.")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(AppTheme.textDim)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Continue Button
                    Button {
                        viewModel.settings.drinkingMode = drinkingMode
                        viewModel.goTo(.addPlayers)
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
}

// MARK: - Vibe Card
struct VibeCard: View {
    let emoji: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let badgeText: String?
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Emoji circle
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.2))
                        .frame(width: 52, height: 52)
                    Text(emoji)
                        .font(.system(size: 26))
                }
                
                // Text
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.text)
                    
                    Text(subtitle)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(AppTheme.textDim)
                }
                
                Spacer()
                
                // Badge + Radio
                HStack(spacing: 10) {
                    if let badge = badgeText {
                        Text("🔥 \(badge)")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "FF9500"))
                            .cornerRadius(6)
                    }
                    
                    // Radio button
                    ZStack {
                        Circle()
                            .stroke(isSelected ? accentColor : AppTheme.textDim.opacity(0.5), lineWidth: 2)
                            .frame(width: 22, height: 22)
                        
                        if isSelected {
                            Circle()
                                .fill(accentColor)
                                .frame(width: 11, height: 11)
                        }
                    }
                }
            }
            .padding(14)
            .background(AppTheme.card)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? accentColor : AppTheme.border, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - How To Play Row
struct HowToPlayRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(number)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
                .background(AppTheme.purple)
                .cornerRadius(11)
            
            Text(.init(text))
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(AppTheme.textMuted)
        }
    }
}

#Preview {
    VibeSelectView(viewModel: GameViewModel())
}
