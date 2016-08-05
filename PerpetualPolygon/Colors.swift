//
//  Colors.swift
//  PerpetualPolygon
//
//  Created by Lewis on 8/5/16.
//  Copyright © 2016 Lewis. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class Colors: NSManagedObject {
    let ALPHA: Float = 1.0

    func pointsColor() -> UIColor {
        return UIColor(colorLiteralRed: Float(pointsR!), green: Float(pointsG!), blue: Float(pointsB!), alpha: ALPHA)
    }
    
    func platformColor() -> UIColor {
        return UIColor(colorLiteralRed: Float(platformR!), green: Float(platformG!), blue: Float(platformB!), alpha: ALPHA)
    }
    
    func backgdColor() -> UIColor {
        return UIColor(colorLiteralRed: Float(backgdR!), green: Float(backgdG!), blue: Float(backgdB!), alpha: ALPHA)
    }
    
    func shapeColor() -> UIColor {
        return UIColor(colorLiteralRed: Float(shapeR!), green: Float(shapeG!), blue: Float(shapeB!), alpha: ALPHA)
    }
}
