//
//  SetupView.swift
//  DazedAmuzed
//

import SwiftUI

/// Single-screen setup: players, vibe, game length, and drinking mode —
/// replaces the old PlayMode → VibeSelect → PackSelect → AddPlayers chain.
struct SetupView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var draftName = ""
    @FocusState private var nameFieldFocused: Bool

    private let chipColors: [Color] = [
        Color(hex: "FF5A1F"), Color(hex: "FF2E88"), Color(hex: "8B6BFF"),
        Color(hex: "C6F432"), Color(hex: "FFD60A"), Color(hex: "2EE6C5")
    ]

    var canStart: Bool { viewModel.players.count >= 3 }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    header
                    playersSection
                    vibeSection
                    lengthSection
                    drinkingToggle
                    footer
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .onTapGesture { nameFieldFocused = false }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                viewModel.goTo(.home)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color(hex: "1A1A1A"))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Back")

            Text("Who's playing?")
                .displayStyle(42)
                .foregroundColor(.white)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Players

    private var playersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                TextField("", text: $draftName, prompt: Text("Add a name").foregroundColor(Color(hex: "8C8C8C")))
                    .focused($nameFieldFocused)
                    .font(AppTheme.interMedium(16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .frame(height: 54)
                    .background(Color(hex: "111111"))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color(hex: "333333"), lineWidth: 2)
                    )
                    .submitLabel(.done)
                    .onSubmit(addPlayer)

                Button(action: addPlayer) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 54, height: 54)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .accessibilityLabel("Add player")
            }

            if !viewModel.players.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(Array(viewModel.players.enumerated()), id: \.element.id) { index, player in
                        HStack(spacing: 6) {
                            Text(player.name)
                                .displayStyle(15)
                            Button {
                                viewModel.removePlayer(at: index)
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundColor(.black)
                                    .frame(width: 28, height: 28)
                                    .background(Color.black.opacity(0.14))
                                    .clipShape(Circle())
                            }
                            .accessibilityLabel("Remove \(player.name)")
                        }
                        .foregroundColor(.black)
                        .padding(.leading, 14)
                        .padding(.trailing, 4)
                        .frame(height: 40)
                        .background(chipColors[index % chipColors.count])
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }

    // MARK: - Vibe

    private var vibeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("THE VIBE")
            HStack(spacing: 8) {
                vibeButton(.party, label: "Party")
                vibeButton(.deep, label: "Deep")
                vibeButton(.mixed, label: "Both")
            }
            Text(vibeDescription)
                .font(AppTheme.interMedium(14))
                .foregroundColor(Color(hex: "D9D9D9"))
        }
    }

    private func vibeButton(_ vibe: Vibe, label: String) -> some View {
        let on = viewModel.vibe == vibe
        let color = vibeAccent(vibe)
        return Button {
            viewModel.vibe = vibe
        } label: {
            Text(label)
                .displayStyle(17)
                .foregroundColor(on ? .black : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(on ? color : Color(hex: "111111"))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(on ? color : Color(hex: "333333"), lineWidth: 2)
                )
        }
    }

    private func vibeAccent(_ vibe: Vibe) -> Color {
        switch vibe {
        case .party: return Color(hex: "FF5A1F")
        case .deep: return Color(hex: "8B6BFF")
        case .mixed: return Color(hex: "FF2E88")
        }
    }

    private var vibeDescription: String {
        switch viewModel.vibe {
        case .party: return "Loud, funny, chaotic. Built for a full room."
        case .deep: return "Real questions for the people you actually love."
        case .mixed: return "Starts wild, ends meaningful. Our favorite."
        }
    }

    // MARK: - Game length

    private var lengthSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("PLAY TO")
            HStack(spacing: 8) {
                ForEach(GameLength.allCases, id: \.self) { length in
                    lengthButton(length)
                }
            }
        }
    }

    private func lengthButton(_ length: GameLength) -> some View {
        let on = viewModel.settings.gameLength == length
        return Button {
            viewModel.settings.gameLength = length
        } label: {
            VStack(spacing: 1) {
                Text(length.rawValue)
                    .displayStyle(17)
                Text(length.subtitle)
                    .font(AppTheme.interMedium(12))
            }
            .foregroundColor(on ? .black : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(on ? Color.white : Color(hex: "111111"))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(on ? Color.clear : Color(hex: "333333"), lineWidth: 2)
            )
        }
    }

    // MARK: - Drinking mode

    private var drinkingToggle: some View {
        Button {
            viewModel.settings.drinkingMode.toggle()
            HapticsService.light()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Drinking Mode")
                        .displayStyle(17)
                        .foregroundColor(.white)
                    Text("21+ only. Drink responsibly.")
                        .font(AppTheme.interMedium(12))
                        .foregroundColor(Color(hex: "A6A6A6"))
                }
                Spacer()
                ZStack(alignment: viewModel.settings.drinkingMode ? .trailing : .leading) {
                    Capsule()
                        .fill(viewModel.settings.drinkingMode ? Color(hex: "FFD60A") : Color(hex: "333333"))
                        .frame(width: 56, height: 32)
                    Circle()
                        .fill(viewModel.settings.drinkingMode ? Color.black : Color.white)
                        .frame(width: 26, height: 26)
                        .padding(3)
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.75), value: viewModel.settings.drinkingMode)
            }
            .padding(.horizontal, 16)
            .frame(height: 64)
            .background(Color(hex: "111111"))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(viewModel.settings.drinkingMode ? Color(hex: "FFD60A") : Color(hex: "333333"), lineWidth: 2)
            )
        }
        .accessibilityValue(viewModel.settings.drinkingMode ? "On" : "Off")
    }

    // MARK: - Footer

    @ViewBuilder
    private var footer: some View {
        if canStart {
            Button {
                viewModel.startGame()
            } label: {
                HStack(spacing: 10) {
                    Text("Let's play")
                    Image(systemName: "arrow.right")
                }
                .displayStyle(20)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(Color.white)
                .clipShape(Capsule())
            }
        } else {
            Text(needText)
                .displayStyle(18)
                .foregroundColor(Color(hex: "BFBFBF"))
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .overlay(
                    Capsule().stroke(Color(hex: "555555"), style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
                )
        }
    }

    private var needText: String {
        let need = 3 - viewModel.players.count
        return need == 1 ? "Add 1 more player" : "Add \(need) more players"
    }

    private func addPlayer() {
        let name = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, viewModel.players.count < 12 else { return }
        viewModel.addPlayer(name: name)
        draftName = ""
    }
}

// MARK: - Section label

private struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(AppTheme.interBold(12))
            .tracking(2)
            .foregroundColor(Color(hex: "A6A6A6"))
    }
}

// MARK: - Flow layout (wrapping chip row)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        FlowResult(in: proposal.width ?? 0, spacing: spacing, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, spacing: spacing, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y),
                proposal: .unspecified
            )
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
    SetupView(viewModel: GameViewModel())
}
