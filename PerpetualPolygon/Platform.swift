//
//  Platform.swift
//  PerpetualPolygon
//
//  Created by Lewis on 7/21/16.
//  Copyright © 2016 Lewis. All rights reserved.
//

import Foundation
import SpriteKit

class Platform {
    let TOLERANCE:CGFloat = 0.001
    let SPEED:Double = 2.0 * M_PI / 2.0

    var sides: Int
    var pos = 0 //The side of the polygon currently occupied by the rightmost part of the platform, starting from the top and proceeding ccw
    var length = 1 //The number of sides taken up by the platform
    
    var passedSide = false //Keeps track of whether the platform has passed a corner in the current motion
    var movingCW = false
    var movingCCW = false
    
    var img = SKShapeNode()
    
    var _sideFactor:Double?
    var prevAngle:CGFloat = 0.0
    var _tarAngle:CGFloat = 0.0
    
    init(scene:SKScene, sides:Int, fillCol:SKColor, zPos:CGFloat) {
        self.sides = sides
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0.0, 0.0)
        CGPathAddLineToPoint(path, nil, -3000 * cos(_getEdgeAngle()), 3000 * sin(_getEdgeAngle()))
        CGPathAddLineToPoint(path, nil, -3000, -3000)
        CGPathAddLineToPoint(path, nil, 3000, -3000)
        CGPathAddLineToPoint(path, nil, 3000 * cos(_getEdgeAngle()), 3000 * sin(_getEdgeAngle()))
        CGPathAddLineToPoint(path, nil, 0.0, 0.0)
        
        img = SKShapeNode(path: path)
        img.position = CGPoint(x: CGRectGetMidX(scene.frame), y: CGRectGetMidY(scene.frame))
        img.fillColor = fillCol
        img.strokeColor = SKColor.blackColor()
        img.lineWidth = 5.0
        img.zPosition = zPos
        
        scene.addChild(img)
    }
    
    /* Used in init to make the stencil */
    func _getEdgeAngle() -> CGFloat {
        return CGFloat(M_PI) * (0.5 - 1 / CGFloat(sides)) // ([Pi / 2] - [2 * Pi] / [2 * sides])
    }
    
    func _swapAngles() {
        let temp = _tarAngle
        _tarAngle = prevAngle
        prevAngle = temp
    }
    
    /* The lowest valid angle value for a side, all others are this plus some number of 2 Pi / sides */
    func sideFactor(sides:Int) -> Double {
        if _sideFactor == nil {
            _sideFactor = M_PI / 2.0
            
            while _sideFactor! - (2.0 * M_PI / Double(sides)) > 0.0 {
                _sideFactor! -= 2.0 * M_PI / Double(sides)
            }
        }

        return _sideFactor!
    }
    
    func tarAngle() -> CGFloat {
        if abs(_tarAngle - img.zRotation) < TOLERANCE { //Already reached destination
            prevAngle = _tarAngle
            
            if movingCW {
                _tarAngle -= CGFloat(M_PI) * 2.0 / CGFloat(sides)
            } else if movingCCW {
                _tarAngle += CGFloat(M_PI) * 2.0 / CGFloat(sides)
            }
        }
        
        return _tarAngle
    }
    
    func update(pressedL:Bool, pressedR:Bool) {
        var tarAng = img.zRotation
        
        if pressedL {
            if movingCW { // Turning around
                _swapAngles()
                movingCW = false
            }
            
            movingCCW = true
            tarAng = tarAngle()
        } else if pressedR {
            if movingCCW { // Turning around
                _swapAngles()
                movingCCW = false
            }
            
            movingCW = true
            tarAng = tarAngle()
        } else { // Move towards nearest side
            let toTarAngle = _tarAngle - tarAng
            let toPrevAngle =  prevAngle - tarAng
            if abs(toTarAngle) < abs(toPrevAngle) {
                if abs(toTarAngle) < TOLERANCE {
                    movingCW = false
                    movingCCW = false
                } else {
                    tarAng = _tarAngle
                    movingCW = toTarAngle < 0.0
                    movingCCW = !movingCW
                }
            } else {
                if abs(toPrevAngle) < TOLERANCE {
                    movingCW = false
                    movingCCW = false
                } else {
                    tarAng = prevAngle
                    movingCW = toPrevAngle > 0.0
                    movingCCW = !movingCW
                }
            }
        }
        
        print("At end of update, tarAng = \(tarAng)")
        img.runAction(SKAction.rotateToAngle(tarAng, duration: abs(Double(tarAng) - Double(img.zRotation)) / SPEED))
//        img.runAction(SKAction.rotateByAngle(CGFloat(M_PI), duration: 2.0))
    }
}