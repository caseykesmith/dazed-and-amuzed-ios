//
//  AddPlayersView.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import SwiftUI

struct AddPlayersView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var newPlayerName: String = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
                .onTapGesture {
                    isInputFocused = false
                }
            
            VStack(spacing: 24) {
                // Back Button
                HStack {
                    Button {
                        viewModel.goTo(.packSelect)
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
                
                // Title
                Text("Who's playing?")
                    .font(AppTheme.headlineFont)
                    .foregroundColor(AppTheme.text)
                
                // Player Input
                HStack(spacing: 12) {
                    TextField("Enter name", text: $newPlayerName)
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.text)
                        .padding(16)
                        .background(AppTheme.card)
                        .cornerRadius(AppTheme.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .stroke(AppTheme.border, lineWidth: 1)
                        )
                        .focused($isInputFocused)
                        .onSubmit {
                            addPlayer()
                        }
                    
                    Button {
                        addPlayer()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 52, height: 52)
                            .background(AppTheme.purple)
                            .cornerRadius(AppTheme.cornerRadius)
                    }
                    .disabled(newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, AppTheme.paddingLarge)
                
                // Player List
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(Array(viewModel.players.enumerated()), id: \.element.id) { index, player in
                            PlayerRow(player: player) {
                                viewModel.removePlayer(at: index)
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.paddingLarge)
                }
                
                // Player Count
                if !viewModel.players.isEmpty {
                    Text("\(viewModel.players.count) player\(viewModel.players.count == 1 ? "" : "s")")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textMuted)
                }
                
                Spacer()
                
                // Start Game Button
                Button {
                    viewModel.startGame()
                } label: {
                    Text(viewModel.players.count < 2 ? "Add at least 2 players" : "Start Game 🎉")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            viewModel.players.count < 2
                                ? LinearGradient(colors: [AppTheme.textDim, AppTheme.textDim], startPoint: .leading, endPoint: .trailing)
                                : AppTheme.primaryGradient
                        )
                        .cornerRadius(AppTheme.cornerRadius)
                }
                .disabled(viewModel.players.count < 2)
                .padding(.horizontal, AppTheme.paddingLarge)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func addPlayer() {
        let name = newPlayerName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        viewModel.addPlayer(name: name)
        newPlayerName = ""
    }
}

// MARK: - Player Row Component
struct PlayerRow: View {
    let player: Player
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Text(player.emoji)
                .font(.system(size: 28))
            
            Text(player.name)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.text)
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(AppTheme.textDim)
            }
        }
        .padding(14)
        .background(AppTheme.card)
        .cornerRadius(AppTheme.cornerRadius)
    }
}

#Preview {
    AddPlayersView(viewModel: GameViewModel())
}