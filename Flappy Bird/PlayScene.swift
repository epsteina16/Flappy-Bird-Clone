//
//  PlayScene.swift
//  Flappy Bird
//
//  Created by block7 on 12/17/15.
//  Copyright © 2015 block7. All rights reserved.
//

import Foundation
import SpriteKit

struct PhysicsCategory{
    static let Flappy: UInt32 = 0x1 << 1
    static let Ground: UInt32 = 0x1 << 2
    static let Pole: UInt32 = 0x1 << 3
}

class PlayScene: SKScene, SKPhysicsContactDelegate {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    let runningBar = SKSpriteNode(imageNamed: "bar")
    var origRunningBarPositionX = CGFloat(0)
    var maxPosition = CGFloat(0)
    var groundSpeed = 1.69

    var groundHeight = CGFloat(0)
    
    let flappy = SKSpriteNode(imageNamed: "flappy")
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let kGravity: CGFloat = -1500.0
    let kImpulse: CGFloat = 400.0
    var playerVelocity: CGFloat = 0
    
    var roofHeight = CGFloat(0)
    
    var tubeMaxX = CGFloat(0)
    var origTubePositionX = CGFloat(0)
    let scoreText = SKLabelNode(fontNamed: "Chalkduster")

    var score = 0
    var whatScore: NSNumber = 15
    
    var tubeSpace = 150
    
    var polePair = SKNode()
    var moveAndRemove = SKAction()
    
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        self.backgroundColor = UIColor.blueColor()
        
        self.runningBar.anchorPoint = CGPointMake(0, 0.5)
        self.runningBar.position = CGPointMake(CGRectGetMinX(self.frame),CGRectGetMinY(self.frame) + (self.runningBar.size.height / 2))
        self.runningBar.zPosition = 2
        self.addChild(self.runningBar)
        self.origRunningBarPositionX = self.runningBar.position.x
        self.maxPosition = self.runningBar.size.width - self.frame.size.width
        self.maxPosition *= -1
        
        setupplayer()
        
        self.flappy.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(self.flappy.size.width / 2))
        self.flappy.physicsBody!.affectedByGravity = false
        self.flappy.physicsBody!.categoryBitMask = PhysicsCategory.Flappy
        self.flappy.physicsBody!.contactTestBitMask = PhysicsCategory.Pole
        self.flappy.physicsBody!.collisionBitMask = PhysicsCategory.Pole
        
        self.roofHeight = CGRectGetMaxY(self.frame) - (self.flappy.size.height / 2)
        self.groundHeight = self.runningBar.size.height - (self.flappy.size.height / 2)
        
        self.scoreText.text = "0"
        self.scoreText.fontSize = 42
        self.scoreText.position = CGPointMake(CGRectGetMinX(self.frame) + 50, CGRectGetMaxY(self.frame) - 50)
        self.scoreText.zPosition = 5
        self.addChild(self.scoreText)
        
        
        let spawn = SKAction.runBlock({
            () in
            
            self.createPoles()
        })
        let delay = SKAction.waitForDuration(2.1)
        let spawnDelay = SKAction.sequence([spawn, delay])
        let spawnDelayForever = SKAction.repeatActionForever(spawnDelay)
        self.runAction(spawnDelayForever)
        
        let distance = CGFloat(self.frame.width + polePair.frame.width)
        let movePipes = SKAction.moveByX(-distance, y: 0, duration: NSTimeInterval(0.01 * distance))
        let removePipes = SKAction.removeFromParent()
        
        
        let addScore = SKAction.runBlock({
            self.score += 1
            self.scoreText.text = String(self.score)
        })
        var findTimeInterval = NSTimeInterval(distance - (size.width * 0.2))
        findTimeInterval = (findTimeInterval * 0.01) - 2.1
        let startDelay = SKAction.waitForDuration(findTimeInterval)
        let scoreDelay = SKAction.waitForDuration(2.1)
        let scoreSequence = SKAction.sequence([scoreDelay, addScore])
        let scoreForever = SKAction.repeatActionForever(scoreSequence)
        let scoreAction = SKAction.sequence([startDelay, scoreForever])
        self.runAction(scoreAction)

        
        moveAndRemove = SKAction.sequence([movePipes, removePipes])
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        flapPlayer()
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if self.runningBar.position.x <= maxPosition{
            self.runningBar.position.x = self.origRunningBarPositionX
        }
        runningBar.position.x -= CGFloat(self.groundSpeed)
        
        if self.flappy.position.y < self.groundHeight{
            died()
        }
        
        if lastUpdateTime > 0{
            dt = currentTime - lastUpdateTime
        } else{
            dt = 0
        }
        lastUpdateTime = currentTime
        updatePlayer()
        if flappy.position.y > self.frame.size.height{
            died()
        }
    }
    func didBeginContact(contact: SKPhysicsContact){
        died()
    }
    func died(){
        defaults.setInteger(self.score, forKey: "score")
        print(defaults.stringForKey("score"))
        let nextScene = GameScene(size: (self.scene?.size)!)
        nextScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(nextScene, transition: SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 0.5))
    }
    func setupplayer(){
        flappy.position = CGPoint(x: size.width * 0.2, y: size.height * 0.4)
        flappy.zPosition = 3
        flappy.setScale(1.5)
        self.addChild(flappy)
    }
    func updatePlayer(){
        let gravity = CGVector(dx:0, dy:kGravity)
        let gravityStep = gravity.dy * CGFloat(dt)
        playerVelocity += gravityStep
        
        //Apply Velocity
        
        let velocityStep = playerVelocity * CGFloat(dt)
        flappy.position.y += velocityStep
    }
    func flapPlayer(){
        playerVelocity = CGFloat(kImpulse)
    }
    func createPoles(){
        polePair = SKNode()
        
        let topPole = SKSpriteNode(imageNamed: "TubeTop")
        let btmPole = SKSpriteNode(imageNamed: "TubeBottom")
        
        let height = UInt32( self.frame.size.height / 4)
        let y = CGFloat(arc4random_uniform(height) + height)
        
        let verticalPipeGap: CGFloat = 150.0
        
        
        topPole.position = CGPoint(x: self.frame.width, y: y + topPole.size.height / 2 + verticalPipeGap)
        btmPole.position = CGPoint(x: self.frame.width, y: y - btmPole.size.height / 2)
        
        topPole.physicsBody = SKPhysicsBody(rectangleOfSize: topPole.size)
        topPole.physicsBody?.categoryBitMask = PhysicsCategory.Pole
        topPole.physicsBody?.collisionBitMask = PhysicsCategory.Flappy
        topPole.physicsBody?.contactTestBitMask = PhysicsCategory.Flappy
        topPole.physicsBody?.dynamic = false
        topPole.physicsBody?.affectedByGravity = false
        
        btmPole.physicsBody = SKPhysicsBody(rectangleOfSize: btmPole.size)
        btmPole.physicsBody?.categoryBitMask = PhysicsCategory.Pole
        btmPole.physicsBody?.collisionBitMask = PhysicsCategory.Flappy
        btmPole.physicsBody?.contactTestBitMask = PhysicsCategory.Flappy
        btmPole.physicsBody?.dynamic = false
        btmPole.physicsBody?.affectedByGravity = false
        
        polePair.addChild(topPole)
        polePair.addChild(btmPole)
        
        polePair.zPosition = 1
        
        polePair.runAction(moveAndRemove)
        self.addChild(polePair)
        
        
    }

}