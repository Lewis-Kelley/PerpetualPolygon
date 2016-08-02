//
//  GameScene.swift
//  PerpetualPolygon
//
//  Created by Lewis on 7/4/16.
//  Copyright (c) 2016 Lewis. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var spawning = false
    var pointLabel : SKLabelNode?
    var score = 0
    var lifeLabel : SKLabelNode?
    var posLbl: SKLabelNode? //TEMP
    let POLYGON_SIZE_RATIO:CGFloat = 0.50
    let PLATFORM_W:CGFloat = 145.0
    let PLATFORM_H:CGFloat = 30.0
    let PLATFORM_H_OFFSET:CGFloat = 108.0
    let CENTER_SHAPE_RADIUS: CGFloat = 100.0
    let PLATFORM_SHAPE_RADIUS: CGFloat = 120.0
    
    var platform: Platform?
    var points : [Point?] = []
    var sides = 5
    var life = 20
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
//        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
//        myLabel.text = "Hello, World!"
//        myLabel.fontSize = 45
//        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
//        self.addChild(myLabel)
        
        /* Draw Polygon */
//        let centerShape = SKSpriteNode(imageNamed: "hexagon.jpg")
//        centerShape.xScale = POLYGON_SIZE_RATIO
//        centerShape.yScale = centerShape.xScale
//        centerShape.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
//        centerShape.zPosition = 0.0 //Z pos defines display order
//        
//        self.addChild(centerShape)
//        
        /* Draw platform */
//        platform = SKShapeNode(rect:
//            CGRect(x: -PLATFORM_W / 2.0,
//            y:  -PLATFORM_H / 2.0,
//            width: PLATFORM_W,
//            height: PLATFORM_H))
        
        backgroundColor = SKColor.lightGrayColor()
        
        platform = Platform(scene: self, sides: sides, fillCol: SKColor.lightGrayColor(), zPos: 1.0)
        points.append(Point(scene: self, sides: sides))
        
        /* Create center shape and platform shape */
        let startTheta = CGFloat(M_PI  * (0.5 - 1.0 / Double(sides))) // ([Pi / 2] - [2 * Pi] / [2 * sides])
        let centerPath = CGPathCreateMutable()
        let platformPath = CGPathCreateMutable()
        
        CGPathMoveToPoint(centerPath, nil, CENTER_SHAPE_RADIUS * cos(startTheta), CENTER_SHAPE_RADIUS * sin(startTheta))
        CGPathMoveToPoint(platformPath, nil, PLATFORM_SHAPE_RADIUS * cos(startTheta), PLATFORM_SHAPE_RADIUS * sin(startTheta))
        
        var theta = startTheta
        for _ in 1...sides {
            theta += 2 * CGFloat(M_PI) / CGFloat(sides)
            CGPathAddLineToPoint(centerPath, nil, CENTER_SHAPE_RADIUS * cos(theta), CENTER_SHAPE_RADIUS * sin(theta))
            CGPathAddLineToPoint(platformPath, nil, PLATFORM_SHAPE_RADIUS * cos(theta), PLATFORM_SHAPE_RADIUS * sin(theta))
        }
        
        let centerShape = SKShapeNode(path: centerPath)
        centerShape.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame))
        centerShape.fillColor = SKColor.greenColor()
        centerShape.lineWidth = 0.0
        centerShape.zPosition = 100.0
        
        addChild(centerShape)
        
        let platformShape = SKShapeNode(path: platformPath)
        platformShape.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame))
        platformShape.fillColor = SKColor.redColor()
        platformShape.lineWidth = 0.0
        platformShape.zPosition = 0.0
        
        addChild(platformShape)
        
        self.lifeLabel = SKLabelNode(fontNamed: "Arial")
        self.lifeLabel!.text = "\(self.life)"
        self.lifeLabel!.fontSize = 20
        self.lifeLabel!.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.lifeLabel!.zPosition = 101.00
        addChild(self.lifeLabel!)
        
        self.posLbl = SKLabelNode(fontNamed: "Arial")
        self.posLbl!.fontSize = 20
        self.posLbl!.position = CGPoint(x: CGRectGetMinX(self.frame) + 50, y: CGRectGetMidY(self.frame))
        self.posLbl!.zPosition = 101.00
        addChild(self.posLbl!)
        
//        self.pointLabel = SKLabelNode(fontNamed: "Arial")
//        self.pointLabel?.text = "\(self.score)"
//        self.pointLabel!.fontSize = 20
//        self.pointLabel!.position = CGPoint(x: 0,y: 0)
//        addChild(self.pointLabel!)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            /* Animate platform moving in circle depending on if the touch was right or left */
            platform?.update(location.x < CGRectGetMidX(frame), pressedR: location.x > CGRectGetMidX(frame), resetFirstCall: true)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        platform?.update(false, pressedR: false, resetFirstCall: false)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        posLbl!.text = "Pos: \((platform?.pos)!)"
        for point in points {
            point?.update()
            if (point?.radius == Double(self.CENTER_SHAPE_RADIUS) && (point?.pos)! == ((platform?.pos)! + 1) % sides) {
                self.scene?.removeChildrenInArray([point!.img])
                self.points.removeAtIndex(0)
            }
        }
        if (!self.spawning) {
            delay(1.5, closure: spawn)
        }
    }
    
    func removeFromArray(pointToFind : Point) {
        points.removeAtIndex(0)
        self.life = self.life - 1
        self.lifeLabel?.text = "\(self.life)"
    }
    
    func delay(delay:Double, closure:()->()) {
        self.spawning = true
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func spawn() {
        points.append(Point(scene: self, sides: sides))
        self.spawning = false
    }
}
