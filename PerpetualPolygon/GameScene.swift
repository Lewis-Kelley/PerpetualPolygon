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
    
    var platform: Platform?
    var point : Point?
    var sides = 4
    
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
        
        platform = Platform(scene: self, sides: sides, fillCol: SKColor.greenColor(), zPos: 1.0)
        point = Point(scene: self, sides: sides)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            /* Animate platform moving in circle depending on if the touch was right or left */
            platform?.update(location.x < CGRectGetMidX(frame), pressedR: location.x > CGRectGetMidX(frame), resetFirstCall: true)
            
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
        platform?.update(false, pressedR: false, resetFirstCall: false)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        point?.update()
    }
}
