//
//  GameState.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//

import Foundation

enum PlayMode: String, Codable {
    case local
    case video
}

enum GameScreen: Codable {
    case home
    case playMode
    case vibeSelect
    case packSelect
    case addPlayers
    case gamePlay
    case judgeTurn
    case pickWinner
    case giveSips
    case results
}

enum GameLength: String, CaseIterable, Codable {
    case quick = "Quick"
    case classic = "Classic"
    case endless = "Endless"
    
    var targetScore: Int? {
        switch self {
        case .quick: return 5
        case .classic: return 10
        case .endless: return nil
        }
    }
    
    var subtitle: String {
        switch self {
        case .quick: return "5 points"
        case .classic: return "10 points"
        case .endless: return "No limit"
        }
    }
}

struct GameSettings: Codable {
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var drinkingMode: Bool = false
    var timerSeconds: Int = 30
    var gameLength: GameLength = .classic
}
