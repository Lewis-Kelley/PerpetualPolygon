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
    let BOX_HEIGHT_FACTOR: CGFloat = 1.0 / (IPAD ? 5.0 : 4.0) //Fraction of the height of the screen to be used for the HUD boxes
    let BOX_LINE_WIDTH: CGFloat = 5.0
    let BOX_CORNER_RADIUS: CGFloat = 10.0
    let TEXT_BUFFER: CGFloat = 5.0 //Distance text starts from borders
    let FONT_SIZE: CGFloat = IPAD ? 40.0 : 20.0
    let FONT_ID = "Arial"
    
    // Status variables
    var spawning = false
    var score = 0
    var life = 5
    var streak = 0
    
    // Labels
    var lifeLabel : SKLabelNode?
    var scoreLbl: SKLabelNode!
    var hScoreLbl: SKLabelNode!
    var diffLbl: SKLabelNode!
    var pptLbl: SKLabelNode!
    
    // Unchanging one game starts or containers
    var colors: Colors!
    var platform: Platform!
    var points : [Point?] = []
    var sides = 6
    var diff: String?
    var highScore = 0
    
    let highscoreRef = FIRDatabase.database().reference().child("highscores")
    
    override func didMoveToView(view: SKView) {
        backgroundColor = colors.backgdColor()
        
        platform = Platform(scene: self, sides: sides, fillCol: colors.backgdColor(), zPos: 1.0)
        points.append(Point(scene: self, sides: sides, color: colors.pointsColor(), power: .None))
        
        /* Create center shape and platform shape */
        
        let centerShapes = makeCenterShapes()
        addChild(centerShapes.0)
        addChild(centerShapes.1)
        
        /* Create HUD boxes */
        
        addChild(makeLeftBox())
        addChild(makeRightBox())
        
        /* Create life label */
        
        lifeLabel = SKLabelNode(fontNamed: FONT_ID)
        lifeLabel!.text = "\(life)"
        lifeLabel!.fontSize = FONT_SIZE
        lifeLabel!.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame) - FONT_SIZE / 3.0)
        lifeLabel!.zPosition = 101.00
        addChild(lifeLabel!)
        
        /* Create score labels */
        
        hScoreLbl = SKLabelNode(fontNamed: FONT_ID)
        hScoreLbl.fontSize = FONT_SIZE
        hScoreLbl.position = CGPoint(x: CGRectGetMinX(frame) + TEXT_BUFFER, y: CGRectGetMaxY(frame) - (IPAD ? 1.0 : 6.0) * FONT_SIZE) //Don't ask why the iPad flag. I don't know
        hScoreLbl.horizontalAlignmentMode = .Left
        hScoreLbl.zPosition = 101.0
        addChild(hScoreLbl)
        
        scoreLbl = SKLabelNode(fontNamed: FONT_ID)
        scoreLbl.fontSize = FONT_SIZE
        scoreLbl.position = CGPoint(x: CGRectGetMinX(frame) + TEXT_BUFFER, y: CGRectGetMaxY(frame) - frame.height * BOX_HEIGHT_FACTOR + 3.0 * TEXT_BUFFER)
        scoreLbl.horizontalAlignmentMode = .Left
        scoreLbl.zPosition = 101.0
        addChild(scoreLbl)
        
        /* Create difficulty and powerpoint labels */
        
        diffLbl = SKLabelNode(fontNamed: FONT_ID)
        diffLbl.fontSize = FONT_SIZE
        diffLbl.position = CGPoint(x: CGRectGetMaxX(frame) - TEXT_BUFFER, y: CGRectGetMaxY(frame) - (IPAD ? 1.0 : 6.0) * FONT_SIZE) //Don't ask why the iPad flag. I don't know
        diffLbl.horizontalAlignmentMode = .Right
        diffLbl.zPosition = 101.0
        diffLbl.text = diff
        addChild(diffLbl)
        
        pptLbl = SKLabelNode(fontNamed: FONT_ID)
        pptLbl.fontSize = FONT_SIZE
        pptLbl.position = CGPoint(x: CGRectGetMaxX(frame) - TEXT_BUFFER, y: CGRectGetMaxY(frame) - frame.height * BOX_HEIGHT_FACTOR + 3.0 * TEXT_BUFFER)
        pptLbl.horizontalAlignmentMode = .Right
        pptLbl.zPosition = 101.0
        addChild(pptLbl)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        //platform.getPowerUp(platform.pwrUp == .None ? .Doubled : .None) //For testing
        
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
        hScoreLbl.text = "High: \(highScore)"
        scoreLbl.text = "Score: \(score)"
        pptLbl.text = "Streak: \(streak)" // TODO: Something fancy to show how close the player is getting to a ppt
        
        for point in points {
            point?.update()
            if (point?.radius == Double(self.CENTER_SHAPE_RADIUS) && platform.pointDidCollide(point!)) {
                self.scene?.removeChildrenInArray([point!.img])
                self.points.removeAtIndex(0)
                self.score += 1
                self.streak += 1
                if (point?.pwr)! != Powers.None {
                    platform.getPowerUp((point?.pwr)!)
                }
            }
        }
        if (!self.spawning) {
            delay(1.5, closure: spawn)
        }
    }
    
    func removeFromArray(pointToFind : Point) {
        points.removeAtIndex(0)
        self.life = self.life - 1
        self.streak = 0
        self.lifeLabel?.text = "\(self.life)"
        platform.getPowerUp(.None)
        if (self.life <= 0) {
            self.paused = true
            // Save the highscore to firebase
            saveHighScore()
        }
    }
    
    func saveHighScore() {
        self.highscoreRef.childByAutoId().setValue(Highscore(score: "\(self.score)", playerName: "Larry", difficulty: "Easy").getSnapshotValue()) //Why Larry?
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
        points.append(Point(scene: self, sides: sides, color: colors.pointsColor(), power: streak > 4 ? .Doubled : .None))
        self.spawning = false
    }
    
    // MARK: HUD functions
    
    func makeCenterShapes() -> (SKShapeNode, SKShapeNode) {
        let centerPath = CGPathCreateMutable()
        let platformPath = CGPathCreateMutable()
        var theta = CGFloat(M_PI  * (0.5 - 1.0 / Double(sides))) // ([Pi / 2] - [2 * Pi] / [2 * sides])
        
        CGPathMoveToPoint(centerPath, nil, CENTER_SHAPE_RADIUS * cos(theta), CENTER_SHAPE_RADIUS * sin(theta))
        CGPathMoveToPoint(platformPath, nil, PLATFORM_SHAPE_RADIUS * cos(theta), PLATFORM_SHAPE_RADIUS * sin(theta))
        
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
                height: frame.height * BOX_HEIGHT_FACTOR + BOX_LINE_WIDTH))
        
        boxConfig(leftBox)
        
        return leftBox
    }
    
    func makeRightBox() -> SKShapeNode {
        let rightBox = SKShapeNode(
            rect: CGRect(x: CGRectGetMaxX(frame) - frame.width * BOX_WIDTH_FACTOR,
                y: CGRectGetMaxY(frame) - frame.height * BOX_HEIGHT_FACTOR,
                width: frame.width * BOX_WIDTH_FACTOR + BOX_LINE_WIDTH,
                height: frame.height * BOX_HEIGHT_FACTOR + BOX_LINE_WIDTH))
        
        boxConfig(rightBox)
        
        return rightBox
    }
}

enum Powers {
    case None
    case Doubled
}
