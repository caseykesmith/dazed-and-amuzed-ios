//
//  PassPhoneView.swift
//  DazedAmuzed
//
//  Interstitial shown between rounds: hands the phone to the next judge
//  before the deck-select grid appears, so everyone else knows to look away.
//

import SwiftUI

struct PassPhoneView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var shake = false

    private let tint = Color(hex: "FF5A1F")

    var body: some View {
        ZStack {
            tint.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 4) {
                Text("ROUND \(viewModel.roundNumber) · NO PEEKING")
                    .font(AppTheme.interBold(12))
                    .tracking(2)
                    .foregroundColor(.black)

                Spacer()

                Image(systemName: "iphone")
                    .font(.system(size: 60, weight: .regular))
                    .foregroundColor(.black)
                    .padding(.bottom, 10)
                    .rotationEffect(.degrees(shake ? 8 : -8))
                    .offset(x: shake ? 14 : -14)
                    .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: shake)
                    .onAppear { shake = true }

                Text("Pass the phone to")
                    .font(AppTheme.displayMedium(24))
                    .foregroundColor(.black)

                Text(viewModel.currentPlayer?.name ?? "the next judge")
                    .displayStyle(84)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)

                HStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                    Text("You're the Judge this round.")
                        .displayStyle(20)
                        .foregroundColor(.black)
                }
                .padding(.top, 14)

                Text("Everyone else, eyes off the screen.")
                    .font(AppTheme.interMedium(15))
                    .foregroundColor(.black.opacity(0.75))
                    .padding(.top, 4)

                Spacer()
                Spacer()

                Button {
                    HapticsService.light()
                    viewModel.goTo(.gamePlay)
                } label: {
                    Text("I'm \(viewModel.currentPlayer?.name ?? "ready"). Let's go.")
                        .displayStyle(19)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 64)
                        .background(Color.black)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 56)
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    let vm = GameViewModel()
    vm.addPlayer(name: "Mo")
    vm.addPlayer(name: "Dani")
    vm.addPlayer(name: "Kat")
    vm.startGame()
    return PassPhoneView(viewModel: vm)
}
