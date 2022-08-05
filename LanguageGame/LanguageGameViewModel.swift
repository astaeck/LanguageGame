//
//  LanguageGameViewModel.swift
//  LanguageGame
//
//  Created by Angelina Staeck on 07.05.18.
//  Copyright © 2018 Angelina Staeck. All rights reserved.
//

import Foundation

class LanguageGameViewModel {
    
    let roundsToPlay = 3
    let fileService: FileService
    
    private var wordPairs: [WordPair] = [WordPair]() {
        didSet {
            prepareNextGame()
        }
    }
    
    private var randomWordPair: WordPair? {
        didSet {
            self.startGameCallback?(randomWordPair)
        }
    }

    private var randomTranslations = [String?]()
    
    var startGameCallback: ((WordPair?)->())?
    var updateRound: ((Int)->())?
    var updateScore: ((Int, String)->())?
    var gameFinished: ((Int)->())?

    var score: Int = 0 {
        didSet {
            if oldValue > score {
                updateScore?(0, "")
            } else if oldValue < score {
                updateScore?(score, "🎉🎉🎉")
            } else {
                updateScore?(score, "👎🙈")
            }
        }
    }
    
    var roundCount = 0 {
        didSet {
            updateRound?(roundCount)
            if roundCount == roundsToPlay {
                gameFinished?(score)
            } else {
                prepareNextGame()
            }
        }
    }
    
    init(service: FileService = FileService()) {
        self.fileService = service
    }
    
    func resetGame() {
        roundCount = 0
        if score != 0 {
            score = 0
        } else {
            updateScore?(0, "")
        }
    }
    
    func readWordPairsFromFile() {
        self.fileService.getWordPairsFromJSONFile(fileName: "words", type: "json", completion: { [weak self] (result) in
            guard let sself = self else { return }
            
            switch result {
                
            case .success(let words):
                sself.wordPairs = words
                
            case .error:
                print("File could not be parsed")
            }
        })
    }
    
    func getRandomTranslation() -> String? {
        if let translation = randomTranslations.random() {
            return translation
        }
        return nil
    }
    
    func removeRandomTranslation(translation: String) {
        randomTranslations = randomTranslations.filter({ $0 != translation })
    }
    
    func checkAnswer(isCorrect: Bool, text: String) {
        if isCorrect == true && randomWordPair?.spanishText == text ||
            isCorrect == false && randomWordPair?.spanishText != text {
                score += 1
        } else {
            score += 0
        }
        checkRound()
    }
    
    func checkRound() {
        if randomTranslations.count > 0 {
            startGameCallback?(randomWordPair)
            return
        }
        roundCount += 1
    }
    
    func prepareNextGame() {
        let wordPairToTranslate = wordPairs.random()
        let filteredWordPairs = wordPairs.filter({ $0.englishText != wordPairToTranslate.englishText })
        var possibleTanslations = filteredWordPairs.createRandom(withCount: 2).map { return $0.spanishText }
        possibleTanslations.append(wordPairToTranslate.spanishText)
        randomTranslations = possibleTanslations
        randomWordPair = wordPairToTranslate
    }
}

extension Array {
    func random() -> Element {
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
    
    func createRandom(withCount count: Int) -> [Element] {
        var randomArray = [Element]()
        for _ in 0..<count {
            randomArray.append(self[Int(arc4random_uniform(UInt32(self.count)))])
        }
        return randomArray
    }
}
