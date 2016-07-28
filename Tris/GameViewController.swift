//
//  GameViewController.swift
//  Tris
//
//  Created by Eshan on 7/28/16.
//  Copyright (c) 2016 Eshan. All rights reserved.
//

import UIKit
import SpriteKit
import iAd

class GameViewController: UIViewController, TrisDelegate, UIGestureRecognizerDelegate {
    
    var scene: GameScene!
    var tris:Tris!
    
    var panPointReference:CGPoint?

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var highscoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Config View
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        self.canDisplayBannerAds = true

        
        // Config Scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        scene.tick = didTick
        tris = Tris()
        tris.delegate = self
        tris.beginGame()

        // Present Scene
        skView.presentScene(scene)
        
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func didTick() {
        tris.letShapeFall()
    }
    
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        tris.rotateShape()
    }
    
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        let currentPoint = sender.translationInView(self.view)
        if let originalPoint = panPointReference {
            
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                
                if sender.velocityInView(self.view).x > CGFloat(0) {
                    tris.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    tris.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .Began {
            panPointReference = currentPoint
        }

    }
    
    @IBAction func didSwipe(sender: AnyObject) {
        tris.dropShape()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer {
            if otherGestureRecognizer is UIPanGestureRecognizer {
                return true
            }
        } else if gestureRecognizer is UIPanGestureRecognizer {
            if otherGestureRecognizer is UITapGestureRecognizer {
                return true
            }
        }
        return false
    }
    
    func nextShape() {
        let newShapes = tris.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
        self.scene.movePreviewShape(fallingShape) {
            self.view.userInteractionEnabled = true
            self.scene.startTicking()
        }
    }
    
    func gameDidBegin(tris: Tris) {
        levelLabel.text = "\(tris.level)"
        scoreLabel.text = "\(tris.score)"
        highscoreLabel.text = "\(tris.highscore)"
        scene.tickLengthMillis = TickLengthLevelOne
        
        // The following is false when restarting a new game
        if tris.nextShape != nil && tris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(tris.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }

    func gameDidEnd(tris: Tris) {
        view.userInteractionEnabled = false
        scene.stopTicking()
        scene.playSound("Sounds/gameover.mp3")
        scene.animateCollapsingLines(tris.removeAllBlocks(), fallenBlocks: tris.removeAllBlocks()) {
            tris.beginGame()
        }

    }
    
    func gameDidLevelUp(tris: Tris) {
        levelLabel.text = "\(tris.level)"
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        scene.playSound("Sounds/levelup.mp3")
    }
    
    func gameShapeDidDrop(tris: Tris) {
        
        scene.stopTicking()
        scene.redrawShape(tris.fallingShape!) {
            tris.letShapeFall()
        }
        scene.playSound("Sounds/drop.mp3")
    }
    
    func gameShapeDidLand(tris: Tris) {
        scene.stopTicking()
        self.view.userInteractionEnabled = false
        let removedLines = tris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(tris.score)"
            self.highscoreLabel.text = "\(tris.highscore)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                self.gameShapeDidLand(tris)
            }
            scene.playSound("Sounds/bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    func gameShapeDidMove(tris: Tris) {
        scene.redrawShape(tris.fallingShape!) {}
    }

}
