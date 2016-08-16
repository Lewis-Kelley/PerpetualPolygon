//
//  OptionsViewController.swift
//  PerpetualPolygon
//
//  Created by Lewis on 8/5/16.
//  Copyright © 2016 Lewis. All rights reserved.
//

import UIKit
import CoreData

class OptionsViewController: UIViewController, NSFetchedResultsControllerDelegate {
    let POINTS_TAG = 0
    let PLATFORM_TAG = 1
    let BACKGD_TAG = 2
    let SHAPE_TAG = 3
    let FONT_SIZE: CGFloat = IPAD ? 40.0 : 20.0
    
    static let TEXT_COLOR_CUTOFF: Float = 0.30
    
    let SHOW_MENU_SEGUE = "OptionsToMain"
    
    @IBOutlet weak var pointsBt: UIButton!
    @IBOutlet weak var platformBt: UIButton!
    @IBOutlet weak var backgdBt: UIButton!
    @IBOutlet weak var shapeBt: UIButton!

    @IBOutlet weak var colorVw: UIView!
    
    @IBOutlet weak var red: UISlider!
    @IBOutlet weak var green: UISlider!
    @IBOutlet weak var blue: UISlider!
    
    @IBOutlet weak var redLbl: UILabel!
    @IBOutlet weak var greenLbl: UILabel!
    @IBOutlet weak var blueLbl: UILabel!

    var colors: Colors!
    var managedObjectContext: NSManagedObjectContext?
    var curTag = 0
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        _fetchedResultsController = OptionsViewController.getFRC(managedObjectContext!, delegate: self, forColors: true)
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    static func getFRC(moc: NSManagedObjectContext, delegate: OptionsViewController?, forColors: Bool) -> NSFetchedResultsController {
        let fetchReq = NSFetchRequest(entityName: forColors ? "Colors" : "Score")
        fetchReq.sortDescriptors = [NSSortDescriptor(key: forColors ? "pointsR" : "difficulty", ascending: false)] //Pointless, but necessary
        
        let frc = NSFetchedResultsController(fetchRequest: fetchReq, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: "Master")
        
        frc.delegate = delegate == nil ? OptionsViewController() : delegate
        try! frc.performFetch()
        return frc
    }
    
    static func getColors(moc: NSManagedObjectContext?, delegate: OptionsViewController?) -> Colors {
        let frc = getFRC(moc!, delegate: delegate, forColors: true)
        var colors: Colors
        
        if frc.sections![0].numberOfObjects == 0 { // First time starting up
            colors = NSEntityDescription.insertNewObjectForEntityForName("Colors", inManagedObjectContext: moc!) as! Colors
            
            colors.pointsR = 1.0
            colors.platformG = 1.0
            colors.backgdB = 1.0
            
            try! moc!.save()
        } else {
            colors = frc.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! Colors
        }
        
        return colors
    }
    
    static func colorDist(color: UIColor) -> Float {
        let colors = CGColorGetComponents(color.CGColor)
        return sqrt(Float(colors[0] * colors[0] + colors[1] * colors[1] + colors[2] * colors[2]))
    }
    
    static func getHighScore(moc: NSManagedObjectContext?, delegate: OptionsViewController?, diff: Difficulty) -> Int {
        let frc = getFRC(moc!, delegate: delegate, forColors: false)
        var score: Int
        
        if frc.sections![0].numberOfObjects == 0 { //First time starting up
            for diff in Difficulty.Easy.rawValue...Difficulty.Impossible.rawValue {
                print("Making new score for diff \(diff)")
                let score = NSEntityDescription.insertNewObjectForEntityForName("Score", inManagedObjectContext: moc!) as! Score
                score.difficulty = diff
                score.score = 0
                
                try! moc!.save()
            }
            score = 0
        } else {
            score = (frc.objectAtIndexPath(NSIndexPath(forRow: diff.rawValue - 1, inSection: 0)) as! Score).score as! Int
        }
        
        return score
    }
    
    static func saveHighScore(moc: NSManagedObjectContext?, delegate: OptionsViewController?, diff: Difficulty, score: Int) {
        let frc = getFRC(moc!, delegate: delegate, forColors: false)
        (frc.objectAtIndexPath(NSIndexPath(forRow: diff.rawValue - 1, inSection: 0)) as! Score).score = score
        try! moc!.save()
        
        print("Score saved to array with \(frc.sections![0].numberOfObjects)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        colors = OptionsViewController.getColors(managedObjectContext!, delegate: self)
        
        for tag in 1...3 {
            updateButton(tag, fromCD: true)
        }
        
        curTag = 0
        pressedBt(nil)
        
        let stdFont = pointsBt.titleLabel?.font.fontWithSize(FONT_SIZE)
        pointsBt.titleLabel?.font = stdFont
        platformBt.titleLabel?.font = stdFont
        backgdBt.titleLabel?.font = stdFont
        shapeBt.titleLabel?.font = stdFont
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func saveColors() {
        switch curTag {
        case POINTS_TAG:
            colors.pointsR = NSNumber(float: red.value)
            colors.pointsG = NSNumber(float: green.value)
            colors.pointsB = NSNumber(float: blue.value)
        case PLATFORM_TAG:
            colors.platformR = NSNumber(float: red.value)
            colors.platformG = NSNumber(float: green.value)
            colors.platformB = NSNumber(float: blue.value)
        case BACKGD_TAG:
            colors.backgdR = NSNumber(float: red.value)
            colors.backgdG = NSNumber(float: green.value)
            colors.backgdB = NSNumber(float: blue.value)
        case SHAPE_TAG:
            colors.shapeR = NSNumber(float: red.value)
            colors.shapeG = NSNumber(float: green.value)
            colors.shapeB = NSNumber(float: blue.value)
        default:
            print("Erroneous curTag \(curTag)")
        }
        
        try! managedObjectContext?.save()
    }
    
    func updateButton(tag: Int, fromCD: Bool) {
        switch tag {
        case POINTS_TAG:
            pointsBt.backgroundColor = UIColor(red: CGFloat(fromCD ? colors.pointsR! : red.value),
                                               green: CGFloat(fromCD ? colors.pointsG! : green.value),
                                               blue: CGFloat(fromCD ? colors.pointsB! : blue.value), alpha: 1.0)
            
            if OptionsViewController.colorDist(pointsBt.backgroundColor!) > OptionsViewController.TEXT_COLOR_CUTOFF {
                pointsBt.setTitleColor(UIColor.blackColor(), forState: .Normal)
            } else {
                pointsBt.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            }
        case PLATFORM_TAG:
            platformBt.backgroundColor = UIColor(red: CGFloat(fromCD ? colors.platformR! : red.value),
                                                 green: CGFloat(fromCD ? colors.platformG! : green.value),
                                                 blue: CGFloat(fromCD ? colors.platformB! : blue.value), alpha: 1.0)
            if OptionsViewController.colorDist(platformBt.backgroundColor!) > OptionsViewController.TEXT_COLOR_CUTOFF {
                platformBt.setTitleColor(UIColor.blackColor(), forState: .Normal)
            } else {
                platformBt.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            }
        case BACKGD_TAG:
            backgdBt.backgroundColor = UIColor(red: CGFloat(fromCD ? colors.backgdR! : red.value),
                                               green: CGFloat(fromCD ? colors.backgdG! : green.value),
                                               blue: CGFloat(fromCD ? colors.backgdB! : blue.value), alpha: 1.0)
            
            if OptionsViewController.colorDist(backgdBt.backgroundColor!) > OptionsViewController.TEXT_COLOR_CUTOFF {
                backgdBt.setTitleColor(UIColor.blackColor(), forState: .Normal)
            } else {
                backgdBt.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            }
        case SHAPE_TAG:
            shapeBt.backgroundColor = UIColor(red: CGFloat(fromCD ? colors.shapeR! : red.value),
                                              green: CGFloat(fromCD ? colors.shapeG! : green.value),
                                              blue: CGFloat(fromCD ? colors.shapeB! : blue.value), alpha: 1.0)
            
            if OptionsViewController.colorDist(shapeBt.backgroundColor!) > OptionsViewController.TEXT_COLOR_CUTOFF {
                shapeBt.setTitleColor(UIColor.blackColor(), forState: .Normal)
            } else {
                shapeBt.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            }
        default:
            print("Erroneous tag \(tag)")
        }
    }
    
    @IBAction func pressedBt(sender: AnyObject?) {
        var tag: Int
        if sender == nil {
            tag = 0
        } else {
            tag = sender!.tag
            saveColors()
        }
        
        switch tag {
        case POINTS_TAG:
            red.value = Float(colors.pointsR!)
            green.value = Float(colors.pointsG!)
            blue.value = Float(colors.pointsB!)
        case PLATFORM_TAG:
            red.value = Float(colors.platformR!)
            green.value = Float(colors.platformG!)
            blue.value = Float(colors.platformB!)
        case BACKGD_TAG:
            red.value = Float(colors.backgdR!)
            green.value = Float(colors.backgdG!)
            blue.value = Float(colors.backgdB!)
        case SHAPE_TAG:
            red.value = Float(colors.shapeR!)
            green.value = Float(colors.shapeG!)
            blue.value = Float(colors.shapeB!)
        default:
            print("Erroneous button tag \(tag)")
        }
        
        curTag = tag
        
        movedSlider(self)
    }
    
    @IBAction func movedSlider(sender: AnyObject) {
        redLbl.text = String(format: "%.2f", red.value)
        greenLbl.text = String(format: "%.2f", green.value)
        blueLbl.text = String(format: "%.2f", blue.value)
        
        updateButton(curTag, fromCD: false)
        
        colorVw.backgroundColor = UIColor(red: CGFloat(red.value), green: CGFloat(green.value), blue: CGFloat(blue.value), alpha: 1.0)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == SHOW_MENU_SEGUE {
            saveColors()
            (segue.destinationViewController as! MenuViewController).managedObjectContext = managedObjectContext
        }
    }
}
