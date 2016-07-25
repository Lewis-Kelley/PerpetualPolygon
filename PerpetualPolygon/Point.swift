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
    var gameRunning : Bool = false
    var SPEED : Double = 0.1
    var radius : Double = 100
    let sides : Int
    let pos : Int // The side that the point will come from.
    var img = SKShapeNode()
    let angle : Double
    
    init(scene : SKScene, sides : Int) {
        self.sides = sides
        self.pos = Int(arc4random_uniform(UInt32(sides)))
        self.angle = Double(self.pos) * Double(360 / Double(sides))
        
        let x : Double = Double(CGRectGetMidX(scene.frame)) + (radius * cos(angle))
        let y : Double = Double(CGRectGetMidY(scene.frame)) + (radius * sin(angle))
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, CGFloat(x), CGFloat(y))
        CGPathAddLineToPoint(path, nil, CGFloat(x + 15), CGFloat(y))
        CGPathAddLineToPoint(path, nil, CGFloat(x + 15), CGFloat(y - 15))
        CGPathAddLineToPoint(path, nil, CGFloat(x), CGFloat(y - 15))
        CGPathAddLineToPoint(path, nil, CGFloat(x), CGFloat(y))
        img = SKShapeNode(path: path)
        img.position = CGPoint(x: x, y: y)
        img.fillColor = SKColor.blueColor()
        img.strokeColor = SKColor.blackColor()
        img.zPosition = 5.0
        scene.addChild(img)
    }
    
    func update() {
        if (gameRunning){
            let x = radius - SPEED
            radius = x
            img.position = CGPoint(x: radius * cos(angle), y: radius * sin(angle))
            if (img.position.x == 0 || img.position.y == 0) {
                self.SPEED = 0
            }
        }
    }
}