//
//  SplashView.swift
//  DazedAmuzed
//
//  Branded launch splash: a short multi-beat reveal (word → paint burst →
//  locked wordmark) ending on a tap-to-start gate, matching the brand's
//  paint-splat motif used throughout the game itself.
//

import SwiftUI

struct SplashView: View {
    /// Called once the viewer taps through and the splash should be dismissed.
    var onFinished: () -> Void

    @State private var wordIn = false
    @State private var wordOut = false
    @State private var splatGrown = false
    @State private var splatVisible = false
    @State private var lockedIn = false
    @State private var tagIn = false
    @State private var tapIn = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()

                let side = min(geo.size.width, geo.size.height)
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

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

                // Beat 3: locked DAZED / & / AMUZED lockup + tagline.
                VStack(spacing: side * 0.012) {
                    Text("DAZED")
                        .font(AppTheme.displayCondensed(side * 0.27))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: lockedIn ? 0 : -side * 0.3)

                    Text("&")
                        .font(AppTheme.display(side * 0.17))
                        .foregroundColor(Color(hex: "FF2E88"))
                        .scaleEffect(lockedIn ? 1 : 1.6)

                    Text("AMUZED")
                        .font(AppTheme.displayCondensed(side * 0.27))
                        .foregroundColor(.white)
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
                    .padding(.top, side * 0.055)
                    .opacity(tagIn ? 1 : 0)
                }
                .padding(.horizontal, side * 0.045)
                .opacity(lockedIn ? 1 : 0)
                .position(center)

                VStack {
                    Spacer()
                    Button(action: onFinished) {
                        HStack {
                            Text("TAP TO START")
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .font(AppTheme.interBold(15))
                        .tracking(2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .overlay(
                            Capsule().stroke(Color.white, lineWidth: 2)
                        )
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, max(geo.safeAreaInsets.bottom, 24))
                }
                .opacity(tapIn ? 1 : 0)
            }
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture {
            if tapIn { onFinished() }
        }
        .onAppear { runSequence() }
    }

    private func runSequence() {
        withAnimation(.easeOut(duration: 0.25)) {
            wordIn = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.easeInOut(duration: 0.3)) {
                wordOut = true
            }
            withAnimation(.timingCurve(0.2, 0.9, 0.25, 1, duration: 0.45)) {
                splatGrown = true
            }
            withAnimation(.easeIn(duration: 0.2).delay(0.05)) {
                splatVisible = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
            withAnimation(.easeOut(duration: 0.25)) {
                splatVisible = false
            }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                lockedIn = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                tagIn = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
            withAnimation(.easeInOut(duration: 0.3)) {
                tapIn = true
            }
        }
    }
}

#Preview {
    SplashView(onFinished: {})
}
