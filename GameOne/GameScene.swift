//
//  GameScene.swift
//  GameOne
//
//  Created by Михаил Зайцев on 22/03/2019.
//  Copyright © 2019 Михаил Зайцев. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield:SKEmitterNode!  // звёзное поле
    var player:SKSpriteNode!  // игрок
    var scoreLabel:SKLabelNode!  // надпись со счётом
    var score:Int = 0 {  // автоматическое обновление счёта
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var gameTimer:Timer!
    var aliens = ["alien", "alien2", "alien3"]
    
    let alienCategory:UInt32 = 0x1 << 1
    let bulletCategory:UInt32 = 0x1 << 0
    
    let motionManager = CMMotionManager ()
    var xAccelerate: CGFloat = 0
    
    
    override func didMove(to view: SKView) {
        starfield = SKEmitterNode(fileNamed: "Starfield")  // добавление файла с анимацией
        starfield.position = CGPoint(x: 0, y: 1472)  // где будет отображаться
        starfield.advanceSimulationTime(10)  // пропуск первых 10 сек анимации
        self.addChild(starfield)  // добавление объекта "звёздное поле" на экран
        
        starfield.zPosition = -10  // Отодвигаем поле на задний план
        player = SKSpriteNode(imageNamed: "shuttle")  // добавление файла-картинки с шатлом
        player.position = CGPoint (x: UIScreen.main.bounds.width / 2, y: 40)  // координаты шатла
        
        self.addChild(player)  // добавление объекта "шатл" на экран
        player.zPosition = 0
        
        self.physicsWorld.gravity = CGVector (dx: 0, dy: 0)  // отключение гравитации
        self.physicsWorld.contactDelegate = self  // отслеживание прикосновений
        
        scoreLabel = SKLabelNode(text: "Score: 0")  // надпись со счётом
        scoreLabel.fontName = "Helvetica Neue"  // шрифт надписи
        scoreLabel.fontSize = 56 // размер шрифта
        scoreLabel.fontColor = UIColor.white // цвет шрифта
        scoreLabel.position = CGPoint (x: 150, y: UIScreen.main.bounds.height - 70) // позиция надписи со счётом
        scoreLabel.zPosition = 10
        score = 0  // чёт на старте
        self.addChild(scoreLabel)  // добавление объекта "Счёт"
        
        var timeInterval = 0.75
        if UserDefaults.standard.bool(forKey: "hard") {
            timeInterval = 0.3
        }
        
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        motionManager.accelerometerUpdateInterval = 0.01
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometrData = data {
                let acceleration = accelerometrData.acceleration
                self.xAccelerate = CGFloat(acceleration.x) * 0.75 + self.xAccelerate * 0.25
            }
        }
    }
    
    override func didSimulatePhysics() {
        player.position.x += xAccelerate * 23  // скорость перемещения
        
        if player.position.x < 0 {
            player.position = CGPoint(x: UIScreen.main.bounds.width - player.size.width, y: player.position.y)
        } else if player.position.x > UIScreen.main.bounds.width {
            player.position = CGPoint(x: 20, y: player.position.y)
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var alienBody:SKPhysicsBody
        var bulletBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask { // {???
            bulletBody = contact.bodyA
            alienBody = contact.bodyB
        } else {
            bulletBody = contact.bodyB
            alienBody = contact.bodyA
        }
        
        if (alienBody.categoryBitMask & alienCategory) != 0 && (bulletBody.categoryBitMask & bulletCategory) != 0 {
            collisinElements(bulletNode: bulletBody.node as! SKSpriteNode, alienNode: alienBody.node as! SKSpriteNode)
        }
    }
    
    func collisinElements (bulletNode: SKSpriteNode, alienNode: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Vzriv")
        explosion?.position = alienNode.position
        self.addChild(explosion!)
        
        self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
        
        bulletNode.removeFromParent()
        alienNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)) {
            explosion?.removeFromParent()
        }
        
        score += 1
    } // ???}
    
    @objc func addAlien () {
        aliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: aliens) as! [String]
        
        let alien = SKSpriteNode (imageNamed: aliens[0])
        let randomPos = GKRandomDistribution (lowestValue: 25, highestValue: Int(UIScreen.main.bounds.size.width - 25))
        let pos = CGFloat(randomPos.nextInt())
        alien.position = CGPoint(x: pos, y: UIScreen.main.bounds.size.height + alien.size.height)
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = bulletCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        alien.zPosition = -5
        let animDuration:TimeInterval = 6
        
        var actions = [SKAction] ()
        actions.append(SKAction.move(to: CGPoint(x: pos, y: 0 - alien.size.height), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actions))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }
    func fireBullet () {
        self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
        
        let bullet = SKSpriteNode (imageNamed: "torpedo")
        bullet.position = player.position
        bullet.position.y += 5
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        bullet.physicsBody?.isDynamic = true
        
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = alienCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(bullet)
        
        let animDuration:TimeInterval = 0.3
        
        var actions = [SKAction] ()
        actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: UIScreen.main.bounds.size.height + bullet.size.height), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        bullet.run(SKAction.sequence(actions))

    }

    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

