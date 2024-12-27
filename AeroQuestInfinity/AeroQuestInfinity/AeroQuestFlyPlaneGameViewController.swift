//
//  FlyPlaneGameVC.swift
//  AeroQuestInfinity
//
//  Created by AeroQuest Infinity on 2024/12/27.
//


import UIKit

class AeroQuestFlyPlaneGameViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var planeImageView: UIImageView!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var upLeftButton: UIButton!   // New button for up-left diagonal
    @IBOutlet weak var upRightButton: UIButton!  // New button for up-right diagonal
    @IBOutlet weak var downLeftButton: UIButton! // New button for down-left diagonal
    @IBOutlet weak var downRightButton: UIButton! // New button for down-right diagonal
    
    // MARK: - Properties
    var obstacleImageView: UIImageView!
    var gameTimer: Timer!
    var planeSpeed: CGFloat = 50.0
    var obstacleSpeed: CGFloat = 5.0
    var isGameOver = false
    
    var steadyImage: UIImage!
    var upImage: UIImage!
    var downImage: UIImage!
    var leftImage: UIImage!
    var rightImage: UIImage!
    var upLeftImage: UIImage!
    var upRightImage: UIImage!
    var downLeftImage: UIImage!
    var downRightImage: UIImage!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
    }
    
    // MARK: - Game Setup
    private func setupGame() {
        // Set up plane images
        steadyImage = UIImage(named: "plane_steady")
        upImage = UIImage(named: "plane_up")
        downImage = UIImage(named: "plane_down")
        leftImage = UIImage(named: "plane_left")
        rightImage = UIImage(named: "plane_right")
        upLeftImage = UIImage(named: "plane_up_left")
        upRightImage = UIImage(named: "plane_up_right")
        downLeftImage = UIImage(named: "plane_down_left")
        downRightImage = UIImage(named: "plane_down_right")
        
        // Set up initial plane image
        // Set up initial plane image
        planeImageView.image = steadyImage
        planeImageView.frame = CGRect(x: 50, y: view.frame.midY, width: 50, height: 50)
        
        // Initial position to avoid reset issues
        print("Initial plane position: \(planeImageView.frame.origin)")
        
        // Set up obstacle
        obstacleImageView = UIImageView(image: UIImage(named: "obstacle"))
        obstacleImageView.frame = CGRect(x: view.frame.width, y: CGFloat.random(in: 0...view.frame.height - 50), width: 50, height: 50)
        view.addSubview(obstacleImageView)
        
        // Start game timer
        gameTimer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(gameLoop), userInfo: nil, repeats: true)
        
        
        
    }
    
    // MARK: - Actions
    @IBAction func upButtonTapped(_ sender: UIButton) {
        planeImageView.image = upImage
        movePlane(direction: .up)
    }
    
    @IBAction func downButtonTapped(_ sender: UIButton) {
        planeImageView.image = downImage
        movePlane(direction: .down)
    }
    
    @IBAction func leftButtonTapped(_ sender: UIButton) {
        planeImageView.image = leftImage
        movePlane(direction: .left)
    }
    
    @IBAction func rightButtonTapped(_ sender: UIButton) {
        planeImageView.image = rightImage
        movePlane(direction: .right)
    }
    
    @IBAction func upLeftButtonTapped(_ sender: UIButton) {
        planeImageView.image = upLeftImage
        movePlane(direction: .upLeft)
    }
    
    @IBAction func upRightButtonTapped(_ sender: UIButton) {
        planeImageView.image = upRightImage
        movePlane(direction: .upRight)
    }
    
    @IBAction func downLeftButtonTapped(_ sender: UIButton) {
        planeImageView.image = downLeftImage
        movePlane(direction: .downLeft)
    }
    
    @IBAction func downRightButtonTapped(_ sender: UIButton) {
        planeImageView.image = downRightImage
        movePlane(direction: .downRight)
    }
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Game Logic
    private func movePlane(direction: Direction) {
        guard !isGameOver else { return }

        // Get the current position of the plane
        let currentX = planeImageView.frame.origin.x
        let currentY = planeImageView.frame.origin.y

        // Calculate the vertical movement boundaries
        let topLimit = UIScreen.main.bounds.height / 4 + 144
        let bottomLimit = UIScreen.main.bounds.height - 214

        // Initialize new position with current values
        var newX = currentX
        var newY = currentY

        // Adjust the position based on the direction
        switch direction {
        case .up:
            newY = currentY - planeSpeed // Decrement Y for upward movement
        case .down:
            newY = currentY + planeSpeed // Increment Y for downward movement
        case .left:
            newX = currentX - planeSpeed // Decrement X for leftward movement
        case .right:
            newX = currentX + planeSpeed // Increment X for rightward movement
        case .upLeft:
            newX = currentX - planeSpeed // Diagonal movement
            newY = currentY - planeSpeed
        case .upRight:
            newX = currentX + planeSpeed
            newY = currentY - planeSpeed
        case .downLeft:
            newX = currentX - planeSpeed
            newY = currentY + planeSpeed
        case .downRight:
            newX = currentX + planeSpeed
            newY = currentY + planeSpeed
        }

        // Ensure the new X position is within bounds
        if newX >= 0 && newX <= UIScreen.main.bounds.width - planeImageView.frame.width {
            planeImageView.frame.origin.x = newX
        }

        // Ensure the new Y position is within bounds
        if newY >= topLimit && newY <= bottomLimit {
            planeImageView.frame.origin.y = newY
        }

        print("Plane position after move: (\(planeImageView.frame.origin.x), \(planeImageView.frame.origin.y))")
    }
    
    
    
    
    
    // MARK: - Game Loop
    @objc private func gameLoop() {
        guard !isGameOver else { return }
        
        // Move obstacle vertically (up and down)
        obstacleImageView.frame.origin.y += obstacleSpeed
        
        // Check for collision
        if planeImageView.frame.intersects(obstacleImageView.frame) {
            gameOver()
        }
        
        // Reset obstacle if it moves off screen vertically
        if obstacleImageView.frame.origin.y > view.frame.height {
            resetObstacle()
        }
    }
    
    private func resetObstacle() {
        // Reset the obstacle to a random vertical position at the top
        obstacleImageView.frame.origin.y = -obstacleImageView.frame.height
        obstacleImageView.frame.origin.x = CGFloat.random(in: 0...view.frame.width - obstacleImageView.frame.width)
    }
    
    private func gameOver() {
        isGameOver = true
        gameTimer.invalidate()
        
        let alert = UIAlertController(title: "Game Over", message: "You lost!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restart", style: .default, handler: { _ in
            self.restartGame()
        }))
        present(alert, animated: true)
    }
    
    private func restartGame() {
        isGameOver = false
        planeImageView.frame.origin = CGPoint(x: 50, y: view.frame.midY)
        resetObstacle()
        gameTimer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(gameLoop), userInfo: nil, repeats: true)
    }
    
    // MARK: - Direction Enum
    enum Direction {
        case up, down, left, right, upLeft, upRight, downLeft, downRight
    }
}
