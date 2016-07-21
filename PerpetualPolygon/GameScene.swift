//
//  GameScene.swift
//  PerpetualPolygon
//
//  Created by Lewis on 7/4/16.
//  Copyright (c) 2016 Lewis. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let POLYGON_SIZE_RATIO:CGFloat = 0.50
    let PLATFORM_W:CGFloat = 145.0
    let PLATFORM_H:CGFloat = 30.0
    let PLATFORM_H_OFFSET:CGFloat = 108.0
    
    var platform = SKShapeNode()
    var sides = 6

    func getEdgeAngle() -> CGFloat {
        return CGFloat(M_PI) * (0.5 - 1 / CGFloat(sides)) // ([Pi / 2] - [2 * Pi] / [2 * sides])
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
//        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
//        myLabel.text = "Hello, World!"
//        myLabel.fontSize = 45
//        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
//        self.addChild(myLabel)
        
        /* Draw Polygon */
        let centerShape = SKSpriteNode(imageNamed: "hexagon.jpg")
        centerShape.xScale = POLYGON_SIZE_RATIO
        centerShape.yScale = centerShape.xScale
        centerShape.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        centerShape.zPosition = 0.0 //Z pos defines display order
        
        self.addChild(centerShape)
        
        /* Draw platform */
//        platform = SKShapeNode(rect:
//            CGRect(x: -PLATFORM_W / 2.0,
//            y:  -PLATFORM_H / 2.0,
//            width: PLATFORM_W,
//            height: PLATFORM_H))
        var path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0.0, 0.0)
        CGPathAddLineToPoint(path, nil, -3000 * cos(getEdgeAngle()), 3000 * sin(getEdgeAngle()))
        CGPathAddLineToPoint(path, nil, -3000, -3000)
        CGPathAddLineToPoint(path, nil, 3000, -3000)
        CGPathAddLineToPoint(path, nil, 3000 * cos(getEdgeAngle()), 3000 * sin(getEdgeAngle()))
        CGPathAddLineToPoint(path, nil, 0.0, 0.0)
        
        platform = SKShapeNode(path: path)
        platform.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        print("position: \(platform.position)")
        platform.fillColor = SKColor.greenColor()
        platform.strokeColor = SKColor.blackColor()
        platform.lineWidth = 5.0
        platform.zPosition = 1.0 //Z pos defines display order

        self.addChild(platform)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            print("location: \(location)")
            
            /* Animate platform moving in circle depending on if the touch was right or left */
//            platform.runAction(SKAction.followPath(
//                UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: PLATFORM_H_OFFSET, startAngle: platformPos, endAngle: location.x > CGRectGetMidX(frame) ? 100 : -100, clockwise: location.x > CGRectGetMidX(frame)).CGPath,
//                asOffset: false,
//                orientToPath: false, speed: 300.0))
            
            platform.runAction(SKAction.rotateByAngle(2.0 * CGFloat(M_PI), duration: 20))
            
//            let sprite = SKSpriteNode(imageNamed:"Spaceship")
//            
//            sprite.xScale = 0.5
//            sprite.yScale = 0.5
//            sprite.position = location
//            
//            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//            
//            sprite.runAction(SKAction.repeatActionForever(action))
//            
//            self.addChild(sprite)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        platform.removeAllActions() //Stop platform
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
