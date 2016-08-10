//
//  HighscoreViewController.swift
//  PerpetualPolygon
//
//  Created by Chase Bishop on 8/8/16.
//  Copyright © 2016 Lewis. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class HighscoreViewController : UITableViewController {
    
    let scoreCellIdentifier = "HighScoreCell"
    var highScores = [Highscore]()
    let highscoreRef = FIRDatabase.database().reference().child("highscores")
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.highScores.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(scoreCellIdentifier)
        cell?.textLabel?.text = highScores[indexPath.row].score
        cell?.detailTextLabel?.text = highScores[indexPath.row].playerName
        return cell!
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        highscoreRef.removeAllObservers()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        self.highScores.removeAll()
        
        // Add observer for CHILD ADDED
        self.highscoreRef.observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot) in
            if !snapshot.exists() {
                print("Something went wrong CHILD ADDED")
                return
            }
            let newHighscore = Highscore(snapshot: snapshot)
            self.highScores.insert(newHighscore, atIndex: 0)
            self.tableView.reloadData()
        }
        
        // Add observer for CHILD CHANGED
        self.highscoreRef.observeEventType(FIRDataEventType.ChildChanged) { (snapshot: FIRDataSnapshot) in
            if !snapshot.exists() {
                print("Something went wrong CHILD CHANGED")
                return
            }
            
            let modifiedHighscore = Highscore(snapshot: snapshot)
            for existingHighscore in self.highScores {
                if existingHighscore.key! == modifiedHighscore.key! {
                    existingHighscore.playerName = modifiedHighscore.playerName
                    existingHighscore.score = modifiedHighscore.score
                    existingHighscore.difficulty = modifiedHighscore.difficulty
                    break
                }
            }
            self.tableView.reloadData()
        }
        
        // Add observer for CHILD REMOVED
        self.highscoreRef.observeEventType(FIRDataEventType.ChildRemoved) { (snapshot: FIRDataSnapshot) in
            if !snapshot.exists() {
                print("Something went wrong CHILD REMOVED")
                return
            }
            
            let deletedHighscore = Highscore(snapshot: snapshot)
            var indexToRemove = 0
            for existingHighscore in self.highScores {
                if existingHighscore.key! == deletedHighscore.key! {
                    self.highScores.removeAtIndex(indexToRemove)
                    break
                }
                indexToRemove += 1
            }
            
            if self.highScores.count == 0 {
                self.tableView.reloadData()
                self.setEditing(false, animated: true)
            }
        }
        self.tableView.reloadData()
    }
}