//
//  Highscore.swift
//  PerpetualPolygon
//
//  Created by Chase Bishop on 8/8/16.
//  Copyright © 2016 Lewis. All rights reserved.
//

import Foundation
import Firebase

class Highscore {
    
    var key : String?
    var playerName : String
    var score : String
    var difficulty : String
    
    init(score: String, playerName: String, difficulty: String) {
        self.playerName = playerName
        self.score = score
        self.difficulty = difficulty
    }
    
    init(snapshot: FIRDataSnapshot) {
        self.key = snapshot.key
        self.playerName = snapshot.valueForKey("player") as! String
        self.score = snapshot.valueForKey("score") as! String
        self.difficulty = snapshot.valueForKey("difficulty") as! String
    }
    
    func getSnapshotValue() -> NSDictionary {
        return ["player": self.playerName, "score": self.score, "difficulty": self.difficulty]
    }
}