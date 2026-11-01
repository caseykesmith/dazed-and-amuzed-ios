//
//  PickWinnerView.swift
//  DazedAmuzed
//
//  Created by PJ on 3/29/26.
//


import SwiftUI

struct PickWinnerView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var winner: Player?
    @State private var preRoundLeaderID: UUID?
    @State private var showCrownStolen = false

    private var category: QuestionCategory? { viewModel.currentQuestion?.category }

    /// Everyone except the judge — the judge doesn't award themselves the point.
    private var contenders: [Player] {
        viewModel.players.filter { $0.id != viewModel.currentPlayer?.id }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Button {
                        viewModel.goTo(.gamePlay)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color(hex: "1A1A1A"))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Back")
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("ROUND \(viewModel.roundNumber)\(category.map { " · \($0.displayName.uppercased())" } ?? "")")
                        .font(AppTheme.interBold(12))
                        .tracking(2)
                        .foregroundColor(category?.color ?? AppTheme.pink)

                    Text("\(viewModel.currentPlayer?.name ?? "Judge"), who won?")
                        .displayStyle(42)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)

                    Text("Tap the best answer. No take-backs.")
                        .font(AppTheme.interMedium(15))
                        .foregroundColor(Color(hex: "BFBFBF"))
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(contenders) { player in
                            playerRow(player)
                        }
                    }
                }

                infoRow

                if let winner {
                    footerMessage(for: winner)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 20)

            if showCrownStolen, let winner {
                crownStolenOverlay(winner: winner)
            }
        }
        .onAppear {
            preRoundLeaderID = leaderID()
        }
    }

    // MARK: - Rows

    private func playerRow(_ player: Player) -> some View {
        let isWinner = winner?.id == player.id
        let tint = category?.color ?? AppTheme.pink
        return Button {
            selectWinner(player)
        } label: {
            HStack {
                HStack(spacing: 10) {
                    Text(player.name)
                        .displayStyle(34)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    if player.id == leaderID() {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "FFD60A"))
                    }
                }
                Spacer()
                HStack(spacing: 8) {
                    Text("\(player.score)")
                        .displayStyle(34)
                    if isWinner {
                        Text("+1")
                            .displayStyle(18)
                    }
                }
            }
            .foregroundColor(isWinner ? .black : .white)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: 92)
            .background(isWinner ? tint : Color(hex: "111111"))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(isWinner ? tint : Color(hex: "333333"), lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .disabled(winner != nil)
    }

    private var infoRow: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "FFD60A"))
                Text("\(viewModel.currentPlayer?.name ?? "Judge") is judging this round")
                    .font(AppTheme.interBold(13))
                    .foregroundColor(Color(hex: "BFBFBF"))
            }
            Spacer()
            Text("\(viewModel.currentPlayer?.score ?? 0)")
                .displayStyle(17)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: "111111"))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private func footerMessage(for winner: Player) -> some View {
        if !showCrownStolen {
            VStack(spacing: 14) {
                if leaderID() == winner.id {
                    Text("\(winner.name) keeps the crown.")
                        .displayStyle(19)
                        .foregroundColor(Color(hex: "FFD60A"))
                }

                HStack(spacing: 10) {
                    Button(action: undo) {
                        Text("Undo")
                            .displayStyle(16)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 58)
                            .overlay(
                                RoundedRectangle(cornerRadius: 999)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }

                    Button(action: advance) {
                        Text("Next round")
                            .displayStyle(17)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, minHeight: 58)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private func crownStolenOverlay(winner: Player) -> some View {
        let runnerUp = viewModel.players.first(where: { $0.id == preRoundLeaderID })
        let tint = category?.color ?? AppTheme.pink

        return VStack(spacing: 14) {
            Spacer(minLength: 20)

            Image(systemName: "crown.fill")
                .font(.system(size: 64))
                .foregroundColor(.black)

            Text("CROWN\nSTOLEN")
                .displayStyle(58)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .lineSpacing(-10)

            if let runnerUp {
                Text("\(winner.name) takes the lead, \(liveScore(for: winner)) to \(runnerUp.score).")
                    .displayStyle(20)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                Text("Sorry, \(runnerUp.name).")
                    .font(AppTheme.interMedium(15))
                    .foregroundColor(.black)
            }

            Spacer(minLength: 20)

            HStack(spacing: 10) {
                Button(action: undo) {
                    Text("Undo")
                        .displayStyle(16)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 58)
                        .overlay(
                            RoundedRectangle(cornerRadius: 999)
                                .stroke(Color.black, lineWidth: 3)
                        )
                }

                Button(action: advance) {
                    Text("Next round")
                        .displayStyle(17)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 58)
                        .background(Color.black)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 70)
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(tint)
        .ignoresSafeArea()
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }

    // MARK: - Actions

    private func selectWinner(_ player: Player) {
        guard winner == nil else { return }
        HapticsService.success()
        viewModel.awardPoint(to: player, category: category)
        winner = player

        let newLeader = leaderID()
        if newLeader == player.id, let pre = preRoundLeaderID, pre != player.id {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                showCrownStolen = true
            }
        }
    }

    private func undo() {
        guard let w = winner else { return }
        viewModel.undoPoint(from: w, category: category)
        winner = nil
        withAnimation {
            showCrownStolen = false
        }
    }

    private func advance() {
        guard let w = winner else { return }
        // `winner` is a value-type snapshot taken at the moment of the tap, so its
        // .score is stale by exactly the point just awarded — always re-read the
        // live score from the view model rather than trusting the local copy.
        let newScore = liveScore(for: w)
        // Clear the resolved question so returning to the deck-select screen
        // shows a fresh grid instead of silently reopening this round's card.
        viewModel.currentQuestion = nil

        if let target = viewModel.settings.gameLength.targetScore, newScore >= target {
            viewModel.goTo(.results)
        } else {
            viewModel.nextTurn()
            viewModel.goTo(.passPhone)
        }
    }

    private func leaderID() -> UUID? {
        let maxScore = viewModel.players.map(\.score).max() ?? 0
        guard maxScore > 0 else { return nil }
        let top = viewModel.players.filter { $0.score == maxScore }
        return top.count == 1 ? top.first?.id : nil
    }

    /// `Player` is a value type, so a `Player` captured earlier (like `winner`)
    /// doesn't reflect points awarded since — look its current score up live.
    private func liveScore(for player: Player) -> Int {
        viewModel.players.first(where: { $0.id == player.id })?.score ?? player.score
    }
}

#Preview {
    let vm = GameViewModel()
    vm.addPlayer(name: "Dani")
    vm.addPlayer(name: "Kat")
    vm.addPlayer(name: "Mo")
    vm.startGame()
    return PickWinnerView(viewModel: vm)
}
