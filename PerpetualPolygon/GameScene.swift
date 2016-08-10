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
    let POLYGON_SIZE_RATIO:CGFloat = 0.50
    let PLATFORM_W:CGFloat = 145.0
    let PLATFORM_H:CGFloat = 30.0
    let PLATFORM_H_OFFSET:CGFloat = 108.0
    let CENTER_SHAPE_RADIUS: CGFloat = 100.0
    let PLATFORM_SHAPE_RADIUS: CGFloat = 120.0
    let BOX_WIDTH_FACTOR: CGFloat = 1.0 / 5.0 //Fraction of the width of the screen to be used for the HUD boxes
    let BOX_HEIGHT_FACTOR: CGFloat = 1.0 / 4.0 //Fraction of the height of the screen to be used for the HUD boxes
    let BOX_LINE_WIDTH: CGFloat = 5.0
    let BOX_CORNER_RADIUS: CGFloat = 10.0
    
    var spawning = false
    var pointLabel : SKLabelNode?
    var score = 0
    var lifeLabel : SKLabelNode?
    var tmpLbl: SKLabelNode? //TEMP
    
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
        
        let centerShapes = makeCenterShapes()
        addChild(centerShapes.0)
        addChild(centerShapes.1)
        
        /* Create HUD boxes */
        
        addChild(makeLeftBox())
        addChild(makeRightBox())
        
        /* Create life label */
        
        self.lifeLabel = SKLabelNode(fontNamed: "Arial")
        self.lifeLabel!.text = "\(self.life)"
        self.lifeLabel!.fontSize = 20
        self.lifeLabel!.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.lifeLabel!.zPosition = 101.00
        addChild(self.lifeLabel!)
        
        self.tmpLbl = SKLabelNode(fontNamed: "Arial")
        self.tmpLbl!.fontSize = 20
        self.tmpLbl!.position = CGPoint(x: CGRectGetMinX(self.frame) + 50, y: CGRectGetMidY(self.frame))
        self.tmpLbl!.zPosition = 101.00
        addChild(self.tmpLbl!)
        
        self.pointLabel = SKLabelNode(fontNamed: "Arial")
        self.pointLabel?.text = "\(self.score)"
        self.pointLabel!.fontSize = 20
        self.pointLabel!.position = CGPoint(x: 0,y: 0)
        addChild(self.pointLabel!)
        
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
        tmpLbl!.text = "Score: \((self.score))"
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
    
    // MARK: HUD functions
    
    func makeCenterShapes() -> (SKShapeNode, SKShapeNode) {
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
        
        let platformShape = SKShapeNode(path: platformPath)
        platformShape.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame))
        platformShape.fillColor = colors.platformColor()
        platformShape.lineWidth = 0.0
        platformShape.zPosition = 0.0
        
        return (centerShape, platformShape)
    }
    
    func boxConfig(box: SKShapeNode) {
        box.fillColor = colors.shapeColor()
        box.zPosition = 100.0
        box.lineWidth = BOX_LINE_WIDTH
        box.strokeColor = colors.platformColor()
    }
    
    func makeLeftBox() -> SKShapeNode {
        let leftBox = SKShapeNode(
            rect: CGRect(x: CGRectGetMinX(frame) - BOX_LINE_WIDTH,
                y: CGRectGetMaxY(frame) - frame.height * BOX_HEIGHT_FACTOR,
                width: frame.width * BOX_WIDTH_FACTOR,
                height: frame.height * BOX_HEIGHT_FACTOR),
            cornerRadius: BOX_CORNER_RADIUS)
        
        boxConfig(leftBox)
        
        return leftBox
    }
    
    func makeRightBox() -> SKShapeNode {
        let rightBox = SKShapeNode(
            rect: CGRect(x: CGRectGetMaxX(frame) - frame.width * BOX_WIDTH_FACTOR,
                y: CGRectGetMaxY(frame) - frame.height * BOX_HEIGHT_FACTOR,
                width: frame.width * BOX_WIDTH_FACTOR + BOX_LINE_WIDTH,
                height: frame.height * BOX_HEIGHT_FACTOR),
            cornerRadius: BOX_CORNER_RADIUS)
        
        boxConfig(rightBox)
        
        return rightBox
    }
}
