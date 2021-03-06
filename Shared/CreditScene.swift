//
//  CreditScene.swift
//  OhMyPlane
//
//  Created by HS Song on 2016. 4. 4..
//  Copyright © 2016년 softdevstory. All rights reserved.
//

import SpriteKit
import SKTUtilsExtended

class CreditScene: SKScene {

    let backgroundLayer = SKNode()
    let creditLayer = SKNode()

    var backSprite: SKSpriteNode!
    var backTextures: [SKTexture] = []
    var backPressed = false

    var creditContent = [
        "Design, Code, Art, Music",
        "HS Song",
        "",
        "Main sponsor",
        "MH Choi",
        "",
        "Tester",
        "ES Song, HS Oh, DS Choi, JH Choi",
        "",
        "Thanks to:",
        "",
        "Kenney(http://www.kenney.nl)",
        "images, sound resources",
        "",
        "RayWenderlich(https://www.raywenderlich.com)",
        "Technical hints from '2D iOS & tvOS Games by tutorials'",
        "",
        "GarageBand",
        "All musics are composed by using GarageBand loops",
        "",
        "InkScape(https://inkscape.org/)",
        "All images are modified by using InkScape."
    ]
    
    var creditLabels: [SKLabelNode] = []
    
    override func didMove(to view: SKView) {
        addChild(backgroundLayer)
        addChild(creditLayer)
        
        loadBackground()
        loadButtons()

        playBackgroundMusic()

        // for tvOS
        let scene = (self as SKScene)
        if let scene = scene as? TVControlsScene {
            scene.setupTVControls()
        }
        
        creditLayer.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run() {
            self.loadCreditLabels()
            self.positionCreditLabels()
            } ]))
    }
    
    func touchDownBack() {
        backSprite.texture = backTextures[1]
        backSprite.size = (backSprite.texture?.size())!
        backPressed = true
        
        playClickSound()
    }
    
    func doBack() {
        let scene = MainScene(size: GameSetting.SceneSize)
        scene.scaleMode = (self.scene?.scaleMode)!
        let transition = SKTransition.push(with: .up, duration: 0.6)
        view!.presentScene(scene, transition: transition)
        
        backSprite.texture = backTextures[0]
        backSprite.size = (backSprite.texture?.size())!
        backPressed = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // for tvOS
        let scene = (self as SKScene)
        if let scene = scene as? TVControlsScene {
            scene.touchOnRemoteBegan()
            return
        }
        
        let touch = touches.first
        let location = touch?.location(in: backgroundLayer)
        let node = backgroundLayer.atPoint(location!)
        
        if node == backSprite {
            touchDownBack()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if backPressed {
            doBack()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if backPressed {
            backSprite.texture = backTextures[0]
            backSprite.size = (backSprite.texture?.size())!
            backPressed = false
        }
    }

    func loadBackground() {
        let image = SKSpriteNode(imageNamed: "background_credit")
        image.anchorPoint = CGPoint.zero
        image.position = CGPoint(x: 0, y: overlapAmount() / 2)
        image.zPosition = SpriteZPosition.BackBackground
        
        backgroundLayer.addChild(image)
    }
    
    func loadButtons() {
        backTextures.append(SKTexture(imageNamed: "back2"))
        backTextures.append(SKTexture(imageNamed: "back2_pressed"))
        
        let back = SKSpriteNode(texture: backTextures[0])
        back.position = CGPoint(x: size.width - back.size.width, y: overlapAmount() / 2 + back.size.height)
        back.zPosition = SpriteZPosition.Overlay
        
        backgroundLayer.addChild(back)
        backSprite = back
    }
    
    func playBackgroundMusic() {
        SKTAudio.sharedInstance().playBackgroundMusic("credit.mp3")
    }
    
    func playClickSound() {
        SKTAudio.sharedInstance().playSoundEffect("click3.wav")
    }
    
    func overlapAmount() -> CGFloat {
        guard let view = self.view else {
            return 0
        }
        
        let scale = view.bounds.size.width / self.size.width
        let scaledHeight = self.size.height * scale
        let scaledOverlap = scaledHeight - view.bounds.size.height
        
        return scaledOverlap / scale
    }
    
    func positionCreditLabels() {
        var position = CGPoint(x: size.width / 2, y: 0)
        
        for label in creditLabels {
            position.y -= label.fontSize
            label.position = position
            position.y -= label.fontSize
        }
        
        creditLayer.run(SKAction.move(by: CGVector(dx: 0, dy: -position.y * 2 + overlapAmount()), duration: 32.0), completion: {
            let achievement = AchievementHelper.sharedInstance.creditWatchAchievement()
            
            GameKitHelper.sharedInstance.reportAchievements([achievement])
        }) 
    }
    
    func loadCreditLabels() {
        
        let title = SKLabelNode(fontNamed: "KenVector Future")
        title.text = "CREDIT"
        title.fontColor = SKColor.red
        title.fontSize = 200
        title.zPosition = SpriteZPosition.Overlay

        creditLabels.append(title)
        creditLayer.addChild(title)
        
        for string in creditContent {
            let label = SKLabelNode(text: string)
            label.fontName = "AppleSDGothicNeo-Bold"
            label.fontColor = SKColor.blue
            label.fontSize = 50
            label.zPosition = SpriteZPosition.Overlay
            
            creditLabels.append(label)
            creditLayer.addChild(label)
        }
    }
}
