//
//  HomeView.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showExtensionPacks = false
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
             
                
                Spacer()
                
                // Logo
                VStack(spacing: 0) {
                    Text("DAZED")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(hex: "9B6DFF"),
                                    Color(hex: "FF6B9D")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("&")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.textDim)
                        .padding(.vertical, 2)
                    
                    Text("AMUZED")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FF6B9D"),
                                    Color(hex: "C44DFF")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                // Tagline
                VStack(spacing: 6) {
                    Text("The party game that reads the room.")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.text)
                    
                    Text("We'll take it from here.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(AppTheme.textDim)
                }
                .padding(.top, 24)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 16) {
                    // Let's Go Button
                    Button {
                        viewModel.goTo(.vibeSelect)
                    } label: {
                        Text("Let's Go")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(AppTheme.primaryGradient)
                            .cornerRadius(16)
                    }
                    
                    // Join with code
                   // Button {
                        // TODO: Join with code
                 //   } label: {
                    //    Text("Join with code")
                   //         .font(.system(size: 16, weight: .medium, design: .rounded))
                  //          .foregroundColor(AppTheme.textMuted)
              //      }
               //     .padding(.top, 4)
                    
                    // Extension Packs
                    Button {
                        showExtensionPacks = true
                    } label: {
                        Text("Extension Packs")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(AppTheme.purple)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppTheme.purple.opacity(0.5), lineWidth: 1.5)
                            )

                    .sheet(isPresented: $showExtensionPacks) {
                        ExtensionPacksView(viewModel: viewModel)
                    }
                    }
                    
                    // Our Story
                    Button {
                        // TODO: Our story
                    } label: {
                        Text("Our Story")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(AppTheme.textDim)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
    }
}

// MARK: - Menu View
struct MenuView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Menu")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.text)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textMuted)
                            .frame(width: 36, height: 36)
                            .background(AppTheme.card)
                            .cornerRadius(18)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)
                
                // Menu Items
                VStack(spacing: 12) {
                    MenuRow(
                        icon: "🎁",
                        title: "Extension Packs",
                        subtitle: "Add more fun to your game",
                        color: AppTheme.pink
                    )
                    
                    MenuRow(
                        icon: "💜",
                        title: "Our Story",
                        subtitle: "Why we built this",
                        color: AppTheme.purple
                    )
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(color)
                
                Text(subtitle)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(AppTheme.textDim)
            }
            
            Spacer()
        }
        .padding(16)
        .background(AppTheme.card)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    HomeView(viewModel: GameViewModel())
}
