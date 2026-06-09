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
    @Published var lastWinner: Player? = nil
    @Published var currentRound: Int = 1
    @Published var vibeMode: VibeMode = .mixed
    
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
        for i in players.indices {
            players[i].score = 0
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
    
    func awardPoint(to player: Player) {
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index].score += 1
        }
    }
    
    // Add this method with the other functions
    func selectCategory(_ category: QuestionCategory) {
        // Clear stale state so an empty category doesn't show the previous question
        currentQuestion = nil
        // Filter questions by category and pick one
        let categoryQuestions = allQuestions.filter { $0.category == category }
        if let question = categoryQuestions.randomElement() {
            currentQuestion = question
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
        selectedPacks = Set(QuestionCategory.availableCases)
    }
}
