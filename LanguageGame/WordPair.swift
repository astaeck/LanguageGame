//
//  WordPair.swift
//  LanguageGame
//
//  Created by Angelina Staeck on 07.05.18.
//  Copyright © 2018 Angelina Staeck. All rights reserved.
//

import Foundation

struct WordPair {
    let englishText: String?
    let spanishText: String?
}

extension WordPair: Decodable {
    enum CodingKeys: String, CodingKey {
        case englishText = "text_eng"
        case spanishText = "text_spa"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        englishText = try values.decodeIfPresent(String.self, forKey: .englishText)
        spanishText = try values.decodeIfPresent(String.self, forKey: .spanishText)
    }
}
