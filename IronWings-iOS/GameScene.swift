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
    
    var gameState: GameState = .ready
    
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
    override func didMove(to view: SKView) {
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
        showMessage(imageNamed: "StartGame")
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
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(index) * background.size.width, y: 0)
            background.zPosition = zOrderValue.background.rawValue
            backgroundLayer.addChild(background)
        }
    }
    
    func scrollBackground() {
        /* 1 */
        let stepX = -backgroundSpeed * delta
        backgroundLayer.position = CGPoint(x: backgroundLayer.position.x + CGFloat(stepX), y: 0)
        
        /* 2 */
        backgroundLayer.enumerateChildNodes(withName: "Background") { (child, index) in
            /* 3 */
            let backgroundPosition = self.backgroundLayer.convert(child.position, to: self)
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
            top.anchorPoint = CGPoint.zero
            top.position = CGPoint(x: CGFloat(index) * top.size.width, y: size.height - top.size.height)
            top.zPosition = zOrderValue.foreground.rawValue
            foregroundLayer.addChild(top)
            
            /* 5 */
            top.physicsBody = SKPhysicsBody(rectangleOf: top.size, center: CGPoint(x: top.size.width * 0.50, y: top.size.height * 0.50 + 20))
            top.physicsBody?.isDynamic = false
            
            /* 6 */
            top.physicsBody?.categoryBitMask = ColliderCategory.wall.rawValue
        }
        
        /** Bottom Wall */
        /* 3 */
        for index in 0 ..< 2 {
            /* 4 */
            let bottom = SKSpriteNode(imageNamed: "ForegroundBottom")
            bottom.name = "Foreground"
            bottom.anchorPoint = CGPoint.zero
            bottom.position = CGPoint(x: CGFloat(index) * bottom.size.width, y: 0)
            bottom.zPosition = zOrderValue.foreground.rawValue
            foregroundLayer.addChild(bottom)
            
            /* 5 */
            bottom.physicsBody = SKPhysicsBody(rectangleOf: bottom.size, center: CGPoint(x: bottom.size.width * 0.50, y: bottom.size.height * 0.50 - 20))
            bottom.physicsBody?.isDynamic = false
            
            /* 6 */
            bottom.physicsBody?.categoryBitMask = ColliderCategory.wall.rawValue
        }
    }
    
    func scrollForeground() {
        /* 1 */
        let stepX = -foregroundSpeed * delta
        /* 2 */
        foregroundLayer.position = CGPoint(x: foregroundLayer.position.x + CGFloat(stepX), y: 0)
        /* 3 */
        foregroundLayer.enumerateChildNodes(withName: "Foreground") { (child, index) in
            /* 4 */
            let foregroundPosition = self.foregroundLayer.convert(child.position, to: self)
            /* 5 */
            if foregroundPosition.x <= -child.frame.size.width {
                child.position = CGPoint(x: child.position.x + child.frame.size.width * 2, y: child.position.y)
            }
        }
    }
    
    // MARK: - Init Physics World
    func initPhysicsWorld() {
        /* 1 */
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        
        /* 2 */
        physicsWorld.contactDelegate = self
        
        /* 3 */
        physicsWorld.speed = 0
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if gameState != .playing {
            return
        }
        
        /* 1 */
        let categoryA = contact.bodyA.categoryBitMask;
        let categoryB = contact.bodyB.categoryBitMask;
        
        /* 2 */
        if categoryA == ColliderCategory.bird.rawValue && categoryB == ColliderCategory.wall.rawValue {
            gameOver()
        } else if categoryB == ColliderCategory.bird.rawValue && categoryA == ColliderCategory.wall.rawValue {
            gameOver()
        } else if categoryA == ColliderCategory.bird.rawValue && categoryB == ColliderCategory.coin.rawValue {
            contact.bodyB.node?.removeFromParent()
            /* Step 3: Update Score */
            updateScore()
        } else if categoryB == ColliderCategory.bird.rawValue && categoryA == ColliderCategory.coin.rawValue {
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
        bird.zPosition = zOrderValue.bird.rawValue
        bird.position = CGPoint(x: size.width * 0.25, y: size.height * 0.50)
        addChild(bird)
        
        /* 2 */
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.5)
        bird.physicsBody?.restitution = 0.0
        bird.physicsBody?.allowsRotation = false
        
        /* 3 */
        bird.physicsBody?.categoryBitMask = ColliderCategory.bird.rawValue
        /* 4 */
        bird.physicsBody?.collisionBitMask = ColliderCategory.wall.rawValue
        /* 5 */
        bird.physicsBody?.contactTestBitMask = ColliderCategory.wall.rawValue | ColliderCategory.coin.rawValue
        
        /* 6 */
        let texture1 = SKTexture(imageNamed: "Bird-1")
        let texture2 = SKTexture(imageNamed: "Bird-2")
        let texture3 = SKTexture(imageNamed: "Bird-3")
        let textures=[texture1, texture2, texture3, texture2]
        
        /* 7 */
        bird.run(SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.25)))
    }
    
    // MARK: - Set Columns
    func addPairOfColumns(){
        /* 1 */
        let gapHeight = randomGapHeight()
        
        /* 2 */
        let height = size.height
        let min = wallHeight + gapHeight * 0.50
        let max = height - wallHeight - gapHeight * 0.50
        let positionY = CGFloat(random(min: UInt32(min), max: UInt32(max)))
        
        /* 3 */
        let pairOfColumns = SKNode()
        pairOfColumns.name = "PairOfColumns"
        pairOfColumns.position = CGPoint(x: size.width * 1.25, y: positionY)
        pairOfColumns.zPosition = zOrderValue.wall.rawValue
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
        let duration = TimeInterval(0.01 * distance)
        let move = SKAction.moveBy(x: -distance, y: 0.0, duration: duration)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([move, remove])
        pairOfColumns.run(sequence)
    }
    
    func randomGapHeight() -> CGFloat {
        let height = random(min: 170, max: 200)
        return CGFloat(height)
    }
    
    func addCoin() -> SKSpriteNode {
        /* 1 */
        let coin = SKSpriteNode(imageNamed: "Coin-1")
        coin.zPosition = zOrderValue.coin.rawValue
        
        /* 2 */
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.height * 0.50)
        coin.physicsBody?.isDynamic = false
        
        /* 3*/
        coin.physicsBody?.categoryBitMask = ColliderCategory.coin.rawValue
        
        /* 4 */
        var textures = [SKTexture]()
        for index in 1 ... 8 {
            let texture = SKTexture(imageNamed: "Coin-\(index)")
            textures.append(texture)
        }
        
        /* 5 */
        coin.run(SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.25)))
        
        return coin
    }
    
    func createBlock() -> SKSpriteNode {
        /* 1 */
        let block = SKSpriteNode(imageNamed: "Block")
        block.name = "Block"
        block.zPosition = zOrderValue.block.rawValue
        
        /* 2 */
        block.physicsBody = SKPhysicsBody(rectangleOf: block.size)
        block.physicsBody?.isDynamic = false
        
        /* 3 */
        block.physicsBody?.categoryBitMask = ColliderCategory.wall.rawValue
        
        return block
    }
    
    
    func createColumn() -> SKSpriteNode {
        /* 1 */
        let column = SKSpriteNode(imageNamed: "Column")
        column.name = "Column"
        column.zPosition = zOrderValue.wall.rawValue
        /* 2 */
        column.physicsBody = SKPhysicsBody(rectangleOf: column.size)
        column.physicsBody?.isDynamic = false
        
        /* 3 */
        column.physicsBody?.categoryBitMask = ColliderCategory.wall.rawValue
        column.physicsBody?.contactTestBitMask = ColliderCategory.bird.rawValue
        
        return column
    }
    
    func initColumns() {
        /* 1 */
        addChild(columnsLayer)
        
        /* 2 */
        let spawn = SKAction.run() {
            self.addPairOfColumns()
        }
        
        let delay = SKAction.wait(forDuration: 4.0)
        let sequence = SKAction.sequence([spawn, delay])
        let forever = SKAction.repeatForever(sequence)
        run(forever)
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
        gameState = .gameOver
        showMessage(imageNamed: "GameOver")
        run(soundGameOver)
        
        /* Save Best Score */
        saveBestScore()
        
        /* 2 */
        let rotate = SKAction.rotate(toAngle: 0, duration: 0)
        bird.run(rotate, completion:{
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
        panel.zPosition = zOrderValue.message.rawValue
        panel.position = CGPoint(x: size.width * 0.65, y: -size.height)
        panel.name = imageNamed
        addChild(panel)
        
        /* 2 */
        let move = SKAction.move(to: CGPoint(x: size.width * 0.65, y: size.height * 0.50), duration: 0.5)
        panel.run(SKAction.sequence([soundMessage, move]))
    }
    
    
    // MARK: - Add HUD
    func initHUD() {
        /* 1 */
        scoreLabel.fontSize = 48
        scoreLabel.zPosition = zOrderValue.hud.rawValue
        scoreLabel.position = CGPoint(x: size.width * 0.25, y: size.height - 48)
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)
        
        /* 2 */
        bestScoreLabel.fontSize = 48
        bestScoreLabel.zPosition = zOrderValue.hud.rawValue
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
            UserDefaults.standard.set(score, forKey: "kBestScore")
            UserDefaults.standard.synchronize()
        }
    }
    
    func loadBestScore() -> Int {
        return UserDefaults.standard.integer(forKey: "kBestScore")
    }
    
    // MARK: - Score
    func updateScore() {
        /* 1 */
        run(soundScore)
        score += 1
    }
    
    // MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        
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
            bird.physicsBody?.velocity = CGVector(dx: CGFloat(curSpeedX), dy: maxSpeedY)
        }
        
        /* 2 */
        bird.zRotation = clamp(min: -1, max: 0.0, value: curSpeedY * (curSpeedY < 0 ? 0.003 : 0.001))
        
        /* 3 */
        bird.position.x = size.width * 0.25
    }

    // MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* 1 */
        if gameState == .ready {
            let startGameMessage = childNode(withName: "StartGame") as! SKSpriteNode
            gameState = .playing
            startGameMessage.removeFromParent()
            startGame()
        }
        
        /* 2 */
        if gameState == .gameOver {
           startNewGame()
        }
        
        /* 3 */
        if gameState == .playing {
            run(soundFly)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 80))
        }
    }
   
}
