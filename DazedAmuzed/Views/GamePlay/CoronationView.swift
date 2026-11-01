//
//  CoronationView.swift
//  DazedAmuzed
//
//  End-of-game crowning ceremony — replaces the old plain scoreboard.
//

import SwiftUI

struct CoronationView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var decreeIndex = 0
    @State private var replayKey = 0

    private let decrees = [
        "Everyone calls me Your Majesty.",
        "You pick my next drink.",
        "No phones at the table but mine."
    ]

    var sortedPlayers: [Player] {
        viewModel.players.sorted { $0.score > $1.score }
    }

    var champion: Player? { sortedPlayers.first }
    var jester: Player? { sortedPlayers.count > 1 ? sortedPlayers.last : nil }

    var isTie: Bool {
        guard sortedPlayers.count >= 2 else { return false }
        return sortedPlayers[0].score == sortedPlayers[1].score
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ConfettiFallView()
                .id(replayKey)
                .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    HStack {
                        Text("GAME OVER · \(champion?.score ?? 0) POINTS")
                            .font(AppTheme.interBold(12))
                            .tracking(2)
                            .foregroundColor(Color(hex: "A6A6A6"))
                        Spacer()
                        Button {
                            HapticsService.light()
                            replayKey += 1
                        } label: {
                            Text("Replay")
                                .font(AppTheme.interBold(13))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .frame(minHeight: 40)
                                .background(Color(hex: "1A1A1A"))
                                .clipShape(Capsule())
                        }
                    }

                    if let champion {
                        championBlock(champion)
                    }

                    if !isTie {
                        decreeSection
                        if let jester {
                            jesterRow(jester)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 20)

                footer
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Champion

    @ViewBuilder
    private func championBlock(_ champion: Player) -> some View {
        VStack(spacing: 10) {
            Text(isTie ? "It's a tie between everyone up top." : "Your champion of the night is")
                .font(AppTheme.displayMedium(21))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            CrownDropView()
                .frame(width: 90, height: 72)

            Text(champion.name)
                .displayStyle(96)
                .foregroundColor(Color(hex: "FFD60A"))
                .lineLimit(1)
                .minimumScaleFactor(0.4)

            if !isTie {
                Text("CHAOS CHAMPION")
                    .displayStyle(16)
                    .tracking(1)
                    .foregroundColor(.black)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(Color(hex: "FF2E88"))
                    .clipShape(Capsule())
                    .rotationEffect(.degrees(-2))

                Text(statLine(for: champion))
                    .font(AppTheme.interMedium(14))
                    .foregroundColor(Color(hex: "D9D9D9"))
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func statLine(for player: Player) -> String {
        var parts: [String] = []
        if let top = player.topCategory, top.count > 0 {
            parts.append("Won \(top.count) \(top.category.displayName) round\(top.count == 1 ? "" : "s").")
        }
        parts.append(viewModel.totalSkips == 0 ? "Never skipped a card." : "Skipped \(viewModel.totalSkips) card\(viewModel.totalSkips == 1 ? "" : "s").")
        return parts.joined(separator: " ")
    }

    // MARK: - Royal decree

    private var decreeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ROYAL DECREE · PICK ONE FOR THE NIGHT")
                .font(AppTheme.interBold(12))
                .tracking(1.5)
                .foregroundColor(Color(hex: "FFD60A"))

            ForEach(decrees.indices, id: \.self) { index in
                let on = decreeIndex == index
                Button {
                    decreeIndex = index
                    HapticsService.selection()
                } label: {
                    Text(decrees[index])
                        .font(AppTheme.interBold(15))
                        .foregroundColor(on ? .black : .white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .frame(minHeight: 48)
                        .background(on ? Color(hex: "FFD60A") : Color(hex: "111111"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(on ? Color(hex: "FFD60A") : Color(hex: "333333"), lineWidth: 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
    }

    // MARK: - Jester

    private func jesterRow(_ jester: Player) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "theatermasks.fill")
                .font(.system(size: 18))
                .foregroundColor(.black)
                .frame(width: 40, height: 40)
                .background(Color(hex: "2EE6C5"))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text("\(jester.name) is the Jester.")
                    .displayStyle(15)
                    .foregroundColor(.white)
                Text("Last place speaks in a British accent until the next game.")
                    .font(AppTheme.interMedium(13))
                    .foregroundColor(Color(hex: "D9D9D9"))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "111111"))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: 10) {
            Button {
                viewModel.goTo(.setup)
            } label: {
                Text("Play again")
                    .displayStyle(16)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .overlay(Capsule().stroke(Color.white, lineWidth: 2))
            }

            Button {
                viewModel.goTo(.crownCard)
            } label: {
                Text("Get your Crown Card")
                    .displayStyle(17)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color(hex: "FFD60A"))
                    .clipShape(Capsule())
            }
        }
    }
}

// MARK: - Crown drop animation

private struct CrownDropView: View {
    @State private var dropped = false

    var body: some View {
        Image(systemName: "crown.fill")
            .font(.system(size: 52))
            .foregroundColor(Color(hex: "FFD60A"))
            .rotationEffect(.degrees(dropped ? -8 : -35))
            .offset(y: dropped ? 0 : -260)
            .onAppear {
                withAnimation(.interpolatingSpring(stiffness: 180, damping: 14).delay(0.3)) {
                    dropped = true
                }
            }
    }
}

// MARK: - Confetti

private struct ConfettiPieceModel: Identifiable {
    let id = Int.random(in: Int.min...Int.max)
    let x: CGFloat
    let width: CGFloat
    let height: CGFloat
    let corner: CGFloat
    let color: Color
    let duration: Double
    let delay: Double
}

private struct ConfettiFallView: View {
    @State private var fallen = false

    private let colors: [Color] = [
        Color(hex: "FFD60A"), Color(hex: "FF2E88"), Color(hex: "FF5A1F"),
        Color(hex: "2EE6C5"), Color(hex: "8B6BFF"), Color(hex: "C6F432"), .white
    ]

    private var pieces: [ConfettiPieceModel] {
        (0..<34).map { i in
            let b = (i * 53) % 17
            return ConfettiPieceModel(
                x: CGFloat((i * 37) % 100),
                width: CGFloat(6 + (b % 6)),
                height: CGFloat(10 + (b % 9)),
                corner: b % 3 == 0 ? 99 : 2,
                color: colors[i % colors.count],
                duration: 2.2 + Double(b % 7) * 0.25,
                delay: 1.5 + Double(i % 9) * 0.12
            )
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    RoundedRectangle(cornerRadius: piece.corner)
                        .fill(piece.color)
                        .frame(width: piece.width, height: piece.height)
                        .position(x: geo.size.width * piece.x / 100, y: fallen ? geo.size.height + 40 : -30)
                        .opacity(fallen ? 0 : 1)
                        .animation(.easeIn(duration: piece.duration).delay(piece.delay), value: fallen)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { fallen = true }
    }
}

#Preview {
    let vm = GameViewModel()
    vm.addPlayer(name: "Dani")
    vm.addPlayer(name: "Kat")
    vm.addPlayer(name: "Mo")
    vm.players[0].score = 10
    vm.players[0].categoryWins = [.debates: 4]
    vm.players[1].score = 6
    vm.players[2].score = 4
    return CoronationView(viewModel: vm)
}
