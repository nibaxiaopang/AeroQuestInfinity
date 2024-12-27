//
//  ViewController.swift
//  AeroQuestInfinity
//
//  Created by AeroQuest Infinity on 2024/12/27.
//

import UIKit
import SpriteKit
import GameplayKit

class AeroQuestFlyLRViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = SKView(frame: self.view.bounds)
        self.view.addSubview(skView)
        
        let scene = AeroQuestGameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = true
        
        
        let buttonBack = UIButton(frame: CGRect(x: 24, y: 60, width: 44, height: 44))
        buttonBack.setImage(UIImage(named: "leftArrow"), for: .normal)
        buttonBack.addTarget(self, action: #selector(backTapped(_: )), for: .touchUpInside)
        view.addSubview(buttonBack)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    @objc func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    

}

