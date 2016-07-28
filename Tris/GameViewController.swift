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
    var tris:Tris!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Config View
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Config Scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        scene.tick = didTick
        tris = Tris()
        tris.beginGame()

        // Present Scene
        skView.presentScene(scene)
        
        scene.addPreviewShapeToScene(tris.nextShape!) {
            self.tris.nextShape?.moveTo(StartingColumn, row: StartingRow)
            self.scene.movePreviewShape(self.tris.nextShape!) {
                let nextShapes = self.tris.newShape()
                self.scene.startTicking()
                self.scene.addPreviewShapeToScene(nextShapes.nextShape!) {}
            }
        }

    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func didTick() {
        tris.fallingShape?.lowerShapeByOneRow()
        scene.redrawShape(tris.fallingShape!, completion: {})
    }
}
