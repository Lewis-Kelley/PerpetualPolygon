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
import CoreData

class HighscoreViewController : UITableViewController {
    let SHOW_MENU_SEGUE = "ScoresToMain"
    
    let scoreCellIdentifier = "HighScoreCell"
    var highScores = [Highscore]()
    var highScoresToShow = [Highscore]()
    var managedObjectContext: NSManagedObjectContext?
    let highscoreRef = FIRDatabase.database().reference().child("highscores")
    var filter = 0
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.highScoresToShow.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(scoreCellIdentifier)
        cell?.textLabel?.text = highScoresToShow[indexPath.row].score
        cell?.detailTextLabel?.text = highScoresToShow[indexPath.row].playerName
        return cell!
    }
    
    @IBAction func difficultyButtonPressed(sender: AnyObject) {
        let alertController = UIAlertController(title: "\(self.diffCalc()) Difficutly", message: "", preferredStyle: .ActionSheet)
     
        let difficutlyUpAction = UIAlertAction(title: "Difficulty Up", style: .Default) { (UIAlertAction) in
            if self.filter < 4 {
                self.filter += 1
            }
            alertController.title = "\(self.diffCalc()) Difficulty"
            self.makeHighscoreArray()
            self.tableView.reloadData()
        }
        alertController.addAction(difficutlyUpAction)
        
        let difficutlyDownAction = UIAlertAction(title: "Difficulty Down", style: .Default) { (UIAlertAction) in
            if self.filter > 0 {
                self.filter -= 1
            }
            alertController.title = "\(self.diffCalc()) Difficutly"
            self.makeHighscoreArray()
            self.tableView.reloadData()
        }
        alertController.addAction(difficutlyDownAction)
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { (UIAlertAction) in
            self.makeHighscoreArray()
            self.tableView.reloadData()
        }
        alertController.addAction(okAction)
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (UIAlertAction) in
            return
        }
        alertController.addAction(cancel)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        highscoreRef.removeAllObservers()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        self.highScores.removeAll()
        prepareObservers()
        self.makeHighscoreArray()
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.makeHighscoreArray()
        self.tableView.reloadData()
    }
    
    func makeHighscoreArray() {
        self.highScoresToShow.removeAll()
        for highscore in self.highScores {
            if highscore.difficulty == self.diffCalc() || self.diffCalc() == "All" {
                self.highScoresToShow.append(highscore)
            }
        }
    }
    
    func prepareObservers() {
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

    }
    
    func diffCalc() -> String {
        if filter == 0 {
            return "All"
        } else if filter == 1 {
            return "Easy"
        } else if filter == 2 {
            return "Medium"
        } else if filter == 3 {
            return "Hard"
        } else {
            return "Very Hard"
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == SHOW_MENU_SEGUE {
            (segue.destinationViewController as! MenuViewController).managedObjectContext = managedObjectContext
        }
    }
}