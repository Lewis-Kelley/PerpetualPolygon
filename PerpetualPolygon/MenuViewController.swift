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
    
    var managedObjectContext: NSManagedObjectContext?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        print("Starting segue \(segue.identifier)")
        if segue.identifier == SHOW_OPTIONS_SEGUE {
            (segue.destinationViewController as! OptionsViewController).managedObjectContext = managedObjectContext
        }
    }

}
