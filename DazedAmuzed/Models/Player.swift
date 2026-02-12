//
//  Player.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import Foundation

struct Player: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var score: Int
    var emoji: String
    
    init(id: UUID = UUID(), name: String, score: Int = 0, emoji: String = "😎") {
        self.id = id
        self.name = name
        self.score = score
        self.emoji = emoji
    }
}