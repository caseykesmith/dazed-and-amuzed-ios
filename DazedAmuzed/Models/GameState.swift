//
//  GameState.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//

import Foundation

enum PlayMode: String, Codable {
    case local      // In person, pass the phone
    case video      // Video call, everyone on own phone
}

enum GameScreen {
    case home
    case playMode
    case vibeSelect
    case packSelect
    case addPlayers
    case gamePlay
    case judgeTurn
    case results
}

struct GameSettings: Codable {
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var drinkingMode: Bool = false
    var timerSeconds: Int = 60
}
