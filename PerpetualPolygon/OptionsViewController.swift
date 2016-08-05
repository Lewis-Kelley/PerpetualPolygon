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
    
    let SHOW_MENU_SEGUE = "OptionsToMain"
    
    @IBOutlet weak var pointsBt: UIButton!
    @IBOutlet weak var platformBt: UIButton!
    @IBOutlet weak var backgdBt: UIButton!

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
        
        _fetchedResultsController = OptionsViewController.getFRC(managedObjectContext!, delegate: self)
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    static func getFRC(moc: NSManagedObjectContext, delegate: OptionsViewController?) -> NSFetchedResultsController {
        let fetchReq = NSFetchRequest(entityName: "Colors")
        fetchReq.sortDescriptors = [NSSortDescriptor(key: "pointsR", ascending: false)] //Pointless, but necessary
        
        let frc = NSFetchedResultsController(fetchRequest: fetchReq, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: "Master")
        
        frc.delegate = delegate == nil ? OptionsViewController() : delegate
        try! frc.performFetch()
        return frc
    }
    
    static func getColors(moc: NSManagedObjectContext?, delegate: OptionsViewController?) -> Colors {
        let frc = getFRC(moc!, delegate: delegate)
        var colors: Colors
        
        if frc.sections![0].numberOfObjects == 0 { // First time starting up
            colors = NSEntityDescription.insertNewObjectForEntityForName("Colors", inManagedObjectContext: moc!) as! Colors
            
            // Assign defaults
            try! moc?.save()
        } else {
            colors = frc.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! Colors
        }
        return colors
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colors = OptionsViewController.getColors(managedObjectContext!, delegate: self)
        pressedBt(nil)
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
        
        colorVw.backgroundColor = UIColor(colorLiteralRed: red.value, green: green.value, blue: blue.value, alpha: 1.0)
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
