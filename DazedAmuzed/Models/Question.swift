//
//  Question.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import Foundation
import SwiftUI

struct Question: Identifiable, Codable, Hashable {
    let id: UUID
    let text: String
    let category: QuestionCategory
    let vibe: Vibe
    
    init(id: UUID = UUID(), text: String, category: QuestionCategory, vibe: Vibe) {
        self.id = id
        self.text = text
        self.category = category
        self.vibe = vibe
    }
}

enum QuestionCategory: String, Codable, CaseIterable {
    case debates
    case stories
    case reflection
    case wouldYouRather
    case exposed
    case drinkIf
    case musicTrivia
    case reunion
    case bachelorette
    case couplesNight
    case afterDark
    case firstDate

    var displayName: String {
        switch self {
        case .debates: return "Debate"
        case .stories: return "Spill"
        case .reflection: return "Unfiltered"
        case .wouldYouRather: return "Would You Rather"
        case .exposed: return "Exposed"
        case .drinkIf: return "Drink If"
        case .musicTrivia: return "Music Trivia"
        case .reunion: return "Reunion"
        case .bachelorette: return "Bachelorette"
        case .couplesNight: return "Couples Night"
        case .afterDark: return "After Dark"
        case .firstDate: return "First Date"
        }
    }

    var icon: String {
        switch self {
        case .debates: return "🔥"
        case .stories: return "💬"
        case .reflection: return "🪞"
        case .wouldYouRather: return "⚖️"
        case .exposed: return "🫣"
        case .drinkIf: return "🍻"
        case .musicTrivia: return "🎵"
        case .reunion: return "🎓"
        case .bachelorette: return "💍"
        case .couplesNight: return "💕"
        case .afterDark: return "🌶️"
        case .firstDate: return "🥰"
        }
    }

    /// Decks that aren't available yet. Shown as "Coming Soon" and disabled.
    var isComingSoon: Bool {
        switch self {
        case .musicTrivia, .reunion, .bachelorette, .couplesNight, .afterDark, .firstDate:
            return true
        default:
            return false
        }
    }

    /// Categories that are currently playable (excludes "Coming Soon" decks).
    static var availableCases: [QuestionCategory] {
        allCases.filter { !$0.isComingSoon }
    }

    var color: Color {
        switch self {
        case .debates: return Color(hex: "FF6B35")
        case .wouldYouRather: return Color(hex: "FF2D78")
        case .stories: return Color(hex: "7B68EE")
        case .reflection: return Color(hex: "9ACD32")
        case .exposed: return Color(hex: "FFD700")
        case .drinkIf: return Color(hex: "20B2AA")
        case .musicTrivia: return Color(hex: "1DB954")
        case .reunion: return Color(hex: "FF6B35")
        case .bachelorette: return Color(hex: "FF69B4")
        case .couplesNight: return Color(hex: "E91E63")
        case .afterDark: return Color(hex: "8B0000")
        case .firstDate: return Color(hex: "FF6B9D")
        }
    }
}

enum Vibe: String, Codable, CaseIterable {
    case party
    case deep
    case mixed
    
    var displayName: String {
        switch self {
        case .party: return "Party Mode"
        case .deep: return "Deep Mode"
        case .mixed: return "Mix It Up"
        }
    }
}