//
//  Highscore.swift
//  PerpetualPolygon
//
//  Created by Chase Bishop on 8/8/16.
//  Copyright © 2016 Lewis. All rights reserved.
//

import Foundation

class Highscore {
    
    var key : String?
    var playerName : String
    var score : String
    
    init(score: String, playerName: String, key: String) {
        self.key = key
        self.playerName = playerName
        self.score = score
    }
}