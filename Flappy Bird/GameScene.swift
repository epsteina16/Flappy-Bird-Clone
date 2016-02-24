//
//  GameScene.swift
//  Flappy Bird
//
//  Created by block7 on 12/3/15.
//  Copyright (c) 2015 block7. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let playButton = SKSpriteNode(imageNamed: "play")
    let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    var score = 0
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    override func didMoveToView(view: SKView) {
        self.playButton.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame))
        self.addChild(self.playButton)
        self.backgroundColor = UIColor.blueColor()
        getUserDefaults()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches{
            let location = touch.locationInNode(self)
            var touchedNode = self.nodeAtPoint(location)
            if touchedNode == self.playButton{
                var scene = PlayScene(size: self.size)
                let skView = self.view! as SKView
                scene.scaleMode = .ResizeFill
                scene.size = skView.bounds.size
                skView.presentScene(scene)
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    func getUserDefaults(){
        if let prevScore = defaults.stringForKey("score")
        {
            scoreLabel.text = String(prevScore)
            self.scoreLabel.fontSize = 42
            scoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.playButton.position.y - 150)
            self.addChild(scoreLabel)
            print(prevScore)
        }
        else{
            scoreLabel.text = "0"
            self.scoreLabel.fontSize = 42
            scoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.playButton.position.y - 150)
            self.addChild(scoreLabel)
        }
    }
}
