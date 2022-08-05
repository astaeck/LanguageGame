//
//  LanguageGameTests.swift
//  LanguageGameTests
//
//  Created by Angelina Staeck on 07.05.18.
//  Copyright © 2018 Angelina Staeck. All rights reserved.
//

import XCTest
@testable import LanguageGame

class LanguageGameTests: XCTestCase {
   
    var gameViewModel: LanguageGameViewModel!
    var wordPairs = [WordPair(englishText: "rainfall", spanishText: "precipitación"),
                     WordPair(englishText: "forest floor", spanishText: "suelo del bosque"),
                     WordPair(englishText: "swamp", spanishText: "zona pantanosa")]
    
    override func setUp() {
        super.setUp()
        let fileService = MockFileService()
        fileService.fileServiceResult = .success(wordPairs)
        gameViewModel = LanguageGameViewModel(service: fileService)
        gameViewModel.readWordPairsFromFile()
    }
    
    override func tearDown() {
        super.tearDown()
        gameViewModel = nil
    }
    
    func testRoundCount() {
        gameViewModel.prepareNextGame()
        gameViewModel.removeRandomTranslation(translation: gameViewModel.getRandomTranslation() ?? "")
        gameViewModel.checkRound()
        XCTAssertEqual(gameViewModel.roundCount, 0)
        
        gameViewModel.removeRandomTranslation(translation: gameViewModel.getRandomTranslation() ?? "")
        gameViewModel.removeRandomTranslation(translation: gameViewModel.getRandomTranslation() ?? "")
        gameViewModel.checkRound()
        XCTAssertEqual(gameViewModel.roundCount, 1)
    }
    
    func testScoreCount() {
        gameViewModel.prepareNextGame()
        gameViewModel.checkAnswer(isCorrect: true, text: "rainfall")
        XCTAssertEqual(gameViewModel.score, 0)
        
        gameViewModel.checkAnswer(isCorrect: true, text: "precipitación")
        gameViewModel.checkAnswer(isCorrect: true, text: "suelo del bosque")
        gameViewModel.checkAnswer(isCorrect: true, text: "zona pantanosa")
        XCTAssertEqual(gameViewModel.score, 1)
        
        gameViewModel.checkAnswer(isCorrect: false, text: "precipitación")
        gameViewModel.checkAnswer(isCorrect: false, text: "suelo del bosque")
        gameViewModel.checkAnswer(isCorrect: false, text: "zona pantanosa")
        XCTAssertEqual(gameViewModel.score, 3)
    }
    
}
private final class MockFileService: FileService {
    var fileServiceResult: FileServiceResult?

    override func getWordPairsFromJSONFile(fileName: String, type: String, completion: @escaping (FileServiceResult) -> Void) {
        completion(fileServiceResult!)
    }
}
