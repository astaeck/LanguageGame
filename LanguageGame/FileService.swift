//
//  FileService.swift
//  LanguageGame
//
//  Created by Angelina Staeck on 11.05.18.
//  Copyright © 2018 Angelina Staeck. All rights reserved.
//

import Foundation

enum FileServiceResult {
    case success([WordPair])
    case error
}

class FileService {
    func getWordPairsFromJSONFile(fileName: String, type: String, completion: @escaping (FileServiceResult) -> Void) {
        if let path = Bundle.main.path(forResource: fileName, ofType: type) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let words = try JSONDecoder().decode([WordPair].self, from: data)
                completion(.success(words))
                
            } catch {
                completion(.error)
            }
        }
    }
}
