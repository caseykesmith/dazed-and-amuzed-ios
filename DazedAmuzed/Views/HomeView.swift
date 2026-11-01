//
//  HomeView.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var bob = false
    @State private var showPlayApartComingSoon = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                floatingCards
                    .padding(.top, 20)

                VStack(alignment: .leading, spacing: -30) {
                    Text("DAZED")
                        .foregroundColor(Color(hex: "FF7A1A"))
                    (Text("&").foregroundColor(.white) + Text("AMUZED").foregroundColor(Color(hex: "FF2E88")))
                }
                .displayStyle(100)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.top, 8)

                Text("The party game that reads the room.")
                    .font(AppTheme.displayMedium(20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                VStack(spacing: 10) {
                    Button {
                        viewModel.goTo(.setup)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Play together")
                                    .displayStyle(20)
                                Text("One phone. Say it out loud.")
                                    .font(AppTheme.interMedium(13))
                            }
                            Spacer()
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
                                        .background(Color(hex: "2EE6C5"))
                                        .clipShape(Capsule())
                                }
                                Text("Friends join with a code. No app needed.")
                                    .font(AppTheme.interMedium(13))
                                    .foregroundColor(Color(hex: "D9D9D9"))
                            }
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(hex: "2EE6C5"))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                        .background(Color(hex: "111111"))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color(hex: "2EE6C5"), lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 36)

                Spacer(minLength: 20)
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                bob = true
            }
        }
        .alert("Play Apart is coming soon", isPresented: $showPlayApartComingSoon) {
            Button("Got it", role: .cancel) {}
        } message: {
            Text("Remote play with a join code isn't ready yet — for now, play together on one phone.")
        }
    }

    private var floatingCards: some View {
        ZStack {
            FloatingQuestionCard(
                label: "DEBATE",
                text: "Splitting the bill when you only had a salad?",
                color: Color(hex: "FF5A1F"),
                width: 170, height: 230
            )
            .rotationEffect(.degrees(bob ? -14 : -12))
            .offset(y: bob ? -8 : 0)
            .position(x: 103, y: 155)

            FloatingQuestionCard(
                label: "MOST LIKELY TO",
                text: "Most likely to text their ex tonight.",
                color: Color(hex: "FFD60A"),
                width: 170, height: 230
            )
            .rotationEffect(.degrees(bob ? 16 : 14))
            .offset(y: bob ? -6 : 0)
            .position(x: 291, y: 165)

            FloatingQuestionCard(
                label: "WOULD YOU RATHER",
                text: "Your camera roll goes public, or your search history?",
                color: Color(hex: "FF2E88"),
                width: 180, height: 250
            )
            .shadow(color: .black.opacity(0.6), radius: 20, y: 12)
            .rotationEffect(.degrees(bob ? 4 : 1))
            .offset(y: bob ? -12 : 0)
            .position(x: 190, y: 145)
        }
        .frame(height: 300)
    }
}

// MARK: - Floating question card

private struct FloatingQuestionCard: View {
    let label: String
    let text: String
    let color: Color
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(AppTheme.interBold(11))
                .tracking(1.5)
            Spacer()
            Text(text)
                .font(AppTheme.display(19))
                .lineLimit(4)
                .minimumScaleFactor(0.65)
        }
        .foregroundColor(.black)
        .padding(16)
        .frame(width: width, height: height, alignment: .topLeading)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

#Preview {
    HomeView(viewModel: GameViewModel())
}
