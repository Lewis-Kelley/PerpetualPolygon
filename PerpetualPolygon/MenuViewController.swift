//
//  MenuViewController.swift
//  PerpetualPolygon
//
//  Created by Lewis on 8/5/16.
//  Copyright © 2016 Lewis. All rights reserved.
//

import UIKit
import CoreData

class MenuViewController: UIViewController {
    let SHOW_OPTIONS_SEGUE = "MainToOptions"
    let SHOW_GAME_SEGUE = "MainToGame"
    let SHOW_SCORES_SEGUE = "MenuToScores"
    let MAX_DIFF = 4
    let FONT_SIZE: CGFloat = IPAD ? 40.0 : 20.0
    let TITLE_FONT_SIZE: CGFloat = IPAD ? 68.0 : 34.0
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var hScoresBt: UIButton!
    @IBOutlet weak var optsBt: UIButton!
    @IBOutlet weak var diffUpBt: UIButton!
    @IBOutlet weak var diffDownBt: UIButton!
    @IBOutlet weak var playBt: UIButton!
    
    var managedObjectContext: NSManagedObjectContext?
    var diff: Int = 0 //0 = easiest, MAX_DIFF = hardest
    static var diffForScores = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        if IPAD {
            titleLbl.font = titleLbl.font.fontWithSize(TITLE_FONT_SIZE)
            
            let stdFont = hScoresBt.titleLabel?.font.fontWithSize(FONT_SIZE)
            hScoresBt.titleLabel?.font = stdFont
            optsBt.titleLabel?.font = stdFont
            diffUpBt.titleLabel?.font = stdFont
            diffDownBt.titleLabel?.font = stdFont
            playBt.titleLabel?.font = stdFont
        }
        
        playBt.setTitle("Level \(diff): GO!", forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.identifier == SHOW_OPTIONS_SEGUE {
            (segue.destinationViewController as! OptionsViewController).managedObjectContext = managedObjectContext
        } else if segue.identifier == SHOW_GAME_SEGUE {
            let gameVC = segue.destinationViewController as! GameViewController
            gameVC.colors = OptionsViewController.getColors(managedObjectContext, delegate: nil)
            gameVC.diff = diff
        } else if segue.identifier == SHOW_SCORES_SEGUE {
            print("Moving to scores")
            (segue.destinationViewController as! HighscoreViewController).managedObjectContext = managedObjectContext

        }
    }

    @IBAction func adjDiff(sender: AnyObject) {
        diff += sender.tag
        
        if diff < 0 {
            diff = 0
        } else if diff > MAX_DIFF {
            diff = MAX_DIFF
        } else {
            playBt.setTitle("Level \(diff): GO!", forState: .Normal)
        }
    }
}
