//
//  GameScene.swift
//  PerpetualPolygon
//
//  Created by Lewis on 7/4/16.
//  Copyright (c) 2016 Lewis. All rights reserved.
//

import SpriteKit
import Firebase

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
    
    var colors: Colors!
    var platform: Platform?
    var points : [Point?] = []
    var sides = 6
    var life = 5
    
    let highscoreRef = FIRDatabase.database().reference().child("highscores")
    
    override func didMoveToView(view: SKView) {
        
        backgroundColor = colors.backgdColor()
        
        platform = Platform(scene: self, sides: sides, fillCol: colors.backgdColor(), zPos: 1.0)
        points.append(Point(scene: self, sides: sides, color: colors.pointsColor()))
        
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
        centerShape.fillColor = colors.shapeColor()
        centerShape.lineWidth = 0.0
        centerShape.zPosition = 100.0
        
        addChild(centerShape)
        
        let platformShape = SKShapeNode(path: platformPath)
        platformShape.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame))
        platformShape.fillColor = colors.platformColor()
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
        posLbl!.text = "Score: \((self.score))"
        for point in points {
            point?.update()
            if (point?.radius == Double(self.CENTER_SHAPE_RADIUS) && (point?.pos)! == ((platform?.pos)! + 0) % sides) {
                self.scene?.removeChildrenInArray([point!.img])
                self.points.removeAtIndex(0)
                self.score += 1
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
        if (self.life <= 0) {
            self.paused = true
            // Save the highscore to firebase
            saveHighScore()
        }
    }
    
    func saveHighScore() {
        self.highscoreRef.childByAutoId().setValue(Highscore(score: "\(self.score)", playerName: "Larry", difficulty: "Easy").getSnapshotValue())
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
        points.append(Point(scene: self, sides: sides, color: colors.pointsColor()))
        self.spawning = false
    }
}
