//
//  ExtensionPack.swift
//  DazedAmuzed
//
//  Created by PJ on 4/14/26.
//


import SwiftUI

struct ExtensionPack: Identifiable {
    let id: String
    let name: String
    let emoji: String
    let description: String
    let color: Color
    let productID: String
    let questionCount: Int
    var isComingSoon: Bool = false

    static let allPacks: [ExtensionPack] = [
        ExtensionPack(
            id: "musictrivia",
            name: "Music Trivia",
            emoji: "🎵",
            description: "Test your music knowledge with hits from every decade",
            color: Color(hex: "1DB954"),
            productID: StoreKitService.musicTrivia,
            questionCount: 150,
            isComingSoon: true
        ),
        ExtensionPack(
            id: "reunion",
            name: "Reunion",
            emoji: "🎓",
            description: "Perfect for catching up with old friends",
            color: Color(hex: "FF6B35"),
            productID: StoreKitService.reunion,
            questionCount: 120,
            isComingSoon: true
        ),
        ExtensionPack(
            id: "bachelorette",
            name: "Bachelorette",
            emoji: "💍",
            description: "Spice up the bride's last night out",
            color: Color(hex: "FF69B4"),
            productID: StoreKitService.bachelorette,
            questionCount: 100,
            isComingSoon: true
        ),
        ExtensionPack(
            id: "couplesnight",
            name: "Couples Night",
            emoji: "💕",
            description: "Fun questions for date night with friends",
            color: Color(hex: "E91E63"),
            productID: StoreKitService.couplesNight,
            questionCount: 100,
            isComingSoon: true
        ),
        ExtensionPack(
            id: "afterdark",
            name: "After Dark",
            emoji: "🌶️",
            description: "Things get spicy after midnight",
            color: Color(hex: "8B0000"),
            productID: StoreKitService.afterDark,
            questionCount: 150,
            isComingSoon: true
        ),
        ExtensionPack(
            id: "firstdate",
            name: "First Date",
            emoji: "🥰",
            description: "Break the ice and get to know each other",
            color: Color(hex: "FF6B9D"),
            productID: StoreKitService.firstDate,
            questionCount: 80,
            isComingSoon: true
        )
    ]
}
