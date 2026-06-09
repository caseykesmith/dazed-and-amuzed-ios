//
//  PackSelectView.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import SwiftUI

struct PackSelectView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Back Button
                HStack {
                    Button {
                        viewModel.goTo(.vibeSelect)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.textMuted)
                    }
                    Spacer()
                    
                    // Select All / None
                    Button {
                        if viewModel.selectedPacks.count == QuestionCategory.availableCases.count {
                            viewModel.selectedPacks = []
                        } else {
                            viewModel.selectedPacks = Set(QuestionCategory.availableCases)
                        }
                    } label: {
                        Text(viewModel.selectedPacks.count == QuestionCategory.availableCases.count ? "Deselect All" : "Select All")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.purple)
                    }
                }
                .padding(.horizontal, AppTheme.paddingLarge)
                
                // Title
                VStack(spacing: 8) {
                    Text("Pick your packs")
                        .font(AppTheme.headlineFont)
                        .foregroundColor(AppTheme.text)
                    
                    Text("Choose what's in the mix")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.textMuted)
                }
                
                // Pack Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        ForEach(QuestionCategory.allCases, id: \.self) { category in
                            PackCard(
                                category: category,
                                isSelected: viewModel.selectedPacks.contains(category)
                            ) {
                                guard !category.isComingSoon else { return }
                                if viewModel.selectedPacks.contains(category) {
                                    viewModel.selectedPacks.remove(category)
                                } else {
                                    viewModel.selectedPacks.insert(category)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.paddingLarge)
                }
                
                // Continue Button
                Button {
                    viewModel.goTo(.addPlayers)
                } label: {
                    Text("Continue")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            viewModel.selectedPacks.isEmpty 
                                ? LinearGradient(colors: [AppTheme.textDim, AppTheme.textDim], startPoint: .leading, endPoint: .trailing)
                                : AppTheme.primaryGradient
                        )
                        .cornerRadius(AppTheme.cornerRadius)
                }
                .disabled(viewModel.selectedPacks.isEmpty)
                .padding(.horizontal, AppTheme.paddingLarge)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Pack Card Component
struct PackCard: View {
    let category: QuestionCategory
    let isSelected: Bool
    let action: () -> Void
    
    var categoryColor: Color {
        category.color
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(category.icon)
                    .font(.system(size: 36))

                Text(category.displayName)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.text)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                if category.isComingSoon {
                    Text("COMING SOON")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .tracking(1)
                        .foregroundColor(AppTheme.textDim)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .opacity(category.isComingSoon ? 0.5 : 1)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(isSelected ? categoryColor.opacity(0.15) : AppTheme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(isSelected ? categoryColor : AppTheme.border, lineWidth: isSelected ? 2 : 1)
            )
            .overlay(
                // Checkmark
                Group {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(categoryColor)
                            .font(.system(size: 20))
                            .padding(8)
                    }
                },
                alignment: .topTrailing
            )
        }
        .disabled(category.isComingSoon)
    }
}

#Preview {
    PackSelectView(viewModel: GameViewModel())
}