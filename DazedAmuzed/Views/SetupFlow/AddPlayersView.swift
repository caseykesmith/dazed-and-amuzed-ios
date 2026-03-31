//
//  AddPlayersView.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import SwiftUI

struct AddPlayersView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var newPlayerName = ""
    @State private var soundEnabled = true
    @State private var selectedLength: GameLength = .classic
    @FocusState private var isTextFieldFocused: Bool
    
    var canStart: Bool {
        viewModel.players.count >= 3
    }
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Back Button
                    HStack {
                        Button {
                            viewModel.goTo(.vibeSelect)
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
                    
                    // Header
                    Text("Who's playing?")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.text)
                    
                    // Main Card
                    VStack(spacing: 20) {
                        // Add Players Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ADD PLAYERS (3-12)")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(AppTheme.textDim)
                                .tracking(1)
                            
                            // Input Row
                            HStack(spacing: 12) {
                                TextField("Enter name...", text: $newPlayerName)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(AppTheme.text)
                                    .padding(16)
                                    .background(AppTheme.background)
                                    .cornerRadius(12)
                                    .focused($isTextFieldFocused)
                                    .onSubmit {
                                        addPlayer()
                                    }
                                
                                Button {
                                    addPlayer()
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 52, height: 52)
                                        .background(
                                            LinearGradient(
                                                colors: [AppTheme.purple, AppTheme.pink],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(12)
                                }
                            }
                            
                            // Player Chips
                            if viewModel.players.isEmpty {
                                Text("Add at least 3 players to start")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(AppTheme.textDim)
                                    .padding(.top, 4)
                            } else {
                                FlowLayout(spacing: 8) {
                                    ForEach(viewModel.players) { player in
                                        PlayerChip(name: player.name) {
                                            if let index = viewModel.players.firstIndex(where: { $0.id == player.id }) {
                                                viewModel.removePlayer(at: index)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Toggles Row
                        HStack(spacing: 12) {
                            // Sound Toggle
                            ToggleButton(
                                icon: soundEnabled ? "🔊" : "🔇",
                                label: "Sound",
                                isOn: soundEnabled,
                                activeColor: AppTheme.textMuted
                            ) {
                                soundEnabled.toggle()
                            }
                            
                            // Drinking Toggle
                            ToggleButton(
                                icon: "🍺",
                                label: "Drinking \(viewModel.settings.drinkingMode ? "ON" : "OFF")",
                                isOn: viewModel.settings.drinkingMode,
                                activeColor: Color(hex: "FF9F0A")
                            ) {
                                viewModel.settings.drinkingMode.toggle()
                            }
                        }
                        
                        // Game Length
                        VStack(alignment: .leading, spacing: 12) {
                            Text("GAME LENGTH")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(AppTheme.textDim)
                                .tracking(1)
                            
                            HStack(spacing: 10) {
                                ForEach(GameLength.allCases, id: \.self) { length in
                                    GameLengthButton(
                                        title: length.rawValue,
                                        subtitle: length.subtitle,
                                        isSelected: selectedLength == length
                                    ) {
                                        selectedLength = length
                                    }
                                }
                            }
                        }
                        
                        // Start Button
                        Button {
                            if canStart {
                                viewModel.settings.soundEnabled = soundEnabled
                                viewModel.settings.gameLength = selectedLength
                                viewModel.startGame()
                            }
                        } label: {
                            Text(canStart ? "Let's play! →" : "Add \(3 - viewModel.players.count) more")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(canStart ? .white : AppTheme.textDim)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    Group {
                                        if canStart {
                                            AppTheme.primaryGradient
                                        } else {
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(AppTheme.border, lineWidth: 1)
                                        }
                                    }
                                )
                                .cornerRadius(14)
                        }
                        .disabled(!canStart)
                    }
                    .padding(20)
                    .background(AppTheme.card)
                    .cornerRadius(20)
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
    
    private func addPlayer() {
        let name = newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !name.isEmpty && viewModel.players.count < 12 {
            viewModel.addPlayer(name: name)
            newPlayerName = ""
        }
    }
}

// MARK: - Player Chip
struct PlayerChip: View {
    let name: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(name)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.text)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.textDim)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppTheme.background)
        .cornerRadius(20)
    }
}

// MARK: - Toggle Button
struct ToggleButton: View {
    let icon: String
    let label: String
    let isOn: Bool
    let activeColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(icon)
                    .font(.system(size: 16))
                Text(label)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(isOn ? activeColor : AppTheme.textDim)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(isOn ? activeColor.opacity(0.15) : AppTheme.background)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isOn ? activeColor.opacity(0.5) : AppTheme.border, lineWidth: 1)
            )
        }
    }
}

// MARK: - Game Length Button
struct GameLengthButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? AppTheme.background : AppTheme.text)
                Text(subtitle)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(isSelected ? AppTheme.background.opacity(0.8) : AppTheme.textDim)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? Color(hex: "FFD60A") : Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : AppTheme.border, lineWidth: 1)
            )
        }
    }
}

// MARK: - Flow Layout for Chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, spacing: spacing, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, spacing: spacing, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, spacing: CGFloat, subviews: Subviews) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                
                self.size.width = max(self.size.width, x - spacing)
                self.size.height = y + rowHeight
            }
        }
    }
}

#Preview {
    AddPlayersView(viewModel: GameViewModel())
}
