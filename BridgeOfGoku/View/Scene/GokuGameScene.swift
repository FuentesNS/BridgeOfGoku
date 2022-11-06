//
//  GokuGameScene.swift
//  BridgeOfGoku
//
//  Created by Samuel Fuentes Navarrete on 31/10/22.
//

import SpriteKit
import Foundation

class GokuGameScene: SKScene, SKPhysicsContactDelegate {
    
    //MARK: Variables
    var IsBegin = false
    var IsEnd = false
    var LeftStack:SKShapeNode?
    var RightStack:SKShapeNode?
    
    
    struct GAP {
        static let XGAP:CGFloat = 20
        static let YGAP:CGFloat = 4
    }

    var GameOver = false {
        willSet {
            if (newValue) {
                CheckHighScoreAndStore()
                let gameOverLayer = childNode(withName: GokuGameSceneChildName.GameOverLayerName.rawValue) as SKNode?
                gameOverLayer?.run(SKAction.MoveDistance(CGVector(dx: 0, dy: 100), fadeInWithDuration: 0.2))
            }
            
        }
    }
    
    var Score:Int = 0 {
        willSet {
            let scoreBand = childNode(withName: GokuGameSceneChildName.ScoreName.rawValue) as? SKLabelNode
            scoreBand?.text = "\(newValue)"
            scoreBand?.run(SKAction.sequence([SKAction.scale(to: 1.5, duration: 0.1), SKAction.scale(to: 1, duration: 0.1)]))
            
            if (newValue == 1) {
                let tip = childNode(withName: GokuGameSceneChildName.TipName.rawValue) as? SKLabelNode
                tip?.run(SKAction.fadeAlpha(to: 0, duration: 0.4))
            }
        }
    }
    
    lazy var PlayAbleRect:CGRect = {
        let maxAspectRatio:CGFloat = 16.0/9.0 // iPhone 5"
        let maxAspectRatioWidth = self.size.height / maxAspectRatio
        let playableMargin = (self.size.width - maxAspectRatioWidth) / 2.0
        return CGRect(x: playableMargin, y: 0, width: maxAspectRatioWidth, height: self.size.height)
        }()
    
    lazy var WalkAction:SKAction = {
        var textures:[SKTexture] = []
        for i in 0...7 {
            let texture = SKTexture(imageNamed: "GokuCorriendo\(i + 1).png")
            textures.append(texture)
        }
        
        let action = SKAction.animate(with: textures, timePerFrame: 0.15, resize: true, restore: true)
        
        return SKAction.repeatForever(action)
        }()
    
    //MARK: - override
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        physicsWorld.contactDelegate = self
    }

    override func didMove(to view: SKView) {
        Start()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !GameOver else {
            let gameOverLayer = childNode(withName: GokuGameSceneChildName.GameOverLayerName.rawValue) as SKNode?

            let location = touches.first?.location(in: gameOverLayer!)
            let retry = gameOverLayer!.atPoint(location!)
            
        
            if (retry.name == GokuGameSceneChildName.RetryButtonName.rawValue) {
                retry.run(SKAction.sequence([SKAction.setTexture(SKTexture(imageNamed: "button_retry_down"), resize: false), SKAction.wait(forDuration: 0.3)]), completion: {[unowned self] () -> Void in
                    self.Restart()
                })
            }
            return
        }
        
        if !IsBegin && !IsEnd {
            IsBegin = true
            
            let stick = LoadStick()
            let personage = childNode(withName: GokuGameSceneChildName.PersonageName.rawValue) as! SKSpriteNode
     
            let action = SKAction.resize(toHeight: CGFloat(DefinedScreenHeight - K.StackHeight), duration: 1.5)
            stick.run(action, withKey:GokuGameSceneActionKey.StickGrowAction.rawValue)
            
            let scaleAction = SKAction.sequence([SKAction.scaleY(to: 0.9, duration: 0.05), SKAction.scaleY(to: 1, duration: 0.05)])
            let loopAction = SKAction.group([SKAction.playSoundFileNamed(GokuGameSceneEffectAudioName.StickGrowAudioName.rawValue, waitForCompletion: true)])
            stick.run(SKAction.repeatForever(loopAction), withKey: GokuGameSceneActionKey.StickGrowAudioAction.rawValue)
            personage.run(SKAction.repeatForever(scaleAction), withKey: GokuGameSceneActionKey.PersonageScaleAction.rawValue)
            
            return
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if IsBegin && !IsEnd {
            IsEnd  = true
            
            let personage = childNode(withName: GokuGameSceneChildName.PersonageName.rawValue) as! SKSpriteNode
            personage.removeAction(forKey: GokuGameSceneActionKey.PersonageScaleAction.rawValue)
            personage.run(SKAction.scaleY(to: 1, duration: 0.04))
            
            let stick = childNode(withName: GokuGameSceneChildName.StickName.rawValue) as! SKSpriteNode
            stick.removeAction(forKey: GokuGameSceneActionKey.StickGrowAction.rawValue)
            stick.removeAction(forKey: GokuGameSceneActionKey.StickGrowAudioAction.rawValue)
            stick.run(SKAction.playSoundFileNamed(GokuGameSceneEffectAudioName.StickGrowOverAudioName.rawValue, waitForCompletion: false))
            
            K.StickHeight = stick.size.height;
            
            let action = SKAction.rotate(toAngle: CGFloat(-Double.pi / 2), duration: 0.4, shortestUnitArc: true)
            let playFall = SKAction.playSoundFileNamed(GokuGameSceneEffectAudioName.StickFallAudioName.rawValue, waitForCompletion: false)
            
            stick.run(SKAction.sequence([SKAction.wait(forDuration: 0.2), action, playFall]), completion: {[unowned self] () -> Void in
                self.GokuGo(self.CheckPass())
            })
        }
    }
    
    func Start() {
        loadBackground()
        LoadScoreBackground()
        LoadScore()
        LoadTip()
        LoadGameOverLayer()
 
        LeftStack = LoadStacks(false, startLeftPoint: PlayAbleRect.origin.x)
        self.RemoveMidTouch(false, left:true)
        LoadGoku()
 
        let maxGap = Int(PlayAbleRect.width - K.StackMaxWidth - (LeftStack?.frame.size.width)!)
        
        let gap = CGFloat(RandomInRange(K.StackGapMinWidth...maxGap))
        RightStack = LoadStacks(false, startLeftPoint: K.NextLeftStartX + gap)
        
        GameOver = false
    }
    
    func Restart() {
        IsBegin = false
        IsEnd = false
        Score = 0
        K.NextLeftStartX = 0
        removeAllChildren()
        Start()
    }
    
    fileprivate func CheckPass() -> Bool {
        let stick = childNode(withName: GokuGameSceneChildName.StickName.rawValue) as! SKSpriteNode

        let rightPoint = DefinedScreenWidth / 2 + stick.position.x + K.StickHeight
        
        guard rightPoint < K.NextLeftStartX else {
            return false
        }
        
        guard ((LeftStack?.frame)!.intersects(stick.frame) && (RightStack?.frame)!.intersects(stick.frame)) else {
            return false
        }
        
        self.CheckTouchMidStack()
        
        return true
    }
    
    fileprivate func CheckTouchMidStack() {
        let stick = childNode(withName: GokuGameSceneChildName.StickName.rawValue) as! SKSpriteNode
        let stackMid = RightStack!.childNode(withName: GokuGameSceneChildName.StackMidName.rawValue) as! SKShapeNode
        
        let newPoint = stackMid.convert(CGPoint(x: -10, y: 10), to: self)
        
        if ((stick.position.x + K.StickHeight) >= newPoint.x  && (stick.position.x + K.StickHeight) <= newPoint.x + 20) {
            LoadPerfect()
            self.run(SKAction.playSoundFileNamed(GokuGameSceneEffectAudioName.StickTouchMidAudioName.rawValue, waitForCompletion: false))
            Score += 1
        }
 
    }
    
    fileprivate func RemoveMidTouch(_ animate:Bool, left:Bool) {
        let stack = left ? LeftStack : RightStack
        let mid = stack!.childNode(withName: GokuGameSceneChildName.StackMidName.rawValue) as! SKShapeNode
        if (animate) {
            mid.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
        }
        else {
            mid.removeFromParent()
        }
    }
    
    fileprivate func GokuGo(_ pass:Bool) {
        let personage = childNode(withName: GokuGameSceneChildName.PersonageName.rawValue) as! SKSpriteNode
        
        guard pass else {
            let stick = childNode(withName: GokuGameSceneChildName.StickName.rawValue) as! SKSpriteNode
            
            let dis:CGFloat = stick.position.x + K.StickHeight
            
            let overGap = DefinedScreenWidth / 2 - abs(personage.position.x)
            let disGap = K.NextLeftStartX - overGap - (RightStack?.frame.size.width)! / 2

            let move = SKAction.moveTo(x: dis, duration: TimeInterval(abs(disGap / K.GokuSpeed)))

            personage.run(WalkAction, withKey: GokuGameSceneActionKey.WalkAction.rawValue)
            personage.run(move, completion: {[unowned self] () -> Void in
                stick.run(SKAction.rotate(toAngle: CGFloat(-Double.pi), duration: 0.1))
                
                personage.physicsBody!.affectedByGravity = true
                personage.run(SKAction.playSoundFileNamed(GokuGameSceneEffectAudioName.DeadAudioName.rawValue, waitForCompletion: false))
                personage.removeAction(forKey: GokuGameSceneActionKey.WalkAction.rawValue)
                self.run(SKAction.wait(forDuration: 0.5), completion: {[unowned self] () -> Void in
                    self.GameOver = true
                })
            })

            return
        }
        
        let dis:CGFloat = K.NextLeftStartX - DefinedScreenWidth / 2 - personage.size.width / 2 - GAP.XGAP
        
        let overGap = DefinedScreenWidth / 2 - abs(personage.position.x)
        let disGap = K.NextLeftStartX - overGap - (RightStack?.frame.size.width)! / 2
        
        let move = SKAction.moveTo(x: dis, duration: TimeInterval(abs(disGap / K.GokuSpeed)))
 
        personage.run(WalkAction, withKey: GokuGameSceneActionKey.WalkAction.rawValue)
        personage.run(move, completion: { [unowned self]() -> Void in
            self.Score += 1
            
            personage.run(SKAction.playSoundFileNamed(GokuGameSceneEffectAudioName.VictoryAudioName.rawValue, waitForCompletion: false))
            personage.removeAction(forKey: GokuGameSceneActionKey.WalkAction.rawValue)
            self.MoveStackAndCreateNew()
        })
    }
    
    fileprivate func CheckHighScoreAndStore() {
        let highScore = UserDefaults.standard.integer(forKey: K.StoreScoreName)
        if (Score > Int(highScore)) {
            ShowHighScore()
            
            UserDefaults.standard.set(Score, forKey: K.StoreScoreName)
            UserDefaults.standard.synchronize()
        }
    }
    
    fileprivate func ShowHighScore() {
        self.run(SKAction.playSoundFileNamed(GokuGameSceneEffectAudioName.HighScoreAudioName.rawValue, waitForCompletion: false))
        
        let wait = SKAction.wait(forDuration: 0.4)
        let grow = SKAction.scale(to: 1.5, duration: 0.4)
        grow.timingMode = .easeInEaseOut
        let explosion = StarEmitterActionAtPosition(CGPoint(x: 0, y: 300))
        let shrink = SKAction.scale(to: 1, duration: 0.2)
       
        let idleGrow = SKAction.scale(to: 1.2, duration: 0.4)
        idleGrow.timingMode = .easeInEaseOut
        let idleShrink = SKAction.scale(to: 1, duration: 0.4)
        let pulsate = SKAction.repeatForever(SKAction.sequence([idleGrow, idleShrink]))
        
        let gameOverLayer = childNode(withName: GokuGameSceneChildName.GameOverLayerName.rawValue) as SKNode?
        let highScoreLabel = gameOverLayer?.childNode(withName: GokuGameSceneChildName.HighScoreName.rawValue) as SKNode?
        highScoreLabel?.run(SKAction.sequence([wait, explosion, grow, shrink]), completion: { () -> Void in
            highScoreLabel?.run(pulsate)
        })
    }
    
    fileprivate func MoveStackAndCreateNew() {
        let action = SKAction.move(by: CGVector(dx: -K.NextLeftStartX + (RightStack?.frame.size.width)! + PlayAbleRect.origin.x - 4, dy: 0), duration: 0.3)
        RightStack?.run(action)
        self.RemoveMidTouch(true, left:false)

        let personage = childNode(withName: GokuGameSceneChildName.PersonageName.rawValue) as! SKSpriteNode
        let stick = childNode(withName: GokuGameSceneChildName.StickName.rawValue) as! SKSpriteNode
        
        personage.run(action)
        stick.run(SKAction.group([SKAction.move(by: CGVector(dx: -DefinedScreenWidth, dy: 0), duration: 0.5), SKAction.fadeAlpha(to: 0, duration: 0.3)]), completion: { () -> Void in
            stick.removeFromParent()
        })
        
        LeftStack?.run(SKAction.move(by: CGVector(dx: -DefinedScreenWidth, dy: 0), duration: 0.5), completion: {[unowned self] () -> Void in
            self.LeftStack?.removeFromParent()
            
            let maxGap = Int(self.PlayAbleRect.width - (self.RightStack?.frame.size.width)! - K.StackMaxWidth)
            let gap = CGFloat(RandomInRange(K.StackGapMinWidth...maxGap))
            
            self.LeftStack = self.RightStack
            self.RightStack = self.LoadStacks(true, startLeftPoint:self.PlayAbleRect.origin.x + (self.RightStack?.frame.size.width)! + gap)
        })
    }
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - load node
private extension GokuGameScene {
    func loadBackground() {
        guard let _ = childNode(withName: "background") as! SKSpriteNode? else {
            let texture = SKTexture(image: UIImage(named: "Background.jpg")!)
            let node = SKSpriteNode(texture: texture)
            node.size = texture.size()
            node.zPosition = GokuGameSceneZposition.BackgroundZposition.rawValue
            self.physicsWorld.gravity = CGVector(dx: 0, dy: K.Gravity)
            
            addChild(node)
            return
        }
    }
    
    func LoadScore() {
        let scoreBand = SKLabelNode(fontNamed: "Arial")
        scoreBand.name = GokuGameSceneChildName.ScoreName.rawValue
        scoreBand.text = "0"
        scoreBand.position = CGPoint(x: 0, y: DefinedScreenHeight / 2 - 200)
        scoreBand.fontColor = SKColor.white
        scoreBand.fontSize = 100
        scoreBand.zPosition = GokuGameSceneZposition.ScoreZposition.rawValue
        scoreBand.horizontalAlignmentMode = .center
        
        addChild(scoreBand)
    }
    
    func LoadScoreBackground() {
        let back = SKShapeNode(rect: CGRect(x: 0-120, y: 1024-200-30, width: 240, height: 140), cornerRadius: 20)
        back.zPosition = GokuGameSceneZposition.ScoreBackgroundZposition.rawValue
        back.fillColor = SKColor.black.withAlphaComponent(0.3)
        back.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(back)
    }
    
    func LoadGoku() {
        let personage = SKSpriteNode(imageNamed: "GokuCorriendo1")
        personage.name = GokuGameSceneChildName.PersonageName.rawValue
        let x:CGFloat = K.NextLeftStartX - DefinedScreenWidth / 2 - personage.size.width / 2 - GAP.XGAP
        let y:CGFloat = K.StackHeight + personage.size.height / 2 - DefinedScreenHeight / 2 - GAP.YGAP
        personage.position = CGPoint(x: x, y: y)
        personage.zPosition = GokuGameSceneZposition.PersonageZposition.rawValue
        personage.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 18))
        personage.physicsBody?.affectedByGravity = false
        personage.physicsBody?.allowsRotation = false
        
        addChild(personage)
    }
    
    func LoadTip() {
        let tip = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        tip.name = GokuGameSceneChildName.TipName.rawValue
        tip.text = "Manten Precionado"
        tip.position = CGPoint(x: 0, y: DefinedScreenHeight / 2 - 350)
        tip.fontColor = SKColor.black
        tip.fontSize = 52
        tip.zPosition = GokuGameSceneZposition.TipZposition.rawValue
        tip.horizontalAlignmentMode = .center
    
        addChild(tip)
    }
    
    func LoadPerfect() {
        defer {
            let perfect = childNode(withName: GokuGameSceneChildName.PerfectName.rawValue) as! SKLabelNode?
            let sequence = SKAction.sequence([SKAction.fadeAlpha(to: 1, duration: 0.3), SKAction.fadeAlpha(to: 0, duration: 0.3)])
            let scale = SKAction.sequence([SKAction.scale(to: 1.4, duration: 0.3), SKAction.scale(to: 1, duration: 0.3)])
            perfect!.run(SKAction.group([sequence, scale]))
        }

        guard let _ = childNode(withName: GokuGameSceneChildName.PerfectName.rawValue) as! SKLabelNode? else {
            let perfect = SKLabelNode(fontNamed: "Arial")
            perfect.text = "Perfect +1"
            perfect.name = GokuGameSceneChildName.PerfectName.rawValue
            perfect.position = CGPoint(x: 0, y: -100)
            perfect.fontColor = SKColor.black
            perfect.fontSize = 50
            perfect.zPosition = GokuGameSceneZposition.PerfectZposition.rawValue
            perfect.horizontalAlignmentMode = .center
            perfect.alpha = 0
            
            addChild(perfect)
            
            return
        }
       
    }
    
    func LoadStick() -> SKSpriteNode {
        let hero = childNode(withName: GokuGameSceneChildName.PersonageName.rawValue) as! SKSpriteNode
        
        let stick = SKSpriteNode(color: SKColor.black, size: CGSize(width: 12, height: 1))
        stick.zPosition = GokuGameSceneZposition.StickZposition.rawValue
        stick.name = GokuGameSceneChildName.StickName.rawValue
        stick.anchorPoint = CGPoint(x: 0.5, y: 0);
        stick.color = .red
        stick.position = CGPoint(x: hero.position.x + hero.size.width / 2 + 18, y: hero.position.y - hero.size.height / 2)
        addChild(stick)
        
        return stick
    }
    
    func LoadStacks(_ animate: Bool, startLeftPoint: CGFloat) -> SKShapeNode {
        let max:Int = Int(K.StackMaxWidth / 10)
        let min:Int = Int(K.StackMinWidth / 10)
        let width:CGFloat = CGFloat(RandomInRange(min...max) * 10)
        let height:CGFloat = K.StackHeight
        let stack = SKShapeNode(rectOf: CGSize(width: width, height: height))
        stack.fillColor = SKColor.black
        stack.strokeColor = SKColor.purple
        stack.zPosition = GokuGameSceneZposition.StackZposition.rawValue
        stack.name = GokuGameSceneChildName.StackName.rawValue
 
        if (animate) {
            stack.position = CGPoint(x: DefinedScreenWidth / 2, y: -DefinedScreenHeight / 2 + height / 2)
            
            stack.run(SKAction.moveTo(x: -DefinedScreenWidth / 2 + width / 2 + startLeftPoint, duration: 0.3), completion: {[unowned self] () -> Void in
                self.IsBegin = false
                self.IsEnd = false
            })
            
        }
        else {
            stack.position = CGPoint(x: -DefinedScreenWidth / 2 + width / 2 + startLeftPoint, y: -DefinedScreenHeight / 2 + height / 2)
        }
        addChild(stack)
        
        // Color de en medio del stack
        let mid = SKShapeNode(rectOf: CGSize(width: 20, height: 20))
        mid.fillColor = SKColor.yellow
        mid.strokeColor = SKColor.yellow
        mid.zPosition = GokuGameSceneZposition.StackMidZposition.rawValue
        mid.name = GokuGameSceneChildName.StackMidName.rawValue
        mid.position = CGPoint(x: 0, y: height / 2 - 20 / 2)
        stack.addChild(mid)
        
        K.NextLeftStartX = width + startLeftPoint
        
        return stack
    }

    func LoadGameOverLayer() {
        let node = SKNode()
        node.alpha = 0
        node.name = GokuGameSceneChildName.GameOverLayerName.rawValue
        node.zPosition = GokuGameSceneZposition.GameOverZposition.rawValue
        addChild(node)
        
        let label = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.text = "Game Over"
        label.fontColor = SKColor.red
        label.fontSize = 150
        label.position = CGPoint(x: 0, y: 100)
        label.horizontalAlignmentMode = .center
        node.addChild(label)
        
        let retry = SKSpriteNode(imageNamed: "button_retry_up")
        retry.name = GokuGameSceneChildName.RetryButtonName.rawValue
        retry.position = CGPoint(x: 0, y: -200)
        node.addChild(retry)
        
        let highScore = SKLabelNode(fontNamed: "AmericanTypewriter")
        highScore.text = "Highscore!"
        highScore.fontColor = UIColor.white
        highScore.fontSize = 50
        highScore.name = GokuGameSceneChildName.HighScoreName.rawValue
        highScore.position = CGPoint(x: 0, y: 300)
        highScore.horizontalAlignmentMode = .center
        highScore.setScale(0)
        node.addChild(highScore)
    }
    
    //MARK: - Action
    func StarEmitterActionAtPosition(_ position: CGPoint) -> SKAction {
        let emitter = SKEmitterNode(fileNamed: "StartExplosion")
        emitter?.position = position
        emitter?.zPosition = GokuGameSceneZposition.EmitterZposition.rawValue
        emitter?.alpha = 0.6
        addChild((emitter)!)
        
        let wait = SKAction.wait(forDuration: 0.15)

        return SKAction.run({ () -> Void in
           emitter?.run(wait)
        })
    }

}
