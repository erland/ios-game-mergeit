//
//  CarView.swift
//  RushHour
//
//  Created by Erland Isaksson on 2019-07-07.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

class BlockView : SKSpriteNode, BlockObserver {
    var cellSize: CGFloat
    var block : Block
    let numberLabel : SKLabelNode = SKLabelNode(fontNamed: "ArialRoundedMTBold")

    init(block: Block, cellSize: CGFloat) {
        self.cellSize = cellSize
        self.block = block
        let texture = SKTexture(imageNamed: "block\(block.number)")
        super.init(texture: texture, color: UIColor.black, size: CGSize(width: cellSize-1, height: cellSize-1))
        block.attachObserver(observer: self)
        anchorPoint = CGPoint(x: 0, y: 1)
        numberLabel.fontColor = .black
        numberLabel.zPosition = 10
        numberLabel.fontSize = cellSize/3.5
        numberLabel.horizontalAlignmentMode = .center
        numberLabel.verticalAlignmentMode = .center
        numberLabel.position = CGPoint(x: 0, y: 0)
        addChild(numberLabel)
        blockUpdated(block)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func blockUpdated(_ block: Block) {
        let positionX = CGFloat(block.x)*cellSize+(cellSize)/2.0
        let positionY = -CGFloat(block.y)*cellSize-(cellSize)/2.0
        if self.numberLabel.text != "\(block.number)" {
            if self.numberLabel.text != nil {
                run(SKAction.sequence([SKAction.wait(forDuration: 0.5),SKAction.run() {
                    self.numberLabel.text = "\(block.number)"
                    self.texture = SKTexture(imageNamed: "block\(block.number)")
                    }]))
            }else {
                self.numberLabel.text = "\(block.number)"
                self.texture = SKTexture(imageNamed: "block\(block.number)")
            }
        }
        if position != CGPoint.zero {
            let currentYPos = Int((position.y+cellSize/2.0)/cellSize)
            if currentYPos != block.y {
                run(SKAction.move(to: CGPoint(x: positionX, y: positionY), duration: 0.5))
            }else {
                self.position = CGPoint(x: positionX, y: positionY)
            }
        }else {
            self.position = CGPoint(x: positionX, y: positionY)
        }
    }
}

