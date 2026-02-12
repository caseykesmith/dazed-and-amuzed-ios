//
//  Theme.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//

import SwiftUI

struct AppTheme {
    // MARK: - Colors
    static let background = Color(hex: "0f0f1a")
    static let card = Color(hex: "1a1a2e")
    static let cardElevated = Color(hex: "252542")
    
    static let purple = Color(hex: "a855f7")
    static let pink = Color(hex: "ec4899")
    static let cyan = Color(hex: "06b6d4")
    static let orange = Color(hex: "f97316")
    static let green = Color(hex: "22c55e")
    static let yellow = Color(hex: "facc15")
    
    static let text = Color.white
    static let textMuted = Color(hex: "9ca3af")
    static let textDim = Color(hex: "6b7280")
    static let border = Color(hex: "374151")
    
    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [purple, pink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let partyGradient = LinearGradient(
        colors: [orange, pink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let deepGradient = LinearGradient(
        colors: [purple, cyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Typography
    static let titleFont = Font.system(size: 32, weight: .heavy, design: .rounded)
    static let headlineFont = Font.system(size: 24, weight: .bold, design: .rounded)
    static let bodyFont = Font.system(size: 16, weight: .medium, design: .rounded)
    static let captionFont = Font.system(size: 12, weight: .medium, design: .rounded)
    
    // MARK: - Spacing
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24
    static let cornerRadius: CGFloat = 16
    static let cornerRadiusLarge: CGFloat = 24
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
