//
//  Question.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import Foundation

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
    
    var displayName: String {
        switch self {
        case .debates: return "Debates"
        case .stories: return "Stories"
        case .reflection: return "Reflection"
        case .wouldYouRather: return "Would You Rather"
        case .exposed: return "Exposed"
        case .drinkIf: return "Confess"
        }
    }
    
    var icon: String {
        switch self {
        case .debates: return "🔥"
        case .stories: return "💬"
        case .reflection: return "🪞"
        case .wouldYouRather: return "⚖️"
        case .exposed: return "👀"
        case .drinkIf: return "🫣"
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