//
//  HomeView.swift
//  DazedAmuzed
//
//  The Welcome screen — rebuilt to match the artifact's current design:
//  a rotating "Tonight gets {word}." headline, a scrolling category
//  ticker, then the two entry points into Setup.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showPlayApartComingSoon = false
    @State private var showDecksComingSoon = false
    @State private var startDate = Date()

    private let rotatingWords = ["messy.", "loud.", "petty.", "real.", "spicy."]
    private let wordInterval: TimeInterval = 1.7

    private let tickerItems: [(name: String, color: Color)] = [
        ("Debate", Color(hex: "FF5A1F")),
        ("Would You Rather", Color(hex: "FF2E88")),
        ("Spill", Color(hex: "8B6BFF")),
        ("Unfiltered", Color(hex: "C6F432")),
        ("Most Likely To", Color(hex: "FFD60A")),
        ("Guilty", Color(hex: "2EE6C5"))
    ]

    // Matches the artifact's spec: 116px on a 390px-wide reference screen.
    private let headlineSize: CGFloat = 108

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: Header
                HStack {
                    Text("DAZED \(Text("&").foregroundColor(Color(hex: "FF2E88"))) AMUZED")
                        .foregroundColor(.white)
                        .font(AppTheme.displayCondensed(24))
                        .tracking(AppTheme.displayTracking(for: 24))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button {
                        HapticsService.light()
                        showDecksComingSoon = true
                    } label: {
                        HStack(spacing: 6) {
                            Text("DECKS")
                            Image(systemName: "arrow.right")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .font(AppTheme.interBold(12))
                        .tracking(2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .frame(minHeight: 40)
                        .overlay(Capsule().stroke(Color(hex: "333333"), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // MARK: Headline
                VStack(alignment: .leading, spacing: 0) {
                    // Matches the artifact's line-height: 0.84 — SwiftUI's
                    // per-Text line height is looser than that, so pull the
                    // three lines together with negative spacing here.
                    VStack(alignment: .leading, spacing: -headlineSize * 0.28) {
                        Text("Tonight")
                            .heroCondensedStyle(headlineSize)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Text("gets")
                            .heroCondensedStyle(headlineSize)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)

                        TimelineView(.periodic(from: startDate, by: wordInterval)) { timeline in
                            let elapsed = timeline.date.timeIntervalSince(startDate)
                            let index = max(0, Int(elapsed / wordInterval)) % rotatingWords.count

                            Text(rotatingWords[index])
                                .heroCondensedStyle(headlineSize)
                                .foregroundColor(Color(hex: "FF2E88"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .id(index)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .move(edge: .top).combined(with: .opacity)
                                ))
                                .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.4), value: index)
                        }
                        .frame(height: headlineSize * 0.84, alignment: .leading)
                        .clipped()
                    }

                    Text("One phone. Real questions about the people in the room. Say it out loud.")
                        .font(AppTheme.interMedium(16))
                        .foregroundColor(Color(hex: "BFBFBF"))
                        .lineLimit(3)
                        .frame(maxWidth: 320, alignment: .leading)
                        .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

                // MARK: Ticker
                MarqueeTicker(items: tickerItems)
                    .frame(height: 44)
                    .padding(.vertical, 14)
                    .overlay(Rectangle().fill(Color(hex: "222222")).frame(height: 1), alignment: .top)
                    .overlay(Rectangle().fill(Color(hex: "222222")).frame(height: 1), alignment: .bottom)
                    .padding(.bottom, 20)

                // MARK: Buttons
                VStack(spacing: 10) {
                    Button {
                        viewModel.goTo(.setup)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Play together")
                                    .font(AppTheme.display(20))
                                    .tracking(AppTheme.displayTracking(for: 20))
                                Text("One phone. Pass it around.")
                                    .font(AppTheme.interMedium(13))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 22)
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }

                    Button {
                        HapticsService.light()
                        showPlayApartComingSoon = true
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 8) {
                                    Text("Play apart")
                                        .displayStyle(20)
                                    Text("NEW")
                                        .font(AppTheme.interBold(10))
                                        .tracking(1)
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color(hex: "FF2E88"))
                                        .clipShape(Capsule())
                                }
                                Text("Friends join with a code. No app needed.")
                                    .font(AppTheme.interMedium(13))
                                    .foregroundColor(Color(hex: "D9D9D9"))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white, lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .alert("Play Apart is coming soon", isPresented: $showPlayApartComingSoon) {
            Button("Got it", role: .cancel) {}
        } message: {
            Text("Remote play with a join code isn't ready yet — for now, play together on one phone.")
        }
        .alert("More decks are coming soon", isPresented: $showDecksComingSoon) {
            Button("Got it", role: .cancel) {}
        } message: {
            Text("The pack store isn't ready yet — for now, all six core decks are included free.")
        }
    }
}

private extension Text {
    func displayCondensedStyle(_ size: CGFloat) -> Text {
        self.font(AppTheme.displayCondensed(size)).tracking(AppTheme.displayTracking(for: size))
    }

    /// The artifact's hero headline treatment: uppercase, with the much
    /// lighter -0.02em tracking it specifies (not the app-wide -0.055em
    /// `displayTracking`, which crushes letterforms at this size).
    func heroCondensedStyle(_ size: CGFloat) -> some View {
        self.font(AppTheme.displayCondensed(size))
            .tracking(-size * 0.02)
            .textCase(.uppercase)
    }
}

// MARK: - Marquee ticker

private struct MarqueeTicker: View {
    let items: [(name: String, color: Color)]

    @State private var offset: CGFloat = 0
    @State private var setWidth: CGFloat = 0

    var body: some View {
        HStack(spacing: 0) {
            row
            row
        }
        .fixedSize(horizontal: true, vertical: false)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        setWidth = geo.size.width / 2
                        startAnimating()
                    }
            }
        )
        .offset(x: offset)
        // minWidth: 0 is required: without it the flexible frame adopts the
        // fixed-size marquee's full width (~1300pt), which widens Home's whole
        // VStack past the screen and pushes edge-aligned content off-screen.
        .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .clipped()
    }

    private var row: some View {
        HStack(spacing: 26) {
            ForEach(items.indices, id: \.self) { i in
                HStack(spacing: 10) {
                    Circle()
                        .fill(items[i].color)
                        .frame(width: 10, height: 10)
                    Text(items[i].name)
                        .displayCondensedStyle(24)
                        .foregroundColor(.white)
                        .fixedSize()
                }
            }
        }
        .padding(.trailing, 26)
    }

    private func startAnimating() {
        guard setWidth > 0 else { return }
        offset = 0
        withAnimation(.linear(duration: 16).repeatForever(autoreverses: false)) {
            offset = -setWidth
        }
    }
}

#Preview {
    HomeView(viewModel: GameViewModel())
}
