//
//  HighScoreCell.swift
//  PerpetualPolygon
//
//  Created by Chase Bishop on 8/15/16.
//  Copyright © 2016 Lewis. All rights reserved.
//

import Foundation
import UIKit

class HighScoreCell : UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var diffLabel: UILabel!
    
    func configure(name: String, score: String, diff: String) {
        self.nameLabel.text = name
        self.scoreLabel.text = score
        self.diffLabel.text = diff
    }
}