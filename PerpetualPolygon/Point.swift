//
//  Point.swift
//  PerpetualPolygon
//
//  Created by Chase Bishop on 7/25/16.
//  Copyright © 2016 Lewis. All rights reserved.
//

import Foundation
import SpriteKit

class Point {
    let scene : SKScene
    let centerX : Double
    let centerY : Double
    var gameRunning : Bool = true
    var SPEED : Double = 10
    var radius : Double = 500
    let sides : Int
    let pos : Int // The side that the point will come from.
    var img = SKShapeNode()
    var angle : Double
    var pwr: Powers
    
    init(scene : SKScene, sides : Int, color: UIColor, power: Powers) {
        self.sides = sides
        self.scene = scene
        self.pos = Int(arc4random_uniform(UInt32(sides)))
        self.angle = (Double(self.pos) * Double(360 / Double(sides))) * (2 * 3.14 / 360)
        
        self.angle = self.angle + (3.14/2)
        
        pwr = power
        
        centerX = Double(CGRectGetMidX(scene.frame))
        centerY = Double(CGRectGetMidY(scene.frame))
        
        let X = Double(CGRectGetMidX(scene.frame)) + (radius * cos(angle))
        let Y = Double(CGRectGetMidY(scene.frame)) + (radius * sin(angle))
        img = SKShapeNode(circleOfRadius: 15)
        img.position = CGPoint(x: X, y: Y)
        img.fillColor = color
        img.strokeColor = pwr == .None ? SKColor.blackColor() : SKColor.whiteColor()
        img.zPosition = 1.1
        img.lineWidth = 5
        scene.addChild(img)
    }
    
    func update() {
        if (gameRunning){
            radius = radius - SPEED
            img.position = CGPoint(x: centerX + (radius * cos(angle)), y: centerY + (radius * sin(angle)))
            if (radius <= 0) {
                self.SPEED = 0
                self.gameRunning = false
                self.scene.removeChildrenInArray([self.img])
                (self.scene as! GameScene).removeFromArray(self)
            }
        }
    }
}