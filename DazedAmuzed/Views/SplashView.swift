//
//  SplashView.swift
//  DazedAmuzed
//
//  First-launch sequence: a short multi-beat brand reveal (word → paint
//  burst → locked wordmark, filling the screen edge-to-edge) that flows
//  straight into a run of flashed hype taglines, then lands on Home —
//  fully automatic, no tap required.
//

import SwiftUI

struct SplashView: View {
    /// Called once the sequence finishes and should hand off to the app.
    var onFinished: () -> Void

    // Brand reveal
    @State private var wordIn = false
    @State private var wordOut = false
    @State private var splatGrown = false
    @State private var splatVisible = false
    @State private var lockedIn = false
    @State private var tagIn = false
    @State private var brandVisible = true

    // Tagline flash
    @State private var taglinePhase = false
    @State private var taglineIndex = 0
    @State private var taglineVisible = false

    private let taglines = [
        "Tonight gets spicy.",
        "Tonight gets messy.",
        "Tonight gets real loud.",
        "Tonight gets honest.",
        "Tonight gets unforgettable."
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()

                let side = min(geo.size.width, geo.size.height)
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

                brandReveal(side: side, center: center)
                    .opacity(brandVisible ? 1 : 0)

                if taglinePhase {
                    taglineFlash(side: side)
                        .transition(.opacity)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { runSequence() }
    }

    // MARK: - Brand reveal

    @ViewBuilder
    private func brandReveal(side: CGFloat, center: CGPoint) -> some View {
        // Beat 1: "DAZED" alone, centered.
        Text("DAZED")
            .font(AppTheme.displayCondensed(side * 0.4))
            .foregroundColor(.white)
            .opacity(wordIn && !wordOut ? 1 : 0)
            .scaleEffect(wordOut ? 1.08 : (wordIn ? 1 : 0.9))
            .position(center)

        // Beat 2: paint burst + giant ampersand.
        ZStack {
            BlobPaintShape()
                .fill(Color(hex: "FF2E88"))
                .frame(width: 300, height: 300)
                .scaleEffect(splatGrown ? 13 : 0)
                .rotationEffect(.degrees(splatGrown ? 0 : -20))

            Text("&")
                .font(AppTheme.display(side * 1.05))
                .foregroundColor(.black)
                .scaleEffect(splatGrown ? 1 : 1.25)
                .offset(y: -side * 0.03)
        }
        .opacity(splatVisible ? 1 : 0)
        .position(center)

        // Beat 3: locked DAZED / & / AMUZED lockup, sized edge-to-edge.
        VStack(spacing: side * 0.01) {
            Text("DAZED")
                .displayCondensedStyle(side * 0.52)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(x: lockedIn ? 0 : -side * 0.3)

            Text("&")
                .font(AppTheme.display(side * 0.2))
                .foregroundColor(Color(hex: "FF2E88"))
                .scaleEffect(lockedIn ? 1 : 1.6)

            Text("AMUZED")
                .displayCondensedStyle(side * 0.52)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .offset(x: lockedIn ? 0 : side * 0.3)

            HStack {
                Text("THE PARTY GAME")
                Spacer()
                Text("THAT READS THE ROOM")
            }
            .font(AppTheme.interBold(11))
            .tracking(2)
            .foregroundColor(Color(hex: "BFBFBF"))
            .padding(.top, side * 0.06)
            .opacity(tagIn ? 1 : 0)
        }
        .padding(.horizontal, side * 0.04)
        .opacity(lockedIn ? 1 : 0)
        .position(center)
    }

    // MARK: - Tagline flash

    private func taglineFlash(side: CGFloat) -> some View {
        Text(taglines[taglineIndex])
            .displayCondensedStyle(side * 0.13)
            .foregroundColor(flashColors[taglineIndex % flashColors.count])
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, side * 0.1)
            .opacity(taglineVisible ? 1 : 0)
            .scaleEffect(taglineVisible ? 1 : 0.85)
    }

    private let flashColors: [Color] = [
        Color(hex: "FF5A1F"), Color(hex: "FF2E88"), Color(hex: "8B6BFF"),
        Color(hex: "C6F432"), Color(hex: "FFD60A")
    ]

    // MARK: - Sequencing

    private func runSequence() {
        withAnimation(.easeOut(duration: 0.25)) {
            wordIn = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.easeInOut(duration: 0.3)) { wordOut = true }
            withAnimation(.timingCurve(0.2, 0.9, 0.25, 1, duration: 0.45)) { splatGrown = true }
            withAnimation(.easeIn(duration: 0.2).delay(0.05)) { splatVisible = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
            withAnimation(.easeOut(duration: 0.25)) { splatVisible = false }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) { lockedIn = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeInOut(duration: 0.3)) { tagIn = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) { brandVisible = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                taglinePhase = true
                runTaglines()
            }
        }
    }

    private func runTaglines() {
        showTagline(at: 0)
    }

    private func showTagline(at index: Int) {
        guard index < taglines.count else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onFinished()
            }
            return
        }
        taglineIndex = index
        taglineVisible = false
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            taglineVisible = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.easeIn(duration: 0.15)) {
                taglineVisible = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                showTagline(at: index + 1)
            }
        }
    }
}

private extension Text {
    func displayCondensedStyle(_ size: CGFloat) -> Text {
        self.font(AppTheme.displayCondensed(size)).tracking(AppTheme.displayTracking(for: size))
    }
}

#Preview {
    SplashView(onFinished: {})
}
