//
//  GamePlayView.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import SwiftUI

struct GamePlayView: View {
    @ObservedObject var viewModel: GameViewModel
    @StateObject private var store = StoreKitService.shared
    @State private var showVibeSwitch = false
    @State private var showRules = false

    // Paint-splat reveal state
    @State private var revealOpen: Bool
    @State private var splatPhase: Bool
    @State private var cardPhase: Bool
    @State private var splatOrigin: CGPoint
    @State private var splatColor: Color
    @State private var skipPulse = false
    @State private var cardNumber = 1

    // Speaking timer
    @State private var timerRunning = false
    @State private var timerSecondsLeft = 30
    @State private var timerSpeakerIndex = 0
    @State private var timerTask: Task<Void, Never>?

    let baseCategories: [QuestionCategory] = [
        .debates, .wouldYouRather, .stories, .reflection, .exposed, .drinkIf
    ]

    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
        // Returning to this screen (e.g. "Back" from Pick a Winner) with a question
        // still active should show the card immediately — set that up in the state's
        // own initial values so the very first render is already correct, rather than
        // flashing the bare deck grid for a frame and fixing it up in .onAppear.
        let question = viewModel.currentQuestion
        _revealOpen = State(initialValue: question != nil)
        _splatPhase = State(initialValue: question != nil)
        _cardPhase = State(initialValue: question != nil)
        _splatColor = State(initialValue: question?.category.color ?? AppTheme.pink)
        _splatOrigin = State(initialValue: CGPoint(x: 195, y: 420))
    }

    var purchasedExtensionPacks: [QuestionCategory] {
        let packs: [(QuestionCategory, String)] = [
            (.musicTrivia, StoreKitService.musicTrivia),
            (.reunion, StoreKitService.reunion),
            (.bachelorette, StoreKitService.bachelorette),
            (.couplesNight, StoreKitService.couplesNight),
            (.afterDark, StoreKitService.afterDark),
            (.firstDate, StoreKitService.firstDate),
        ]
        return packs.filter { store.hasAccess(to: $0.1) }.map { $0.0 }
    }

    var allCategories: [QuestionCategory] {
        // "Coming Soon" decks are never playable, even if a premium/test purchase grants access.
        (baseCategories + purchasedExtensionPacks).filter { !$0.isComingSoon }
    }

    var leaderID: UUID? {
        guard let top = viewModel.players.max(by: { $0.score < $1.score }), top.score > 0 else { return nil }
        return top.id
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                header
                metaRow
                judgeHeadline

                deckGrid
                    .frame(maxHeight: .infinity)

                playerRow
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 20)
            .coordinateSpace(name: "board")

            if revealOpen, let question = viewModel.currentQuestion {
                revealOverlay(question: question)
            }
        }
        .sheet(isPresented: $showVibeSwitch) {
            VibeSwitchSheet(viewModel: viewModel)
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showRules) {
            RulesSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("\(Text("DAZED").foregroundColor(AppTheme.purple)) & \(Text("AMUZED").foregroundColor(AppTheme.pink))")
                .foregroundColor(.white)
                .displayStyle(17)

            Spacer()

            Button {
                viewModel.goTo(.results)
            } label: {
                Text("End game")
                    .font(AppTheme.interBold(13))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .frame(minHeight: 44)
                    .background(Color(hex: "1A1A1A"))
                    .clipShape(Capsule())
            }
        }
    }

    private var metaRow: some View {
        HStack(spacing: 14) {
            Button {
                showVibeSwitch = true
            } label: {
                HStack(spacing: 4) {
                    Text(vibeEmoji)
                    Text(vibeTitle)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9))
                }
                .font(AppTheme.interMedium(12))
                .foregroundColor(Color(hex: "9CA3AF"))
            }

            Button {
                showRules = true
            } label: {
                HStack(spacing: 4) {
                    Text("📖")
                    Text("Rules")
                }
                .font(AppTheme.interMedium(12))
                .foregroundColor(Color(hex: "9CA3AF"))
            }

            Spacer()
        }
    }

    private var judgeHeadline: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "FFD60A"))
                Text("ROUND \(viewModel.roundNumber) · THE JUDGE")
                    .font(AppTheme.interBold(13))
                    .tracking(2)
                    .foregroundColor(Color(hex: "FFD60A"))
            }

            Text("\(viewModel.currentPlayer?.name ?? "Judge"), your call.")
                .displayStyle(44)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text("Tap a deck. Make it hurt.")
                .font(AppTheme.interMedium(15))
                .foregroundColor(Color(hex: "B3B3B3"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Deck grid

    private var deckGrid: some View {
        let rows = stride(from: 0, to: allCategories.count, by: 2).map {
            Array(allCategories[$0..<min($0 + 2, allCategories.count)])
        }
        return Grid(horizontalSpacing: 12, verticalSpacing: 12) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                GridRow {
                    ForEach(Array(row.enumerated()), id: \.element) { i, category in
                        let index = allCategories.firstIndex(of: category) ?? i
                        deckTile(category: category, index: index)
                    }
                    if row.count == 1 {
                        Color.clear
                    }
                }
            }
        }
    }

    private func deckTile(category: QuestionCategory, index: Int) -> some View {
        GeometryReader { geo in
            Button {
                let frame = geo.frame(in: .named("board"))
                splatOrigin = CGPoint(x: frame.midX, y: frame.midY)
                splatColor = category.color
                viewModel.selectCategory(category)
                HapticsService.light()
                openReveal()
            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    Text(String(format: "%02d", index + 1))
                        .displayStyle(14)
                        .opacity(0.55)

                    Spacer(minLength: 6)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.displayName)
                            .displayStyle(26)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)
                        Text(category.tagline)
                            .font(AppTheme.interMedium(12))
                            .lineLimit(2)
                    }
                }
                .foregroundColor(.black)
                .padding(14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(category.color)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .buttonStyle(TileButtonStyle())
        }
        .frame(minHeight: 120)
    }

    // MARK: - Player row

    private var playerRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.players) { player in
                    let isLeader = player.id == leaderID
                    HStack(spacing: 6) {
                        Text(player.name)
                            .font(AppTheme.interBold(14))
                            .lineLimit(1)
                        Text("\(player.score)")
                            .font(AppTheme.display(18))
                    }
                    .foregroundColor(isLeader ? .black : .white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(isLeader ? Color.white : Color(hex: "1A1A1A"))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .fixedSize()
                    .overlay(alignment: .topLeading) {
                        if isLeader {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "FFD60A"))
                                .offset(x: 8, y: -10)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Reveal overlay

    private func revealOverlay(question: Question) -> some View {
        let category = question.category
        let categoryIndex = (allCategories.firstIndex(of: category) ?? 0) + 1

        return ZStack {
            PaintSplatView(color: splatColor, origin: splatOrigin, phase: splatPhase)

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Button {
                        closeReveal()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Back to decks")

                    Spacer()

                    Text("CORE · CARD \(cardNumber)")
                        .font(AppTheme.interBold(12))
                        .tracking(2)
                        .foregroundColor(.black)
                }

                Text(category.displayName)
                    .displayStyle(52)
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)

                ZStack {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(Color.black.opacity(0.25))
                        .offset(x: 6, y: 6)

                    VStack(alignment: .leading, spacing: 18) {
                        Text("\(String(format: "%02d", categoryIndex)) · \(category.displayName.uppercased())")
                            .displayStyle(13)
                            .tracking(1.5)
                            .foregroundColor(category.color)

                        Text(question.text)
                            .font(AppTheme.display(28))
                            .foregroundColor(.white)
                            .lineLimit(6)
                            .minimumScaleFactor(0.7)
                            .scaleEffect(skipPulse ? 0.97 : 1)

                        Rectangle()
                            .fill(Color(hex: "333333"))
                            .frame(height: 1)

                        Text(category.rule)
                            .font(AppTheme.interMedium(13))
                            .foregroundColor(Color(hex: "C8C8C8"))
                    }
                    .padding(22)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                }
                .rotationEffect(.degrees(-2))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                timerBlock(category: category)

                GeometryReader { geo in
                    let gap: CGFloat = 10
                    let skipWidth = (geo.size.width - gap) / 3
                    let winWidth = geo.size.width - gap - skipWidth

                    HStack(spacing: gap) {
                        Button {
                            skip()
                        } label: {
                            Text("Skip")
                                .displayStyle(16)
                                .foregroundColor(.black)
                                .frame(width: skipWidth, height: 56)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 999)
                                        .stroke(Color.black, lineWidth: 3)
                                )
                        }

                        Button {
                            pickWinner()
                        } label: {
                            Text("Pick a winner")
                                .displayStyle(16)
                                .foregroundColor(.white)
                                .frame(width: winWidth, height: 56)
                                .background(Color.black)
                                .clipShape(Capsule())
                        }
                    }
                }
                .frame(height: 56)
            }
            .padding(.horizontal, 20)
            .padding(.top, 56)
            .padding(.bottom, 24)
            .opacity(cardPhase ? 1 : 0)
            .offset(y: cardPhase ? 0 : 30)
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func timerBlock(category: QuestionCategory) -> some View {
        if timerRunning {
            VStack(spacing: 10) {
                HStack {
                    Text(timerSecondsLeft > 0 ? "\(speakerName(at: timerSpeakerIndex))'s turn" : "Time's up, \(speakerName(at: timerSpeakerIndex))!")
                        .displayStyle(17)
                        .foregroundColor(.white)
                    Spacer()
                    Text(String(format: "0:%02d", timerSecondsLeft))
                        .font(AppTheme.display(24))
                        .foregroundColor(category.color)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(hex: "333333"))
                        Capsule()
                            .fill(category.color)
                            .frame(width: geo.size.width * CGFloat(timerSecondsLeft) / CGFloat(max(viewModel.settings.timerSeconds, 1)))
                    }
                }
                .frame(height: 8)

                HStack(spacing: 8) {
                    Button(action: advanceSpeaker) {
                        Text("Next: \(speakerName(at: timerSpeakerIndex + 1))")
                            .displayStyle(14)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(category.color)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .frame(maxWidth: .infinity)

                    Button(action: stopTimerAction) {
                        Text("Timer off")
                            .font(AppTheme.interBold(13))
                            .foregroundColor(.white)
                            .frame(minHeight: 44)
                            .padding(.horizontal, 14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color(hex: "555555"), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(14)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        } else {
            Button(action: startTimer) {
                HStack(spacing: 8) {
                    Image(systemName: "timer")
                    Text("Time each answer · \(viewModel.settings.timerSeconds)s")
                }
                .font(AppTheme.interBold(14))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, minHeight: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.black, lineWidth: 2)
                )
            }
        }
    }

    // MARK: - Actions

    private func openReveal() {
        revealOpen = true
        splatPhase = false
        cardPhase = false
        cardNumber = 1
        stopTimerAction()
        withAnimation(.timingCurve(0.2, 0.9, 0.25, 1, duration: 0.7)) {
            splatPhase = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.72).delay(0.4)) {
            cardPhase = true
        }
    }

    private func closeReveal() {
        stopTimerAction()
        withAnimation(.easeInOut(duration: 0.2)) {
            cardPhase = false
            splatPhase = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            revealOpen = false
        }
    }

    private func skip() {
        viewModel.skipQuestion()
        HapticsService.light()
        cardNumber += 1
        withAnimation(.easeOut(duration: 0.08)) {
            skipPulse = true
        }
        withAnimation(.easeOut(duration: 0.18).delay(0.08)) {
            skipPulse = false
        }
    }

    private func pickWinner() {
        HapticsService.medium()
        viewModel.goTo(.pickWinner)
    }

    // MARK: - Speaking timer

    private func speakerName(at index: Int) -> String {
        guard !viewModel.players.isEmpty else { return "Player" }
        let i = ((index % viewModel.players.count) + viewModel.players.count) % viewModel.players.count
        return viewModel.players[i].name
    }

    private func startTimer() {
        guard !viewModel.players.isEmpty else { return }
        timerSpeakerIndex = 0
        timerSecondsLeft = viewModel.settings.timerSeconds
        timerRunning = true
        HapticsService.light()
        runTimerLoop()
    }

    private func advanceSpeaker() {
        guard !viewModel.players.isEmpty else { return }
        timerSpeakerIndex += 1
        timerSecondsLeft = viewModel.settings.timerSeconds
        HapticsService.light()
        runTimerLoop()
    }

    private func stopTimerAction() {
        timerRunning = false
        timerTask?.cancel()
        timerTask = nil
    }

    private func runTimerLoop() {
        timerTask?.cancel()
        timerTask = Task { @MainActor in
            while timerRunning && timerSecondsLeft > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled, timerRunning else { return }
                timerSecondsLeft = max(0, timerSecondsLeft - 1)
            }
        }
    }

    var vibeEmoji: String {
        switch viewModel.vibe {
        case .party: return "🎉"
        case .deep: return "🌙"
        case .mixed: return "✨"
        }
    }

    var vibeTitle: String {
        switch viewModel.vibe {
        case .party: return "Party Mode"
        case .deep: return "Go Deep"
        case .mixed: return "Best of Both"
        }
    }
}

// MARK: - Tile press style

struct TileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Paint splat

private let splatCircles: [(CGFloat, CGFloat, CGFloat)] = [
    (40, 60, 13), (272, 56, 9), (284, 252, 15), (28, 262, 8), (150, 292, 7), (156, 12, 6)
]

private let splat2Circles: [(CGFloat, CGFloat, CGFloat)] = [
    (20, 140, 10), (282, 120, 12), (70, 22, 7), (236, 290, 9), (10, 40, 5), (292, 20, 6)
]

struct BlobPaintShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 300
        let sy = rect.height / 300
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }
        var p = Path()
        p.move(to: pt(150, 42))
        p.addCurve(to: pt(236, 84), control1: pt(190, 40), control2: pt(214, 70))
        p.addCurve(to: pt(258, 160), control1: pt(262, 100), control2: pt(268, 136))
        p.addCurve(to: pt(250, 230), control1: pt(250, 184), control2: pt(266, 206))
        p.addCurve(to: pt(172, 262), control1: pt(232, 256), control2: pt(196, 252))
        p.addCurve(to: pt(96, 250), control1: pt(146, 272), control2: pt(118, 266))
        p.addCurve(to: pt(46, 188), control1: pt(72, 232), control2: pt(44, 220))
        p.addCurve(to: pt(52, 108), control1: pt(48, 160), control2: pt(34, 132))
        p.addCurve(to: pt(150, 42), control1: pt(72, 82), control2: pt(110, 44))
        p.closeSubpath()
        return p
    }
}

struct SplatLayer: View {
    let color: Color
    let circles: [(CGFloat, CGFloat, CGFloat)]
    var includeBlob: Bool = true

    var body: some View {
        ZStack {
            if includeBlob {
                BlobPaintShape().fill(color)
            }
            ForEach(circles.indices, id: \.self) { i in
                let c = circles[i]
                Circle()
                    .fill(color)
                    .frame(width: c.2 * 2, height: c.2 * 2)
                    .position(x: c.0, y: c.1)
            }
        }
        .frame(width: 300, height: 300)
    }
}

struct PaintSplatView: View {
    let color: Color
    let origin: CGPoint
    let phase: Bool

    var body: some View {
        ZStack {
            SplatLayer(color: color, circles: splat2Circles, includeBlob: false)
                .scaleEffect(phase ? 1.6 : 0)
                .rotationEffect(.degrees(phase ? 0 : 30))
                .animation(.timingCurve(0.2, 0.9, 0.25, 1, duration: 0.9).delay(0.08), value: phase)

            SplatLayer(color: color, circles: splatCircles, includeBlob: true)
                .scaleEffect(phase ? 7 : 0)
                .rotationEffect(.degrees(phase ? 10 : -25))
                .animation(.timingCurve(0.2, 0.9, 0.25, 1, duration: 0.7), value: phase)
        }
        .position(origin)
        .allowsHitTesting(false)
    }
}

// MARK: - Vibe Switch Sheet

struct VibeSwitchSheet: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Switch Vibe")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.text)
                    .padding(.top, 24)

                VStack(spacing: 12) {
                    VibeOptionRow(emoji: "🎉", title: "Party Mode", isSelected: viewModel.vibe == .party) {
                        viewModel.vibe = .party
                        dismiss()
                    }
                    VibeOptionRow(emoji: "🌙", title: "Go Deep", isSelected: viewModel.vibe == .deep) {
                        viewModel.vibe = .deep
                        dismiss()
                    }
                    VibeOptionRow(emoji: "✨", title: "Best of Both", isSelected: viewModel.vibe == .mixed) {
                        viewModel.vibe = .mixed
                        dismiss()
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }
}

struct VibeOptionRow: View {
    let emoji: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(emoji)
                    .font(.system(size: 24))
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.text)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.purple)
                }
            }
            .padding(16)
            .background(AppTheme.card)
            .cornerRadius(12)
        }
    }
}

// MARK: - Rules Sheet

struct RulesSheet: View {
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("📖 How to Play")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.text)
                    .padding(.top, 24)

                VStack(alignment: .leading, spacing: 16) {
                    RuleRow(number: "1", text: "The **Judge** picks a card type")
                    RuleRow(number: "2", text: "Everyone else answers or debates")
                    RuleRow(number: "3", text: "Judge picks their favorite")
                    RuleRow(number: "4", text: "Winner gets a point")
                    RuleRow(number: "5", text: "First to target score wins!")
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }
}

struct RuleRow: View {
    let number: String
    let text: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(number)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(AppTheme.purple)
                .cornerRadius(14)

            Text(.init(text))
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(AppTheme.text)
        }
    }
}

#Preview {
    let vm = GameViewModel()
    vm.addPlayer(name: "P")
    vm.addPlayer(name: "C")
    vm.addPlayer(name: "Dani")
    vm.startGame()
    return GamePlayView(viewModel: vm)
}
