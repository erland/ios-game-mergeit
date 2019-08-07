//
//  SingleGameScene.swift
//  MergeIt
//
//  Created by Erland Isaksson on 2019-08-07.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit
import GameplayKit

class SingleGameScene: SKScene, BoardObserver {
    var boardView: BoardView?
    var gameDelegate: GameDelegate?
    var timeText : SKLabelNode?
    var recordLabel : SKLabelNode?
    var recordScore : SKLabelNode?
    var timeCounter : Int = 0
    var record : Int?
    var pauseButton : SKLabelNode?
    var quitButton : SKLabelNode?
    var scoreText : SKLabelNode?
    var score : Int = 0
    var lastTouchX : Int?
    var lastTouchY : Int?
    var mergeInProcess = false
    
    func setup(delegate: GameDelegate, board: Board, startTime: Int, score: Int) {
        self.gameDelegate = delegate
        
        self.boardView = childNode(withName: "board") as? BoardView
        let boardNameLabel = childNode(withName: "boardName") as? SKLabelNode
        boardNameLabel?.text = board.name
        self.boardView?.setup(board: board)
        self.pauseButton = childNode(withName: "pause") as? SKLabelNode
        self.quitButton = childNode(withName: "quit") as? SKLabelNode
        self.scoreText = childNode(withName: "score") as? SKLabelNode
        
        self.timeText = childNode(withName: "time") as? SKLabelNode
        self.recordLabel = childNode(withName: "recordLabel") as? SKLabelNode
        self.recordScore = childNode(withName: "recordScore") as? SKLabelNode
        let recordState = LevelStorage().getRecord(type: board.name)
        if recordState != nil {
            record = recordState!.score
            recordScore?.text = "\(record!)"
        }else {
            record = nil
            recordLabel?.isHidden = true
            recordScore?.isHidden = true
        }
        timeCounter = startTime
        displayTime()
        
        self.score = score
        displayScore()
        
        boardView?.board?.attachObserver(self)
    }
    deinit {
        boardView?.board?.detachObserver(self)
    }
    
    override func didMove(to view: SKView) {
        print("Moved to game scene")
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateTimer() {
        timeCounter = timeCounter + 1
        displayTime()
    }
    
    func timeAsString(_ seconds: Int) -> String {
        let hours = Int(seconds/3600)
        let minutes = String(format: "%02d",Int((seconds%3600)/60))
        let seconds = String(format: "%02d",Int(seconds%60))
        if hours == 0 {
            return  "\(minutes):\(seconds)"
        }else {
            return "\(hours):\(minutes):\(seconds)"
        }
    }
    
    func displayTime() {
        timeText?.text = "\(timeAsString(timeCounter))"
    }
    
    func displayScore() {
        if record != nil && score>record! {
            scoreText?.fontColor = .green
        }
        scoreText?.text = "Score: \(score)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        if quitButton!.contains(touchLocation) {
            gameDelegate?.backToMenu(board: boardView!.board!, seconds: timeCounter, score: score)
        }else if pauseButton!.contains(touchLocation) {
            gameDelegate?.gameCompleted(board: boardView!.board!, completed: false, seconds: timeCounter, score: score)
        }else {
            if boardView!.contains(touchLocation) {
                if !mergeInProcess {
                    if let block = boardView!.blockAtPosition(CGPoint(x: touchLocation.x-boardView!.position.x,
                                                                      y: touchLocation.y-boardView!.position.y)) {
                        if boardView!.board!.isMergePossible(block:block) {
                            mergeInProcess = true
                            score = score + boardView!.board!.merge(block: block)
                            displayScore()
                            DispatchQueue.main.asyncAfter(deadline: .now() +  0.6) {
                                self.boardView!.board!.dropBlocks()
                                DispatchQueue.main.asyncAfter(deadline: .now() +  0.5) {
                                    self.boardView!.board!.addNewBlocks()
                                    self.processGameState()
                                    self.mergeInProcess = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func processGameState() {
        if !boardView!.board!.isMergePossible() {
            gameDelegate?.gameCompleted(board: boardView!.board!, completed: true, seconds: timeCounter, score: score)
        }
    }
    
    func blockAdded(_ block: Block) {
        // Do nothing
    }
    
    func blockRemoved(_ block: Block) {
        // Do nothing
    }
}

