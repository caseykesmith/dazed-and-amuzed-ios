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
    /// Rounds won per category this game — powers the Coronation/Crown Card stats.
    var categoryWins: [QuestionCategory: Int] = [:]

    init(id: UUID = UUID(), name: String, score: Int = 0, emoji: String = "😎") {
        self.id = id
        self.name = name
        self.score = score
        self.emoji = emoji
    }

    /// The category this player has won the most, if any.
    var topCategory: (category: QuestionCategory, count: Int)? {
        categoryWins.max { $0.value < $1.value }.map { ($0.key, $0.value) }
    }
}