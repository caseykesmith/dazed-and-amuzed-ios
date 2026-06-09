//
//  DazedAmuzedApp.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//

import SwiftUI

@main
struct DazedAmuzedApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()

                if showSplash {
                    SplashView {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
        }
    }
}
