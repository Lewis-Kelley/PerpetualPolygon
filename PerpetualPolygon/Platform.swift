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
    let STENCIL_RADIUS: CGFloat = 500
    let TOLERANCE:CGFloat = 0.001
    let SPEED:Double = 2.0 * M_PI / 1.0
    let PROCEED_WEIGHT:CGFloat = 1.25 // Increases the threashold that when released, the platform will finish it's current path. Larger = more likely

    var sides: Int
    var pos: Int { //The side of the polygon currently occupied by the center of the platform, starting from the top and proceeding ccw
        var rot = img.zRotation
        
        while rot <= -TOLERANCE {
            rot += CGFloat(2.0 * M_PI)
        }
        while rot - CGFloat(2.0 * M_PI) >= -TOLERANCE {
            rot -= CGFloat(2.0 * M_PI)
        }
        
        let decPos = rot / CGFloat(M_PI * 2.0 / Double(sides))
        let lowPos = Int(decPos)
        let highPos = Int(decPos) + 1
        
        if decPos - CGFloat(lowPos) <= CGFloat(highPos) - decPos {
            return lowPos
        }
        
        if highPos >= sides {
            return 0
        }
        
        return highPos
    }
    
    var length = 1 //The number of sides taken up by the platform
    
    var movingCW = false
    var movingCCW = false
    
    var img = SKShapeNode()
    
    var firstCall = true
    var _sideFactor:Double?
    var prevAngle:CGFloat = 0.0
    var _tarAngle:CGFloat = 0.0
    
    init(scene:SKScene, sides:Int, fillCol:SKColor, zPos:CGFloat) {
        self.sides = sides
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0.0, 0.0)
        CGPathAddLineToPoint(path, nil, -STENCIL_RADIUS
            * cos(_getEdgeAngle()), STENCIL_RADIUS * sin(_getEdgeAngle()))
        CGPathAddLineToPoint(path, nil, -STENCIL_RADIUS, -STENCIL_RADIUS)
        CGPathAddLineToPoint(path, nil, STENCIL_RADIUS, -STENCIL_RADIUS)
        CGPathAddLineToPoint(path, nil, STENCIL_RADIUS * cos(_getEdgeAngle()), STENCIL_RADIUS * sin(_getEdgeAngle()))
        CGPathAddLineToPoint(path, nil, 0.0, 0.0)
        
        img = SKShapeNode(path: path)
        img.position = CGPoint(x: CGRectGetMidX(scene.frame), y: CGRectGetMidY(scene.frame))
        img.fillColor = fillCol
        img.lineWidth = 0.0
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
    
    func update(pressedL:Bool, pressedR:Bool, resetFirstCall:Bool) {
        if resetFirstCall {
            firstCall = true
        }
        
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
            let toPrevAngle = prevAngle - tarAng
            if firstCall || abs(toTarAngle) < PROCEED_WEIGHT * abs(toPrevAngle) {
                if abs(toTarAngle) < TOLERANCE {
                    movingCW = false
                    movingCCW = false
                } else {
                    tarAng = _tarAngle
                    movingCW = toTarAngle < 0.0
                    movingCCW = !movingCW
                }
            } else {
                _tarAngle = prevAngle
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
        
        img.removeAllActions()
        img.runAction(SKAction.sequence([SKAction.rotateToAngle(tarAng, duration: abs(Double(tarAng) - Double(img.zRotation)) / SPEED), SKAction.runBlock({ 
            if pressedL || pressedR {
                self.firstCall = false
                self.update(pressedL, pressedR: pressedR, resetFirstCall: false)
            }
        })]))
    }
}