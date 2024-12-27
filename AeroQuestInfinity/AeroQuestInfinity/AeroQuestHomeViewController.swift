//
//  HomeVC.swift
//  AeroQuestInfinity
//
//  Created by AeroQuest Infinity on 2024/12/27.
//


import UIKit

class AeroQuestHomeViewController: UIViewController {

    //MARK: - Declare IBOutlets
    @IBOutlet var views: [UIView]!
    
    
    //MARK: - Declare Variables
    
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        for viewRadius in views {
            let radius = (UIScreen.main.bounds.width - 48) / 2
            viewRadius.layer.cornerRadius = radius / 2
        }
    }
    
    //MARK: - Functions
    
    
    //MARK: - Declare IBAction
    
}
