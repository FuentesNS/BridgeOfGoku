//
//  HomeGameScene.swift
//  BridgeOfGoku
//
//  Created by MacBookMBA1 on 01/11/22.
//

import Foundation
import SpriteKit


class HomeGameScene: SKScene, SKPhysicsContactDelegate{
    
    var GokuCloud: SKEmitterNode!
    var FallingLeaf: SKEmitterNode!
    let Gravity:CGFloat = -100.0
    
    
    override func didMove(to view: SKView) {
        
        
        
        FallingLeaf = SKEmitterNode(fileNamed: "FallingLeaf")
        FallingLeaf.position = CGPoint(x: 800, y: 2000)
        FallingLeaf.advanceSimulationTime(10)
        self.addChild(FallingLeaf)
        FallingLeaf.zPosition = 2
        
        
        GokuCloud = SKEmitterNode(fileNamed: "GokuInCloud")
        GokuCloud.position = CGPoint(x: 0, y: 1200)
        GokuCloud.advanceSimulationTime(30)
        self.addChild(GokuCloud)
        GokuCloud.zPosition = 2
        
        
        
        loadBackground()
        loadNameApp()
        
        
    }
    
    func loadBackground(){
        guard let _ = childNode(withName: "background") as! SKSpriteNode? else {
            let texture = SKTexture(image: UIImage(named: "Background.jpg")!)
            let node = SKSpriteNode(texture: texture)
            node.size = texture.size()
            node.zPosition = GokuGameSceneZposition.BackgroundZposition.rawValue
            node.position = CGPoint(x: 500, y: 500)
            self.physicsWorld.gravity = CGVector(dx: 0, dy: Gravity)
            
            addChild(node)
            return
        }
    }
    
    
    func loadNameApp(){
        guard let _ = childNode(withName: "background") as! SKSpriteNode? else {
            let texture = SKTexture(image: UIImage(named: "LogoApp.png")!)
            let node = SKSpriteNode(texture: texture)
            node.size = texture.size()
            node.zPosition = 2
            node.position = CGPoint(x: 800, y: 1700)
            self.physicsWorld.gravity = CGVector(dx: 0, dy: Gravity)
            
            addChild(node)
            return
        }
    }
    
}
 

