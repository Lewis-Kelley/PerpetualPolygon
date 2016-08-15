//
//  GameViewController.swift
//  PerpetualPolygon
//
//  Created by Lewis on 7/4/16.
//  Copyright (c) 2016 Lewis. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var colors: Colors?
    var diff: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            scene.colors = colors
            scene.setViewController(self)
            
            setDiff(scene)
            
            
            skView.presentScene(scene)
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func setDiff(scene: GameScene) {
        switch diff! {
        case 0:
            scene.sides = 3
            scene.diff = "Easy"
        case 1:
            scene.sides = 4
            scene.diff = "Medium"
        case 2:
            scene.sides = 5
            scene.diff = "Hard"
        case 3:
            scene.sides = 6
            scene.diff = "Extreme"
        case 4:
            scene.sides = 7
            scene.diff = "Impossible"
        default:
            print("ERROR: Unrecognized difficulty number \(diff)")
        }
    }
}
