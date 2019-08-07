//
//  Board.swift
//  RushHour
//
//  Created by Erland Isaksson on 2019-07-07.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

protocol BoardObserver : class {
    func blockAdded(_ block: Block)
    func blockRemoved(_ block: Block)
}
class Board {
    let name: String
    let width: Int
    let height: Int
    let board: Array2D<Block>
    var blocks: Set<Block> = Set()
    var observers: [BoardObserver] = []
    let debug = false
    
    init(name: String, width: Int, height: Int) {
        self.name = name
        self.width = width
        self.height = height
        self.board = Array2D<Block>(columns: self.width, rows: self.height)
    }
    
    convenience init(name: String, boardString: String) {
        self.init(name: name, width: 5, height: 5)
        initializeFromString(boardString: boardString)
    }
    
    
    func attachObserver(_ observer: BoardObserver) {
        for block in blocks {
            observer.blockAdded(block)
        }
        observers.append(observer)
    }
    
    func detachObserver(_ observer: BoardObserver) {
        if let index = (self.observers.firstIndex(where: { $0 === observer })) {
            self.observers.remove(at: index)
        }
    }
    
    func initializeFromString(boardString: String) {
        for block in blocks {
            board[block.x,block.y] = nil
            for observer in observers {
                observer.blockRemoved(block)
            }
        }
        blocks.removeAll()

        for y in 0..<height {
            for x in 0..<width {
                let i = width*y+x
                if boardString.count > i {
                    if let num = Int(String(boardString[boardString.index(boardString.startIndex, offsetBy: i)])) {
                        addBlock(Block(number: num, x: x, y: y))
                    }
                }
            }
        }
    }
    subscript(x: Int, y: Int) -> Block? {
        get {
            return board[x,y]
        }
    }

    private func isInsideBoard(x: Int, y: Int) -> Bool {
        if x<0 || x >= self.width || y<0 || y >= self.height {
            // Outside board
            if debug {
                print("Outside board")
            }
            return false
        }
        return true
    }
    
    func isMergePossible() -> Bool {
        for block in blocks {
            if isMergePossible(block: block) {
                return true
            }
        }
        return false
    }

    func isMergePossible(block: Block) -> Bool {
        for offsetY in -1...1 {
            for offsetX in -1...1 {
                if offsetX != 0 || offsetY != 0 {
                    if offsetX == 0 || offsetY == 0 {
                        if let nearbyBlock = board[block.x+offsetX,block.y+offsetY] {
                            if nearbyBlock.number == block.number {
                                return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }

    func merge(block: Block) -> Int {
        if !isMergePossible(block: block) {
            return 0
        }
        block.mergeStep = 1
        var mergeCells : [Block] = []
        mergeCells.append(contentsOf: findMergeCells(block: block))
        
        var score = 0
        for b in mergeCells {
            score = score + b.number
            blocks.remove(b)
            board[b.x,b.y] = nil
            for observer in observers {
                observer.blockRemoved(b)
            }
        }
        block.mergeStep = 0
        block.number = block.number + 1
        score = score * block.number
        return score
    }
    
    private func findMergeCells(block: Block) -> [Block] {
        var result : [Block] = []
        for offsetY in -1...1 {
            for offsetX in -1...1 {
                if offsetX != 0 || offsetY != 0 {
                    if offsetX == 0 || offsetY == 0 {
                        if let nearbyBlock = board[block.x+offsetX,block.y+offsetY] {
                            if nearbyBlock.number == block.number && nearbyBlock.mergeStep == 0 {
                                nearbyBlock.mergeStep = block.mergeStep + 1
                                result.append(nearbyBlock)
                            }
                        }
                    }
                }
            }
        }
        var nextBlocks : [Block] = []
        for block in result {
            nextBlocks.append(contentsOf: findMergeCells(block: block))
        }
        result.append(contentsOf: nextBlocks)
        return result
    }
    
    func dropBlocks() {
        debugBoard(debug: true)
        var dropped = false
        for offsetY in 2...height {
            for x in 0..<width {
                let y = board.rows-offsetY
                if let block = board[x,y] {
                    if board[x,y+1] == nil {
                        block.y = y+1
                        board[x,y] = nil
                        board[x,y+1] = block
                        dropped = true
                    }
                }
            }
        }
        if dropped {
            dropBlocks()
        }
    }
    
    func addNewBlocks() {
        for y in 0..<height {
            for x in 0..<width {
                if board[x,y] == nil {
                    let max = maxNumber()
                    let min = minNumber()
                    let number = Int.random(in: min...max)
                    let block = Block(number: number, x: x, y: y)
                    addBlock(block)
                }
            }
        }
    }
    
    private func maxNumber() -> Int {
        var maxNumber : Int = 0
        for block in blocks {
            if block.number>maxNumber {
                maxNumber = block.number
            }
        }
        if maxNumber<2 {
            maxNumber = 2
        }
        return maxNumber
    }

    private func minNumber() -> Int {
        var minNumber : Int = 0
        for block in blocks {
            if block.number<minNumber {
                minNumber = block.number
            }
        }
        if minNumber == 0 {
            minNumber = 1
        }
        return minNumber
    }

    private func addBlock(_ block: Block) {
        board[block.x,block.y] = block
        blocks.insert(block)
        for observer in observers {
            observer.blockAdded(block)
        }
    }
    

    func asString() -> String {
        var result = ""
        for y in 0..<height {
            for x in 0..<width {
                if board[x,y] != nil {
                    let b = board[x,y]
                    result = result + "\(b!.number)"
                }else {
                    result = result + "_"
                }
            }
        }
        return result
    }
    
    func debugBoard(debug: Bool? = nil) {
        if self.debug || (debug != nil && debug!) {
            
            print("Board contents")
            for y in 0..<height {
                for x in 0..<width {
                    if board[x,y] != nil {
                        let b = board[x,y]
                        print("\(b!.number)", terminator: "")
                    }else {
                        print(" ", terminator: "")
                    }
                }
                print()
            }
        }
    }
    
}
