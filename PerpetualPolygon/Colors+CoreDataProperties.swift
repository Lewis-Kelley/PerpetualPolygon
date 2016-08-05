//
//  Colors+CoreDataProperties.swift
//  PerpetualPolygon
//
//  Created by Lewis on 8/5/16.
//  Copyright © 2016 Lewis. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Colors {

    @NSManaged var platformR: NSNumber?
    @NSManaged var platformG: NSNumber?
    @NSManaged var platformB: NSNumber?
    @NSManaged var pointsR: NSNumber?
    @NSManaged var pointsG: NSNumber?
    @NSManaged var pointsB: NSNumber?
    @NSManaged var backgdR: NSNumber?
    @NSManaged var backgdG: NSNumber?
    @NSManaged var backgdB: NSNumber?
    @NSManaged var shapeR: NSNumber?
    @NSManaged var shapeG: NSNumber?
    @NSManaged var shapeB: NSNumber?

}
