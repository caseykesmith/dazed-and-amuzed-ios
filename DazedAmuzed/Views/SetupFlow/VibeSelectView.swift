//
//  VibeSelectView.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import SwiftUI

struct VibeSelectView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Back Button
                HStack {
                    Button {
                        viewModel.goTo(.playMode)
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
                    Text("Set the vibe")
                        .font(AppTheme.headlineFont)
                        .foregroundColor(AppTheme.text)
                    
                    Text("What kind of night is it?")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.textMuted)
                }
                
                Spacer()
                
                // Vibe Options
                VStack(spacing: 12) {
                    VibeButton(
                        icon: "🎉",
                        title: "Party Mode",
                        description: "Keep it light. Laughs and good vibes only.",
                        vibe: .party,
                        selectedVibe: viewModel.vibe,
                        gradient: AppTheme.partyGradient
                    ) {
                        viewModel.vibe = .party
                    }
                    
                    VibeButton(
                        icon: "🌙",
                        title: "Deep Mode",
                        description: "Get real. Vulnerability welcome.",
                        vibe: .deep,
                        selectedVibe: viewModel.vibe,
                        gradient: AppTheme.deepGradient
                    ) {
                        viewModel.vibe = .deep
                    }
                    
                    VibeButton(
                        icon: "✨",
                        title: "Mix It Up",
                        description: "Best of both. Let the cards decide.",
                        vibe: .mixed,
                        selectedVibe: viewModel.vibe,
                        gradient: AppTheme.primaryGradient
                    ) {
                        viewModel.vibe = .mixed
                    }
                }
                .padding(.horizontal, AppTheme.paddingLarge)
                
                Spacer()
                
                // Continue Button
                Button {
                    viewModel.goTo(.packSelect)
                } label: {
                    Text("Continue")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppTheme.primaryGradient)
                        .cornerRadius(AppTheme.cornerRadius)
                }
                .padding(.horizontal, AppTheme.paddingLarge)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Vibe Button Component
struct VibeButton: View {
    let icon: String
    let title: String
    let description: String
    let vibe: Vibe
    let selectedVibe: Vibe
    let gradient: LinearGradient
    let action: () -> Void
    
    var isSelected: Bool {
        vibe == selectedVibe
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(icon)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.text)
                    
                    Text(description)
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textMuted)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(gradient)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(isSelected ? AppTheme.cardElevated : AppTheme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(isSelected ? AppTheme.purple : AppTheme.border, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

#Preview {
    VibeSelectView(viewModel: GameViewModel())
}