//
//  HomeViewController.swift
//  BridgeOfGoku
//
//  Created by MacBookMBA1 on 01/11/22.
//

import UIKit
import SpriteKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let scene = HomeGameScene(size:CGSize(width: DefinedScreenWidth, height: DefinedScreenHeight))
        
        // Configure the view.
        let skView = self.view as! SKView
//        skView.showsFPS = true
//        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
    }
    
}
