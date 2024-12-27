//
//  GameScene.swift
//  AeroQuestInfinity
//
//  Created by jin fu on 2024/12/27.
//

import UIKit
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var plane: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    private var resetButton: SKSpriteNode!
    private var score = 0
    private var gameOver = false
    private var leftButton: SKSpriteNode!
    private var rightButton: SKSpriteNode!
    
    let planeCategory: UInt32 = 0x1 << 0
    let obstacleCategory: UInt32 = 0x1 << 1
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        setupBackground()
        setupPlane()
        setupScoreLabel()
        setupControls()
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { [weak self] in self?.spawnObstacles() },
                SKAction.wait(forDuration: 1.5)
            ])
        ))
    }
    
    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "ic_bg")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = frame.size
        background.zPosition = -1
        addChild(background)
    }
    
    private func setupPlane() {
        plane = SKSpriteNode(imageNamed: "plane")
        plane.size = CGSize(width: 70, height: 70)
        plane.position = CGPoint(x: frame.midX, y: frame.height/6)
        plane.physicsBody = SKPhysicsBody(rectangleOf: plane.size)
        plane.physicsBody?.isDynamic = true
        plane.physicsBody?.categoryBitMask = planeCategory
        plane.physicsBody?.contactTestBitMask = obstacleCategory
        plane.physicsBody?.collisionBitMask = 0
        addChild(plane)
    }
    
    private func setupScoreLabel() {
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: frame.width/2, y: frame.height - 100)
        scoreLabel.fontName = "Noteworthy-Bold"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        addChild(scoreLabel)
    }
    
    private func setupControls() {
        // Left button
        leftButton = SKSpriteNode(color: .clear, size: CGSize(width: 80, height: 50))
        leftButton.position = CGPoint(x: 60, y: 100)
        leftButton.name = "leftButton"
        addChild(leftButton)
        
        let leftImage = SKSpriteNode(imageNamed: "leftArrow") // Replace "leftArrow" with the name of your left button image
        leftImage.size = CGSize(width: 50, height: 50) // Adjust size as needed
        leftImage.position = CGPoint(x: 0, y: 0)
        leftImage.name = "leftButton" // Match the name of the parent button
        leftButton.addChild(leftImage)
        
        // Right button
        rightButton = SKSpriteNode(color: .clear, size: CGSize(width: 80, height: 50))
        rightButton.position = CGPoint(x: frame.width - 60, y: 100)
        rightButton.name = "rightButton"
        addChild(rightButton)
        
        let rightImage = SKSpriteNode(imageNamed: "rightArrow") // Replace "rightArrow" with the name of your right button image
        rightImage.size = CGSize(width: 50, height: 50) // Adjust size as needed
        rightImage.position = CGPoint(x: 0, y: 0)
        rightImage.name = "rightButton" // Match the name of the parent button
        rightButton.addChild(rightImage)
    }

    func spawnObstacles() {
        let obstacleSize = CGSize(width: 44, height: 44)
        let obstacleGap = plane.size.width * 3
        let maxX = frame.width - obstacleGap/2
        let minX = obstacleGap/2
        
        let randomX = CGFloat.random(in: minX...maxX)
        
        let obstacle = SKSpriteNode(imageNamed: "obstacle")
        obstacle.size = obstacleSize
        obstacle.position = CGPoint(x: randomX, y: frame.height + obstacle.size.height/2)
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.categoryBitMask = obstacleCategory
        addChild(obstacle)
        
        let moveAction = SKAction.moveBy(x: 0, y: -frame.height - obstacle.size.height, duration: 3.0)
        let removeAction = SKAction.removeFromParent()
        let updateScoreAction = SKAction.run { [weak self] in
            self?.score += 10
            self?.scoreLabel.text = "Score: \(self?.score ?? 0)"
        }
        let sequence = SKAction.sequence([moveAction, updateScoreAction, removeAction])
        
        obstacle.run(sequence)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if gameOver { return }
        
        gameOver = true
        removeAllActions()
        physicsWorld.speed = 0
        
        let gameOverLabel = SKLabelNode(text: "Game Over!")
        gameOverLabel.fontName = "Noteworthy-Bold"
        gameOverLabel.fontSize = 40
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        gameOverLabel.name = "gameOverLabel"
        addChild(gameOverLabel)
        
        let resetImage = SKTexture(imageNamed: "ic_reset") // Replace with your image name
            resetButton = SKSpriteNode(texture: resetImage)
            resetButton.size = CGSize(width: 151.5789, height: 50) // Adjust size as needed
            resetButton.position = CGPoint(x: frame.midX, y: frame.midY - 50)
            resetButton.name = "resetButton"
            addChild(resetButton)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !gameOver else {
            for touch in touches {
                let location = touch.location(in: self)
                let touchedNode = atPoint(location)
                
                if touchedNode.name == "resetButton" {
                    resetGame()
                }
            }
            return
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            // Check button names
            if touchedNode.name == "leftButton" {
                plane.position.x -= 50 // Move 50 points to the left
            } else if touchedNode.name == "rightButton" {
                plane.position.x += 50 // Move 50 points to the right
            }
        }
    }


    func resetGame() {
        // Remove all children except the plane and buttons
        children.forEach { child in
            if child.name != "leftButton" && child.name != "rightButton" && child != plane {
                child.removeFromParent()
            }
        }
        setupBackground()
        setupScoreLabel()
        // Reset plane position
        plane.position = CGPoint(x: frame.midX, y: frame.height/6)
        plane.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        // Reset score
        score = 0
        scoreLabel.text = "Score: \(score)"
        
        // Reset game state
        gameOver = false
        physicsWorld.speed = 1
        
        // Restart obstacle spawning
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { [weak self] in self?.spawnObstacles() },
                SKAction.wait(forDuration: 1.5)
            ])
        ))
    }

    
    private func setupResetButton() {
        resetButton = SKSpriteNode(color: .blue, size: CGSize(width: 120, height: 50))
        resetButton.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        resetButton.name = "resetButton"
        addChild(resetButton)
        
        let resetLabel = SKLabelNode(text: "Reset")
        resetLabel.fontName = "Noteworthy-Bold"
        resetLabel.fontSize = 20
        resetLabel.fontColor = .white
        resetLabel.position = CGPoint(x: 0, y: -10)
        resetButton.addChild(resetLabel)
    }
    

    
    override func update(_ currentTime: TimeInterval) {
        if !gameOver {
            let halfWidth = plane.size.width / 2
            plane.position.x = min(max(plane.position.x, halfWidth), frame.width - halfWidth)
        }
    }
}
