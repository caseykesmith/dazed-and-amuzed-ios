//
//  GameViewModel.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import SwiftUI
import Combine

@MainActor
class GameViewModel: ObservableObject {
    // MARK: - Published State
    @Published var screen: GameScreen = .home
    @Published var vibe: Vibe = .mixed
    @Published var players: [Player] = []
    @Published var currentPlayerIndex: Int = 0
    @Published var currentQuestion: Question?
    @Published var usedQuestionIDs: Set<UUID> = []
    @Published var roundNumber: Int = 1
    @Published var settings: GameSettings = GameSettings()
    /// Cards skipped this game — shown as a stat on the Coronation/Crown Card screens.
    @Published var totalSkips: Int = 0
    
    // MARK: - Questions
    private var allQuestions: [Question] = []
    
    // MARK: - Selected Packs
    @Published var selectedPacks: Set<QuestionCategory> = Set(QuestionCategory.availableCases)
    
    // MARK: - Init
    init() {
        loadQuestions()
    }
    
    private func loadQuestions() {
        allQuestions = QuestionLoader.loadQuestions()
        print("✅ Loaded \(allQuestions.count) questions")
    }
    
    // MARK: - Player Management
    func addPlayer(name: String) {
        let emojis = ["😎", "🔥", "💀", "👑", "🎯", "⚡️", "🌙", "💜"]
        let emoji = emojis[players.count % emojis.count]
        let player = Player(name: name, emoji: emoji)
        players.append(player)
    }
    
    func removePlayer(at index: Int) {
        guard index < players.count else { return }
        players.remove(at: index)
    }
    
    var currentPlayer: Player? {
        guard !players.isEmpty, currentPlayerIndex < players.count else { return nil }
        return players[currentPlayerIndex]
    }
    
    // MARK: - Game Flow
    func startGame() {
        screen = .gamePlay
        currentPlayerIndex = 0
        roundNumber = 1
        usedQuestionIDs = []
        totalSkips = 0
        for i in players.indices {
            players[i].score = 0
            players[i].categoryWins = [:]
        }
    }
    
    func nextQuestion() {
        // Safety check - make sure we have questions
        guard !allQuestions.isEmpty else {
            print("❌ No questions loaded!")
            return
        }
        
        let availableQuestions = allQuestions.filter { question in
            // Filter by selected packs
            guard selectedPacks.contains(question.category) else { return false }
            // Filter by vibe
            if vibe != .mixed && question.vibe != vibe { return false }
            // Filter out used questions
            return !usedQuestionIDs.contains(question.id)
        }
        
        if let question = availableQuestions.randomElement() {
            currentQuestion = question
            usedQuestionIDs.insert(question.id)
        } else if !usedQuestionIDs.isEmpty {
            // All questions used, reset and try once more
            usedQuestionIDs = []
            if let question = allQuestions.filter({ selectedPacks.contains($0.category) }).randomElement() {
                currentQuestion = question
                usedQuestionIDs.insert(question.id)
            }
        }
    }
    
    func nextTurn() {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        if currentPlayerIndex == 0 {
            roundNumber += 1
        }
  
    }
    
    func awardPoint(to player: Player, category: QuestionCategory? = nil) {
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index].score += 1
            if let category {
                players[index].categoryWins[category, default: 0] += 1
            }
        }
    }

    func undoPoint(from player: Player, category: QuestionCategory? = nil) {
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index].score = max(0, players[index].score - 1)
            if let category, let wins = players[index].categoryWins[category] {
                players[index].categoryWins[category] = max(0, wins - 1)
            }
        }
    }
    
    // Add this method with the other functions
    func selectCategory(_ category: QuestionCategory) {
        // Clear stale state so an empty category doesn't show the previous question
        currentQuestion = nil
        if let question = pickQuestion(in: category) {
            currentQuestion = question
            usedQuestionIDs.insert(question.id)
        }
    }

    /// Picks another question in the *same* category as the one on screen —
    /// used by the "Skip" control on the question card.
    func skipQuestion() {
        guard let category = currentQuestion?.category else { return }
        totalSkips += 1
        if let question = pickQuestion(in: category) {
            currentQuestion = question
            usedQuestionIDs.insert(question.id)
        }
    }

    private func pickQuestion(in category: QuestionCategory) -> Question? {
        let candidates = allQuestions.filter { question in
            guard question.category == category else { return false }
            if vibe != .mixed && question.vibe != vibe { return false }
            return !usedQuestionIDs.contains(question.id)
        }
        if let question = candidates.randomElement() {
            return question
        }
        // Every question in this category/vibe has been used — allow repeats
        // rather than coming up empty.
        return allQuestions.filter { question in
            question.category == category && (vibe == .mixed || question.vibe == vibe)
        }.randomElement()
    }
    
    // MARK: - Navigation
    func goTo(_ screen: GameScreen) {
        self.screen = screen
    }
    
    func resetGame() {
        screen = .home
        players = []
        currentPlayerIndex = 0
        currentQuestion = nil
        usedQuestionIDs = []
        roundNumber = 1
        totalSkips = 0
        vibe = .mixed
        selectedPacks = Set(QuestionCategory.availableCases)
    }
}
