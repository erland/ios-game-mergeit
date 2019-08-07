//
//  SingleGameOverScene.swift
//  Sudoku
//
//  Created by Erland Isaksson on 2019-06-14.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit
import GameplayKit

class SingleGameOverScene: SKScene {
    var gameDelegate: GameDelegate?
    var boardView: BoardView?
    var openedTime: TimeInterval?
    var status: SKLabelNode?
    var scoreText: SKLabelNode?
    var boardName: SKLabelNode?
    var score: Int?
    var seconds: Int?
    
    override func sceneDidLoad() {
        localize()
    }

    func setup(delegate: GameDelegate, board: Board, seconds: Int, score: Int) {
        self.gameDelegate = delegate
        self.seconds = seconds
        self.score = score
        
        self.boardView = childNode(withName:"board") as? BoardView
        self.status = childNode(withName:"status") as? SKLabelNode
        self.boardName = childNode(withName:"boardName") as? SKLabelNode
        self.boardName?.text = board.name
        self.scoreText = childNode(withName:"score") as? SKLabelNode
        self.boardView?.setup(board: board)
        scoreText?.text = "\(NSLocalizedString("score", comment: "score")): \(score)"
        
    }
    
    override func didMove(to view: SKView) {
        openedTime = NSDate().timeIntervalSince1970
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // We need to ensure the sceen is shown for 2 seconds before we allow player to continue
        if openedTime!<NSDate().timeIntervalSince1970-2 {
            gameDelegate?.backToMenu(board: boardView!.board!, seconds: seconds!, score: score!)
        }
    }
}
