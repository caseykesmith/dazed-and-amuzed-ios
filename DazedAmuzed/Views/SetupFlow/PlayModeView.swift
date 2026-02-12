//
//  PlayModeView.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import SwiftUI

struct PlayModeView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Back Button
                HStack {
                    Button {
                        viewModel.goTo(.home)
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
                    Text("How are you playing?")
                        .font(AppTheme.headlineFont)
                        .foregroundColor(AppTheme.text)
                    
                    Text("Choose your setup")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.textMuted)
                }
                
                Spacer()
                
                // Options
                VStack(spacing: 16) {
                    // In Person
                    PlayModeButton(
                        icon: "🤝",
                        title: "In Person",
                        description: "Pass the phone around. Great for 3-8 people together.",
                        isSelected: viewModel.playMode == .local,
                        color: AppTheme.purple
                    ) {
                        viewModel.playMode = .local
                    }
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .fill(AppTheme.border)
                            .frame(height: 1)
                        Text("or")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.textDim)
                        Rectangle()
                            .fill(AppTheme.border)
                            .frame(height: 1)
                    }
                    .padding(.vertical, 8)
                    
                    // Video Hang
                    PlayModeButton(
                        icon: "📹",
                        title: "Video Hang",
                        description: "FaceTime or Zoom. Everyone plays on their own phone.",
                        isSelected: viewModel.playMode == .video,
                        color: AppTheme.cyan
                    ) {
                        viewModel.playMode = .video
                    }
                }
                .padding(.horizontal, AppTheme.paddingLarge)
                
                Spacer()
                
                // Continue Button
                Button {
                    viewModel.goTo(.vibeSelect)
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

// MARK: - Play Mode Button Component
struct PlayModeButton: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 40))
                
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? color : AppTheme.text)
                
                Text(description)
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.textMuted)
                    .multilineTextAlignment(.center)
                
                if isSelected {
                    Text("✓ Selected")
                        .font(AppTheme.captionFont)
                        .foregroundColor(color)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                    .fill(isSelected ? color.opacity(0.15) : AppTheme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                    .stroke(isSelected ? color : AppTheme.border, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

#Preview {
    PlayModeView(viewModel: GameViewModel())
}