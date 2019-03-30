//
//  MainMenu.swift
//  GameOne
//
//  Created by Михаил Зайцев on 24/03/2019.
//  Copyright © 2019 Михаил Зайцев. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {

    var starfield: SKEmitterNode!
    
    var newGameBtnNode:SKSpriteNode!
    var levelBtnNode:SKSpriteNode!
    var labelLevelNode:SKLabelNode!
    
    override func didMove(to view: SKView) {
        
        starfield = (self.childNode(withName: "starfiled_anim") as! SKEmitterNode)
        starfield.advanceSimulationTime(10)
        
        
        newGameBtnNode = (self.childNode(withName: "newGameBtn") as! SKSpriteNode)
        newGameBtnNode.texture = SKTexture(imageNamed: "newGameBtn")
        
        levelBtnNode = (self.childNode(withName: "LevelBtn") as! SKSpriteNode)
        levelBtnNode.texture = SKTexture(imageNamed: "LevelBtn")
        
        labelLevelNode = (self.childNode(withName: "LabelLevelBtn") as! SKLabelNode)

        let userLevel = UserDefaults.standard
        
        if userLevel.bool(forKey: "hard") {
            labelLevelNode.text = "HARD"
        } else {
            labelLevelNode.text = "EASY"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            if nodesArray.first?.name == "newGameBtn" {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameScene = GameScene(size: UIScreen.main.bounds.size)
                self.view?.presentScene(gameScene, transition: transition )
            } else if nodesArray.first?.name == "levelBtn" {
                changeLevel ()
            }
        }
    }
    func changeLevel () {
        let userLevel = UserDefaults.standard
        
        if labelLevelNode.text == "EASY" {
            labelLevelNode.text = "HARD"
            userLevel.set(true, forKey: "hard")
        } else {
            labelLevelNode.text = "EASY"
            userLevel.set(false, forKey: "hard")
        }
        
        userLevel.synchronize()
    }
}
