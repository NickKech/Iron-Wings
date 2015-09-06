//
//  GameScene.swift
//
//  Created by Nikolaos Kechagias on 02/09/15.
//  Copyright (c) 2015 Your Name. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    /* 1 */
    let soundMessage = SKAction.playSoundFileNamed("Message.m4a", waitForCompletion: false)
    let soundGameOver = SKAction.playSoundFileNamed("GameOver.m4a", waitForCompletion: false)
    let soundScore = SKAction.playSoundFileNamed("Score.m4a", waitForCompletion: false)
    let soundFly = SKAction.playSoundFileNamed("Fly.m4a", waitForCompletion: false)
    
    /* 2 */
    let wallHeight: CGFloat = 118
    
    // Helpful variables for the scrolling
    var delta = 0.0
    var lastUpdate = 0.0
    
    var backgroundLayer = SKNode() 	// Background Layer
    let backgroundSpeed = 50.0     // Speed of the background layer
    
    var foregroundLayer = SKNode() // Foreground Layer
    let foregroundSpeed = 150.0    // Speed of the foreground layer
    
    let columnsLayer = SKNode()  // Columns Layer
    
    var bird = SKSpriteNode() // Image of the bird
    
    var gameState: GameState = .Ready
    
    /* 1 */
    var scoreLabel = LabelNode(fontNamed: "Gill Sans Bold Italic") // Displays the score
    /* 2 */
    var score: Int = 0 {                                // Holds the score
        didSet {
            /* 3 */
            if score > best {
                best = score
            }
            /* 4 */
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    /* 5 */
    var bestScoreLabel = LabelNode(fontNamed: "Gill Sans Bold Italic") // Displays the score
    /* 6 */
    var best: Int = 0 {                                // Holds the score
        didSet {
            /* 7 */
            bestScoreLabel.text = "Best: \(best)"
        }
    }
    
    /* 3 */
    override func didMoveToView(view: SKView) {
        /* Init Physics World */
        initPhysicsWorld()
        
        /* Init Background */
        initBackground()
        
        /* Init Foreground */
        initForeground()
        
        /* Init Bird */
        initBird()
        
        /* Init HUD */
        initHUD()
        
        /* Show Start Game Message */
        showMessage("StartGame")
    }
    
    // MARK: - Helpful Functions
    /* 1 */
    func degreesRadians(value: CGFloat) -> CGFloat {
        return CGFloat(M_PI) * value / 180.0
    }
    
    /* 2 */
    func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if value > max {
            return max
        } else if value < min {
            return min
        } else {
            return value
        }
    }
    
    /* 3 */
    func random(min: UInt32, max: UInt32) -> Int {
        return Int(arc4random_uniform(max - min) + min)
    }
    
    // MARK: - Set Background
    func initBackground() {
        /* 1 */
        addChild(backgroundLayer)
        
        /* 2 */
        for index in 0 ... 1 {
            let background = SKSpriteNode(imageNamed: "Background")
            background.name = "Background"
            background.anchorPoint = CGPointZero
            background.position = CGPoint(x: CGFloat(index) * background.size.width, y: 0)
            background.zPosition = zOrderValue.Background.rawValue
            backgroundLayer.addChild(background)
        }
    }
    
    func scrollBackground() {
        /* 1 */
        let stepX = -backgroundSpeed * delta
        backgroundLayer.position = CGPoint(x: backgroundLayer.position.x + CGFloat(stepX), y: 0)
        
        /* 2 */
        backgroundLayer.enumerateChildNodesWithName("Background") { (child, index) in
            /* 3 */
            let backgroundPosition = self.backgroundLayer.convertPoint(child.position, toNode: self)
            /* 4 */
            if backgroundPosition.x <= -child.frame.size.width {
                child.position = CGPoint(x: child.position.x + child.frame.size.width * 2, y: child.position.y)
            }
        }
    }
    
    // MARK: - Set Foreground
    func initForeground() {
        /* 1 */
        addChild(foregroundLayer)
        
        /** Top Wall */
        /* 2 */
        for index in 0 ..< 2 {
            /* 4 */
            let top = SKSpriteNode(imageNamed: "ForegroundTop")
            top.name = "Foreground"
            top.anchorPoint = CGPointZero
            top.position = CGPoint(x: CGFloat(index) * top.size.width, y: size.height - top.size.height)
            top.zPosition = zOrderValue.Foreground.rawValue
            foregroundLayer.addChild(top)
            
            /* 5 */
            top.physicsBody = SKPhysicsBody(rectangleOfSize: top.size, center: CGPoint(x: top.size.width * 0.50, y: top.size.height * 0.50 + 20))
            top.physicsBody?.dynamic = false
            
            /* 6 */
            top.physicsBody?.categoryBitMask = ColliderCategory.Wall.rawValue
        }
        
        /** Bottom Wall */
        /* 3 */
        for index in 0 ..< 2 {
            /* 4 */
            let bottom = SKSpriteNode(imageNamed: "ForegroundBottom")
            bottom.name = "Foreground"
            bottom.anchorPoint = CGPointZero
            bottom.position = CGPoint(x: CGFloat(index) * bottom.size.width, y: 0)
            bottom.zPosition = zOrderValue.Foreground.rawValue
            foregroundLayer.addChild(bottom)
            
            /* 5 */
            bottom.physicsBody = SKPhysicsBody(rectangleOfSize: bottom.size, center: CGPoint(x: bottom.size.width * 0.50, y: bottom.size.height * 0.50 - 20))
            bottom.physicsBody?.dynamic = false
            
            /* 6 */
            bottom.physicsBody?.categoryBitMask = ColliderCategory.Wall.rawValue
        }
    }
    
    func scrollForeground() {
        /* 1 */
        let stepX = -foregroundSpeed * delta
        /* 2 */
        foregroundLayer.position = CGPoint(x: foregroundLayer.position.x + CGFloat(stepX), y: 0)
        /* 3 */
        foregroundLayer.enumerateChildNodesWithName("Foreground") { (child, index) in
            /* 4 */
            let foregroundPosition = self.foregroundLayer.convertPoint(child.position, toNode: self)
            /* 5 */
            if foregroundPosition.x <= -child.frame.size.width {
                child.position = CGPoint(x: child.position.x + child.frame.size.width * 2, y: child.position.y)
            }
        }
    }
    
    // MARK: - Init Physics World
    func initPhysicsWorld() {
        /* 1 */
        physicsWorld.gravity = CGVectorMake(0, -5)
        
        /* 2 */
        physicsWorld.contactDelegate = self
        
        /* 3 */
        physicsWorld.speed = 0
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if gameState != .Playing {
            return
        }
        
        /* 1 */
        let categoryA = contact.bodyA.categoryBitMask;
        let categoryB = contact.bodyB.categoryBitMask;
        
        /* 2 */
        if categoryA == ColliderCategory.Bird.rawValue && categoryB == ColliderCategory.Wall.rawValue {
            gameOver()
        } else if categoryB == ColliderCategory.Bird.rawValue && categoryA == ColliderCategory.Wall.rawValue {
            gameOver()
        } else if categoryA == ColliderCategory.Bird.rawValue && categoryB == ColliderCategory.Coin.rawValue {
            contact.bodyB.node?.removeFromParent()
            /* Step 3: Update Score */
            updateScore()
        } else if categoryB == ColliderCategory.Bird.rawValue && categoryA == ColliderCategory.Coin.rawValue {
            contact.bodyA.node?.removeFromParent()
            /* Step 3: Update Score */
            updateScore()
        }
    }
    
    // MARK: - Add Bird
    func initBird() {
        /* 1 */
        bird = SKSpriteNode(imageNamed: "Bird-1")
        bird.name = "Bird"
        bird.zPosition = zOrderValue.Bird.rawValue
        bird.position = CGPoint(x: size.width * 0.25, y: size.height * 0.50)
        addChild(bird)
        
        /* 2 */
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.5)
        bird.physicsBody?.restitution = 0.0
        bird.physicsBody?.allowsRotation = false
        
        /* 3 */
        bird.physicsBody?.categoryBitMask = ColliderCategory.Bird.rawValue
        /* 4 */
        bird.physicsBody?.collisionBitMask = ColliderCategory.Wall.rawValue
        /* 5 */
        bird.physicsBody?.contactTestBitMask = ColliderCategory.Wall.rawValue | ColliderCategory.Coin.rawValue
        
        /* 6 */
        let texture1 = SKTexture(imageNamed: "Bird-1")
        let texture2 = SKTexture(imageNamed: "Bird-2")
        let texture3 = SKTexture(imageNamed: "Bird-3")
        let textures=[texture1, texture2, texture3, texture2]
        
        /* 7 */
        bird.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: 0.25)))
    }
    
    // MARK: - Set Columns
    func addPairOfColumns(){
        /* 1 */
        let gapHeight = CGFloat(randomGapHeight())
        
        /* 2 */
        let height = size.height
        let min = wallHeight + gapHeight * 0.50
        let max = height - wallHeight - gapHeight * 0.50
        let positionY = CGFloat(random(UInt32(min), max: UInt32(max)))
        
        /* 3 */
        let pairOfColumns = SKNode()
        pairOfColumns.name = "PairOfColumns"
        pairOfColumns.position = CGPoint(x: size.width * 1.25, y: positionY)
        pairOfColumns.zPosition = zOrderValue.Wall.rawValue
        columnsLayer.addChild(pairOfColumns)
        
        /* 4 */
        let coin = addCoin()
        pairOfColumns.addChild(coin)
        
        let center = coin.position
        
        /* 5 */
        let bottomBlock = createBlock()
        bottomBlock.position = CGPoint(x: center.x, y: center.y - (gapHeight + bottomBlock.size.height) * 0.50)
        pairOfColumns.addChild(bottomBlock)
        
        let blockHeight = bottomBlock.size.height - bottomBlock.size.height * 0.50
        
        let bottomColumn = createColumn()
        bottomColumn.position = CGPoint(x: center.x, y: bottomBlock.position.y - (blockHeight + bottomColumn.size.height) * 0.50)
        pairOfColumns.addChild(bottomColumn)
        
        /* 6 */
        let topBlock = createBlock()
        topBlock.position = CGPoint(x: center.x, y: center.y + (gapHeight + topBlock.size.height) * 0.50)
        pairOfColumns.addChild(topBlock)
        
        let topColumn = createColumn()
        topColumn.position = CGPoint(x: center.x, y: topBlock.position.y + (blockHeight + topColumn.size.height) * 0.50)
        pairOfColumns.addChild(topColumn)
        
        /* 7 */
        let distance = CGFloat(size.width * 1.25 + 2.0 * topBlock.size.width)
        let duration = NSTimeInterval(0.01 * distance)
        let move = SKAction.moveByX(-distance, y: 0.0, duration: duration)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([move, remove])
        pairOfColumns.runAction(sequence)
    }
    
    func randomGapHeight() -> Float {
        let height = random(170, max: 200)
        return Float(height)
    }
    
    func addCoin() -> SKSpriteNode {
        /* 1 */
        let coin = SKSpriteNode(imageNamed: "Coin-1")
        coin.zPosition = zOrderValue.Coin.rawValue
        
        /* 2 */
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.height * 0.50)
        coin.physicsBody?.dynamic = false
        
        /* 3*/
        coin.physicsBody?.categoryBitMask = ColliderCategory.Coin.rawValue
        
        /* 4 */
        var textures = [SKTexture]()
        for index in 1 ... 8 {
            let texture = SKTexture(imageNamed: "Coin-\(index)")
            textures.append(texture)
        }
        
        /* 5 */
        coin.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: 0.25)))
        
        return coin
    }
    
    func createBlock() -> SKSpriteNode {
        /* 1 */
        let block = SKSpriteNode(imageNamed: "Block")
        block.name = "Block"
        block.zPosition = zOrderValue.Block.rawValue
        
        /* 2 */
        block.physicsBody = SKPhysicsBody(rectangleOfSize: block.size)
        block.physicsBody?.dynamic = false
        
        /* 3 */
        block.physicsBody?.categoryBitMask = ColliderCategory.Wall.rawValue
        
        return block
    }
    
    
    func createColumn() -> SKSpriteNode {
        /* 1 */
        let column = SKSpriteNode(imageNamed: "Column")
        column.name = "Column"
        column.zPosition = zOrderValue.Wall.rawValue
        /* 2 */
        column.physicsBody = SKPhysicsBody(rectangleOfSize: column.size)
        column.physicsBody?.dynamic = false
        
        /* 3 */
        column.physicsBody?.categoryBitMask = ColliderCategory.Wall.rawValue
        column.physicsBody?.contactTestBitMask = ColliderCategory.Bird.rawValue
        
        return column
    }
    
    func initColumns() {
        /* 1 */
        addChild(columnsLayer)
        
        /* 2 */
        let spawn = SKAction.runBlock() {
            self.addPairOfColumns()
        }
        
        let delay = SKAction.waitForDuration(4.0)
        let sequence = SKAction.sequence([spawn, delay])
        let forever = SKAction.repeatActionForever(sequence)
        runAction(forever)
    }
    
    // MARK: - Game States
    func startGame() {
        /* 1 */
        initColumns()
        
        /* 2 */
        physicsWorld.speed = 1.0
        
        /* Reset Score */
        score = 0
    }
    
    func gameOver() {
        /* 1 */
        gameState = .GameOver
        showMessage("GameOver")
        runAction(soundGameOver)
        
        /* Save Best Score */
        saveBestScore()
        
        /* 2 */
        let rotate = SKAction.rotateToAngle(0, duration: 0)
        bird.runAction(rotate, completion:{
            self.physicsWorld.speed = 0
            self.removeAllActions()
            self.columnsLayer.removeFromParent()
        })
    }
    
    func startNewGame() {
        /* 1 Creates a new GameScene*/
        let scene = GameScene(size: size)
        
        /* 2 Replace the old scene with new*/
        self.scene?.view?.presentScene(scene)
    }

    
    
    func showMessage(imageNamed: String) {
        /* 1 */
        let panel = SKSpriteNode(imageNamed: imageNamed)
        panel.zPosition = zOrderValue.Message.rawValue
        panel.position = CGPoint(x: size.width * 0.65, y: -size.height)
        panel.name = imageNamed
        addChild(panel)
        
        /* 2 */
        let move = SKAction.moveTo(CGPoint(x: size.width * 0.65, y: size.height * 0.50), duration: 0.5)
        panel.runAction(SKAction.sequence([soundMessage, move]))
    }
    
    
    // MARK: - Add HUD
    func initHUD() {
        /* 1 */
        scoreLabel.fontSize = 48
        scoreLabel.zPosition = zOrderValue.Hud.rawValue
        scoreLabel.position = CGPoint(x: size.width * 0.25, y: size.height - 48)
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)
        
        /* 2 */
        bestScoreLabel.fontSize = 48
        bestScoreLabel.zPosition = zOrderValue.Hud.rawValue
        bestScoreLabel.position = CGPoint(x: size.width * 0.75, y: size.height - 48)
        bestScoreLabel.text = "Best: \(best)"
        addChild(bestScoreLabel)
        
        /* 3 */
        score = 0
        
        /* 4 */
        best = loadBestScore()
    }
    
    // MARK: - Save/Load Best score
    func saveBestScore() {
        if score > loadBestScore() {
            NSUserDefaults.standardUserDefaults().setInteger(best, forKey: "kBestScore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func loadBestScore() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey("kBestScore")
    }
    
    // MARK: - Score
    func updateScore() {
        /* 1 */
        runAction(soundScore)
        score += 1
    }
    
    // MARK: - Update
    override func update(currentTime: CFTimeInterval) {
        
        /* 1 */
        if lastUpdate == 0.0 {
            delta = 0
        }else{
            delta = currentTime - lastUpdate
        }
        lastUpdate = currentTime
        
        /* 2 */
        scrollBackground()
        scrollForeground()
        
        let curSpeedX = bird.physicsBody!.velocity.dx
        let curSpeedY = bird.physicsBody!.velocity.dy
        let maxSpeedY: CGFloat = 320
        
        if curSpeedY > maxSpeedY {
            bird.physicsBody?.velocity = CGVectorMake(CGFloat(curSpeedX), maxSpeedY)
        }
        
        /* 2 */
        bird.zRotation = clamp(-1, max: 0.0, value: curSpeedY * (curSpeedY < 0 ? 0.003 : 0.001))
        
        /* 3 */
        bird.position.x = size.width * 0.25
    }

    // MARK: - Touches
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* 1 */
        if gameState == .Ready {
            let startGameMessage = childNodeWithName("StartGame") as! SKSpriteNode
            gameState = .Playing
            startGameMessage.removeFromParent()
            startGame()
        }
        
        /* 2 */
        if gameState == .GameOver {
           startNewGame()
        }
        
        /* 3 */
        if gameState == .Playing {
            runAction(soundFly)
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 80))
        }
    }
   
}
