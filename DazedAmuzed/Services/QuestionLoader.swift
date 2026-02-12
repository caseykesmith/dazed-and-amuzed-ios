//
//  QuestionLoader.swift
//  DazedAmuzed
//
//  Created by Peyton Sadler on 2/11/26.
//


import Foundation

class QuestionLoader {
    static func loadQuestions() -> [Question] {
        guard let url = Bundle.main.url(forResource: "Questions", withExtension: "json") else {
            print("❌ Questions.json not found")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(QuestionFile.self, from: data)
            
            // Convert to Question objects with UUIDs
            return decoded.questions.map { item in
                Question(
                    text: item.text,
                    category: QuestionCategory(rawValue: item.category) ?? .debates,
                    vibe: Vibe(rawValue: item.vibe) ?? .party
                )
            }
        } catch {
            print("❌ Error loading questions: \(error)")
            return []
        }
    }
}

// Matches JSON structure
private struct QuestionFile: Codable {
    let questions: [QuestionItem]
}

private struct QuestionItem: Codable {
    let text: String
    let category: String
    let vibe: String
}