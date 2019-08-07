//
//  Car.swift
//  RushHour
//
//  Created by Erland Isaksson on 2019-07-07.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

protocol BlockObserver {
    func blockUpdated(_ block: Block)
}
class Block : Hashable, NSCopying {
    var observers: [BlockObserver] = []
    var mergeStep : Int = 0
    
    init(number: Int, x: Int, y: Int) {
        self.x = x
        self.y = y
        self.number = number
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Block(number: self.number, x: self.x,y: self.y)
        return copy
    }
    
    func attachObserver(observer: BlockObserver) {
        observers.append(observer)
    }
    
    private func notifyObservers() {
        for observer in observers {
            observer.blockUpdated(self)
        }
    }
    var x: Int {
        didSet {
            notifyObservers()
        }
    }
    var y: Int {
        didSet {
            notifyObservers()
        }
    }
    var number: Int {
        didSet {
            notifyObservers()
        }
    }
    static func == (lhs: Block, rhs: Block) -> Bool {
        return lhs === rhs
    }
    var hashValue: Int {
        return 1
    }
}

