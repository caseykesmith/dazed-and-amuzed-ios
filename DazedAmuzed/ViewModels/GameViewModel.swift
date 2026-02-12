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
    @Published var playMode: PlayMode = .local
    @Published var vibe: Vibe = .mixed
    @Published var players: [Player] = []
    @Published var currentPlayerIndex: Int = 0
    @Published var currentQuestion: Question?
    @Published var usedQuestionIDs: Set<UUID> = []
    @Published var roundNumber: Int = 1
    @Published var settings: GameSettings = GameSettings()
    
    // MARK: - Questions
    private var allQuestions: [Question] = []
    
    // MARK: - Selected Packs
    @Published var selectedPacks: Set<QuestionCategory> = Set(QuestionCategory.allCases)
    
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
        usedQuestionIDs = []
        roundNumber = 1
        currentPlayerIndex = 0
        players = players.map { Player(name: $0.name, score: 0, emoji: $0.emoji) }
        nextQuestion()
        screen = .gamePlay
    }
    
    func nextQuestion() {
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
        } else {
            // All questions used, reset
            usedQuestionIDs = []
            nextQuestion()
        }
    }
    
    func nextTurn() {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        if currentPlayerIndex == 0 {
            roundNumber += 1
        }
        nextQuestion()
    }
    
    func awardPoint(to player: Player) {
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index].score += 1
        }
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
        vibe = .mixed
        selectedPacks = Set(QuestionCategory.allCases)
    }
}
