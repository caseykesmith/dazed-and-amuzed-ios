//
//  HomeView.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo
                VStack(spacing: 16) {
                    Text("DAZED")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.primaryGradient)
                    
                    Text("& AMUZED")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textMuted)
                    
                    Text("Questions that actually slap")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.textDim)
                        .padding(.top, 8)
                }
                
                Spacer()
                
                // Start Button
                Button {
                    viewModel.goTo(.playMode)
                } label: {
                    Text("Start Game")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppTheme.primaryGradient)
                        .cornerRadius(AppTheme.cornerRadius)
                }
                .padding(.horizontal, AppTheme.paddingLarge)
                
                // Settings Button
                Button {
                    // TODO: Settings
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.textMuted)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    HomeView(viewModel: GameViewModel())
}