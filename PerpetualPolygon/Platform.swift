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
    let STENCIL_RADIUS: CGFloat = 250
    let TOLERANCE:CGFloat = 0.001
    let PROCEED_WEIGHT:CGFloat = 1.25 // Increases the threashold that when released, the platform will finish it's current path. Larger = more likely
    let PWR_UP_TIME = 10.0

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
    
    var speed: Double = 2.0 * M_PI / 1.0
    var length = 1 //The number of sides taken up by the platform
    
    var movingCW = false
    var movingCCW = false
    
    var img = SKShapeNode()
    
    var firstCall = true
    var prevAngle:CGFloat = 0.0
    var _tarAngle:CGFloat = 0.0
    
    var scene: SKScene
    var fillCol: SKColor
    var zPos: CGFloat
    
    var pwrUpStart = NSDate()
    
    var pwrUp = Powers.None
    
    init(scene:SKScene, sides:Int, fillCol:SKColor, zPos:CGFloat, speed: Double) {
        self.scene = scene
        self.sides = sides
        self.fillCol = fillCol
        self.zPos = zPos
        self.speed = speed
        
        makeImg()
    }
    
    /* Used to make the stencil */
    
    func _swapAngles() {
        let temp = _tarAngle
        _tarAngle = prevAngle
        prevAngle = temp
    }
    
    // Returns the angle for the given vertex (vertex 0 = first vertex right of pos 0)
    func _angleForVertex(vertex: Int) -> CGFloat {
        return 2.0 * CGFloat(M_PI) * CGFloat(vertex) / CGFloat(sides) + CGFloat(M_PI) * (0.5 - 1 / CGFloat(sides)) // ([Pi / 2] - [2 * Pi] / [2 * sides])
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
    
    func makeImg() {
        scene.removeChildrenInArray([img])
        
        let rot = img.zRotation
        
        img = SKShapeNode(path: makeStencilPath())
        img.position = CGPoint(x: CGRectGetMidX(scene.frame), y: CGRectGetMidY(scene.frame))
        img.fillColor = fillCol
        img.lineWidth = 0.0
        img.zPosition = zPos
        img.zRotation = rot
        
        scene.addChild(img)
    }
    
    func makeStencilPath() -> CGPath {
        let endPos = (pwrUp == .Doubled ? sides - 1 : sides)
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0.0, 0.0)
        
        var curPos = 1
        while curPos <= endPos {
            CGPathAddLineToPoint(path, nil, STENCIL_RADIUS * cos(_angleForVertex(curPos)), STENCIL_RADIUS * sin(_angleForVertex(curPos)))
            curPos += 1
        }
        CGPathAddLineToPoint(path, nil, 0.0, 0.0)
        
        return path
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
        img.runAction(SKAction.sequence([SKAction.rotateToAngle(tarAng, duration: abs(Double(tarAng) - Double(img.zRotation)) / speed), SKAction.runBlock({ 
            if pressedL || pressedR {
                self.firstCall = false
                self.update(pressedL, pressedR: pressedR, resetFirstCall: false)
            }
        })]))
    }
    
    func getPowerUp(pwr: Powers) {
        if pwr != pwrUp {
            switch pwrUp {
            case .Doubled:
                pwrUp = pwr
                makeImg()
                break
            case .None:
                break
            }
            
            switch pwr {
            case .Doubled:
                pwrUp = pwr
                makeImg()
                break
            case .None:
                break
            }
        }
        
        pwrUpStart = NSDate()
    }
    
    func pointDidCollide(pt: Point) -> Bool {
        return pt.pos == pos || (pwrUp == .Doubled && pt.pos == (pos - 1 < 0 ? sides - 1 : pos - 1))
    }
    
    func ciel(num: Double) -> Int {
        if num - Double(Int(num)) >= 0.5 {
            return Int(num) + 1
        }
        
        return Int(num)
    }
}