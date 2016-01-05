//
//  GameScene.swift
//  first game
//
//  Created by 迫 佑樹 on 2016/01/04.
//  Copyright (c) 2016年 迫 佑樹. All rights reserved.
//

import SpriteKit
import AVFoundation


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var score = 0
    var scoreLabel = SKLabelNode()
    var gameoverLabel = SKLabelNode()
    
    var bg = SKSpriteNode()
    var bird = SKSpriteNode()
    var pipe1 = SKSpriteNode()
    var pipe2 = SKSpriteNode()
    
    var movingObjects = SKSpriteNode()
    var labelContainer = SKSpriteNode()
    
    var gameover = false
    
    enum ColliderType: UInt32{
        case Bird = 1
        case Object = 2
        case Gap = 4
        //一意性のため2倍ずつ...
    }
    
    func makeBackGround(){
        let bgTexture = SKTexture(imageNamed: "bg.png")
        
        let movebg = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: 9)
        let replacebg = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        let moveBackgroud = SKAction.repeatActionForever(SKAction.sequence([movebg,replacebg]))
        
        for var i:CGFloat=0 ; i<3 ; i++ {
            
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: bgTexture.size().width*(i+0.5), y: CGRectGetMidY(self.frame))
            bg.size.height = self.frame.height
            
            bg.zPosition = -5
            bg.runAction(moveBackgroud)
            
            movingObjects.addChild(bg)
            
        }
    }
    
    
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        self.addChild(movingObjects)
        self.addChild(labelContainer)
        
        
        //view did loadメソッド的な
        
        makeBackGround()
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame) , self.frame.size.height - 70)
        
        self.addChild(scoreLabel)
        
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        
        let animation = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatActionForever(animation)
        
        bird = SKSpriteNode(texture: birdTexture)
        
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        
        bird.runAction(makeBirdFlap)

        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height/2)
        bird.physicsBody!.dynamic = true
        bird.physicsBody?.allowsRotation = false
        //重力
        
        
        //衝突検知
        bird.physicsBody?.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        
        
        self.addChild(bird)
        
        let ground = SKNode()
        
        ground.position = CGPointMake(0,0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        ground.physicsBody!.dynamic = false
        
        //衝突検知
        ground.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(ground)
        


        _ = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("makePipes"), userInfo: nil, repeats: true)
        

    }
    
    
    func makePipes(){
        let gapHeight = bird.size.height * 4
        
        
        let movementAmount = CGFloat(arc4random() % UInt32(self.frame.size.height / 2)) - self.frame.size.height/4
        
        let movePipes = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width/100.0))
        
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes,removePipes])
        
        
        
        
        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        let pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeTexture.size().height/2 + gapHeight/2 + movementAmount)
        
        pipe1.runAction(moveAndRemovePipes)

        
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture.size())
        pipe1.physicsBody?.dynamic = false
        
        pipe1.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        movingObjects.addChild(pipe1)
        
        
        let pipeTexture2 = SKTexture(imageNamed: "pipe2.png")
        let pipe2 = SKSpriteNode(texture: pipeTexture2)
        pipe2.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - pipeTexture2.size().height/2 - gapHeight/2 + movementAmount)
        
        
        pipe2.runAction(moveAndRemovePipes)
        
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture.size())
        pipe2.physicsBody?.dynamic = false
        
        pipe2.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        movingObjects.addChild(pipe2)
        
        
        let gap = SKNode()
        gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y:  CGRectGetMidY(self.frame) + movementAmount)
        gap.runAction(moveAndRemovePipes)
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe1.size.width, gapHeight))
        gap.physicsBody!.dynamic = false
        
        gap.physicsBody?.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody?.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        
        //categoryBitMaskとContactTestBitMaskの論理積が0以外になった時にdidBeginContactが呼ばれる
        
        movingObjects.addChild(gap)
        
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue{
            score++
            
            scoreLabel.text = "\(score)"
        } else {
            
            if gameover == false {
            
                gameover = true
                self.speed = 0
                
                gameoverLabel.fontName = "Helvetica"
                gameoverLabel.fontSize = 30
                
                gameoverLabel.text = "Game Over!!! "
                gameoverLabel.color = UIColor.redColor()
                
                gameoverLabel.zPosition = 5
                gameoverLabel.position = CGPointMake(CGRectGetMidX(self.frame) , CGRectGetMidY(self.frame))
                
                labelContainer.addChild(gameoverLabel)
            }
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       //画面をタッチした時の処理
        if gameover == false{
            bird.physicsBody!.velocity = CGVectorMake(0,0)
            bird.physicsBody!.applyImpulse(CGVectorMake(0, 50))
        } else {
            score = 0
            scoreLabel.text = "0"
            scoreLabel.zPosition = 5
            bird.physicsBody!.velocity = CGVectorMake(0, 0)
            
            movingObjects.removeAllChildren()
            
            makeBackGround()
            
            self.speed = 1
            
            gameover = false
            
            labelContainer.removeAllChildren()
        }
    }
    
        override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
