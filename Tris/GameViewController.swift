//
//  GameViewController.swift
//  Tris
//
//  Created by Eshan on 7/28/16.
//  Copyright (c) 2016 Eshan. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var scene: GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Config View
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Config Scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        // Present Scene
        skView.presentScene(scene)

    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
