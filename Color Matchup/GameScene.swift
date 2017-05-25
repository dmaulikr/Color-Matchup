//
//  GameScene.swift
//  Color Matchup
//
//  Created by Adrian San Pedro on 4/12/17.
//  Copyright © 2017 Adrian San Pedro. All rights reserved.
//

import SpriteKit
import GameplayKit

class button{
    var button = SKSpriteNode()
    var containsButton = false
}

var colors = [UIColor.red, UIColor.red, UIColor.blue, UIColor.blue, UIColor.green, UIColor.green, UIColor.orange, UIColor.orange, UIColor.black, UIColor.black, UIColor.purple, UIColor.purple, UIColor.yellow, UIColor.yellow, UIColor.cyan, UIColor.cyan];
var multiplierColors = [UIColor.white, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.orange]

let points = 10;
var multiplier = 1;
var gameTime = 60;
let corrrectSound = SKAction.playSoundFileNamed("correctSound", waitForCompletion: false)
let incorrectSound = SKAction.playSoundFileNamed("incorrectSound", waitForCompletion: false)
let boardFinish = SKAction.playSoundFileNamed("boardFinishSound", waitForCompletion: false)
let timeOutSound = SKAction.playSoundFileNamed("timeOutSound", waitForCompletion: false)

class GameScene: SKScene{
    
    //MARK: Properties
    private var firstPress = button()
    private var secondPress = button()
    private var startButton : SKNode?
    private var stopButton : SKNode?
    private var resetButton : SKNode?
    private var scoreLabel: SKLabelNode?
    private var secondsLabel: SKLabelNode?
    private var multiplierLabel: SKLabelNode?
    private var startStopButton : SKSpriteNode?
    private var timer = Timer()
    private var currentHighScore = 0
    
    var totalPoints = 0;
    var i = 0
    var j = 0
    
    //MARK: Actions
    override func sceneDidLoad() {
        colors = shuffleArray(colors)
        self.startButton = childNode(withName: "startButton")
        self.stopButton = childNode(withName: "stopButton")
        deactivateButton(self.stopButton!)
        self.resetButton = childNode(withName: "resetButton")
        deactivateButton(self.resetButton!)
        self.secondsLabel = childNode(withName: "currentTimeLabel") as! SKLabelNode?
        self.secondsLabel?.text = String(gameTime)
        self.scoreLabel = childNode(withName: "currentScoreLabel") as! SKLabelNode?
        self.scoreLabel?.text = String(self.totalPoints)
        self.multiplierLabel = childNode(withName: "multiplierLabel") as! SKLabelNode?
        self.multiplierLabel?.text = "x\(multiplier)"
        self.enumerateChildNodes(withName: "button", using: init_Buttons)
        self.i = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        let node = atPoint(touchLocation)
        
        if node.name == "button"{   //for every GAME BUTTON that is pressed
            print("button pressed")
            if(self.firstPress.containsButton == false){
                self.firstPress.button = (node as? SKSpriteNode)!
                deactivateButton(self.firstPress.button)
                self.firstPress.containsButton = true
            }
            else if(self.secondPress.containsButton == false){
                self.secondPress.button = (node as? SKSpriteNode)!
                deactivateButton(self.secondPress.button)
                self.secondPress.containsButton = true
                checkPresses()
            }
        }
        else if (node.name == "startLabel"){   //for when START is pressed
            print("START is pressed")
            self.enumerateChildNodes(withName: "button", using: activateButton)
            if(firstPress.containsButton == true){
                deactivateButton(firstPress.button)
            }
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.updateTimer), userInfo: nil, repeats: true)
            secondsLabel?.text = String(gameTime)
            deactivateButton(self.startButton!)
            activateButton(self.stopButton!)
        }
        else if node.name == "stopLabel"{   //for when STOP is pressed
            print("STOP is pressed")
            self.timer.invalidate()
            deactivateButton(self.stopButton!)
            activateButton(self.startButton!)
            activateButton(self.resetButton!)
            self.enumerateChildNodes(withName: "button", using: deactivateButton)
        }
        else if node.name == "resetLabel"{   //for when RESET is pressed
            self.scoreLabel?.fontColor = UIColor.white
            self.secondsLabel?.fontColor = UIColor.white
            self.firstPress.containsButton = false
            self.secondPress.containsButton = false
            multiplier = 1
            self.i = 0
            self.j = -1
            resetBoard()
            deactivateButton(self.resetButton!)
            activateButton(self.startButton!)
            gameTime = 60
            self.totalPoints = 0
            self.scoreLabel?.text = String(self.totalPoints)
            self.secondsLabel?.text = String(gameTime)
            self.enumerateChildNodes(withName: "button", using: deactivateButton)
        }
    }
    
    func updateTimer(){
        print(gameTime)
        if(gameTime > -1){
            self.secondsLabel?.text = String(gameTime)
            gameTime -= 1
            if(gameTime == 9){
                self.secondsLabel?.fontColor = UIColor.red
            }
        }
        else{  //when TIMER reaches 0
            self.timer.invalidate()
            self.timeOut()
            deactivateButton(self.stopButton!)
            activateButton(self.resetButton!)
            self.enumerateChildNodes(withName: "button", using: deactivateButton)
        }
    }
    
    func init_Buttons(_ button: SKNode, stop: UnsafeMutablePointer<ObjCBool>){
        deactivateButton(button)
        setButtonColor(button)
    }
    
    func shuffleArray(_ array: [UIColor]) -> [UIColor]{
        let returnArray = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: array) as! [UIColor]
        return returnArray
    }
    
    func checkPresses(){
        if(self.firstPress.button.color != self.secondPress.button.color){   //if the user chooses the INCORRECT pair
            print("Incorrect pair")
            run(incorrectSound)
            if(multiplier > 1){
                multiplier = 1
                self.j = 0
                self.multiplierLabel?.text = "x\(multiplier)"
                self.multiplierLabel?.fontColor = multiplierColors[j]
            }
            activateButton(self.firstPress.button)
            activateButton(self.secondPress.button)
        }
        else{   //if the user chooses the CORRECT pair
            print("Corret pair")
            run(corrrectSound)
            updatePoints()
            self.firstPress.button.isHidden = true
            self.secondPress.button.isHidden = true
            self.i += 1
            if(self.i == 8){
                run(boardFinish)
                if(multiplier < 16){
                    multiplier *= 2
                }
                resetBoard()
            }
        }
        self.firstPress.containsButton = false
        self.secondPress.containsButton = false
    }
    
    func resetBoard(){
        self.multiplierLabel?.text = "x\(multiplier)"
        if(j < 4){
            self.j += 1
            print(self.j)
            self.multiplierLabel?.fontColor = multiplierColors[j]
        }
        colors = shuffleArray(colors)
        self.i = 0
        self.enumerateChildNodes(withName: "button", using: resetButtons)
        self.i = 0
    }
    
    func resetButtons(_ button: SKNode, stop: UnsafeMutablePointer<ObjCBool>){
        button.isHidden = false
        button.alpha = 1.0
        if(gameTime >= 0){
            button.isPaused = false
            button.isUserInteractionEnabled = false
        }
        else{
            button.isPaused = true
            button.isUserInteractionEnabled = true
        }
        setButtonColor(button)
    }
    
    func setButtonColor(_ button: SKNode){
        let newButton = button as! SKSpriteNode

        if(self.i < 16){
            newButton.color = colors[self.i]
        }
        self.i += 1
    }
    
    func updatePoints(){
        self.totalPoints += (points * multiplier)
        self.scoreLabel?.text = String(self.totalPoints)
        if(self.totalPoints > self.currentHighScore){
            self.currentHighScore = self.totalPoints
            self.scoreLabel?.fontColor = UIColor.cyan
        }
    }
    
    func timeOut(){   
        print("time out, GAME OVER")
        multiplier = 1
        self.i = 0
        run(timeOutSound)
    }
    
    func deactivateButton(_ button: SKNode){
        button.alpha = 0.375
        button.isPaused = true
        button.isUserInteractionEnabled = true
    }
    
    func deactivateButton(_ button: SKNode, stop: UnsafeMutablePointer<ObjCBool>){
        deactivateButton(button)
    }
    
    func activateButton(_ button: SKNode){
        button.alpha = 1
        button.isPaused = false
        button.isUserInteractionEnabled = false
    }
    
    func activateButton(_ button: SKNode, stop: UnsafeMutablePointer<ObjCBool>){
        activateButton(button)
    }
}
