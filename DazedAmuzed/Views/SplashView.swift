//
//  SplashView.swift
//  DazedAmuzed
//
//  Branded launch splash: logo mark + wordmark on near-black, with a
//  brief entrance animation, then hands off to the main app.
//

import SwiftUI

struct SplashView: View {
    /// Called once the splash has finished animating and should be dismissed.
    var onFinished: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Image("LogoMark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160, height: 160)

                // Wordmark — mirrors the home screen: DAZED orange, AMUZED pink.
                VStack(spacing: 0) {
                    Text("DAZED")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "FFB24D"), Color(hex: "FF6A00")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("&")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.textDim)
                        .padding(.vertical, 2)

                    Text("AMUZED")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "FF5C9E"), Color(hex: "FF1E74")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
            .scaleEffect(appeared ? 1.0 : 0.85)
            .opacity(appeared ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                appeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                onFinished()
            }
        }
    }
}

#Preview {
    SplashView(onFinished: {})
}
