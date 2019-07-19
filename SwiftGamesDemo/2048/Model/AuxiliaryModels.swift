//
//  AuxiliaryModels.swift
//  swift_2048
//
//  Created by 刘岑颖 on 2018/5/29.
//  Copyright © 2018年 lcy. All rights reserved.
//

import UIKit

enum MoveDirection {
    case up, down, left, right
}

enum TileObject {
    case empty
    case tile(Int)
}

struct MoveCommand {
    let direction : MoveDirection
    let completion : (Bool) -> ()
}

enum MoveOrder {
    case singleMoveOrder(source: Int, destionation: Int, value: Int, wasMerge: Bool)
    case doubleMoveOrder(firstSource: Int, secondSource: Int, destination: Int, value: Int)
}

enum ActionToken {
    case noAction(source: Int, value: Int)
    case move(source: Int, value: Int)
    case singleCombine(source: Int, value: Int)
    case doubleCombine(source: Int, second: Int, value: Int)
    
    func getValue() -> Int {
        switch self {
        case let .noAction(_, v): return v
        case let .move(_, v): return v
        case let .singleCombine(_, v): return v
        case let .doubleCombine(_, _, v): return v
        }
    }
    
    func getSource() -> Int {
        switch self {
        case let .noAction(s, _): return s
        case let .move(s, _): return s
        case let .singleCombine(s, _): return s
        case let .doubleCombine(s, _, _): return s
        }
    }
}

/*
 泛型<T>
 */
struct SquareGameboard<T> {
    let dimension : Int
    var boardArray : [T]
    
    init(dimension d: Int, initialValue: T) {
        dimension = d
        boardArray = [T](repeating: initialValue, count: d*d)
    }
    
    /*
     自定义下标
     */
    subscript(row: Int, col: Int) -> T {
        get {
            assert(row >= 0 && row < dimension)
            assert(col >= 0 && col < dimension)
            return boardArray[row * dimension + col]
        }
        set {
            assert(row >= 0 && row < dimension)
            assert(col >= 0 && col < dimension)
            boardArray[row * dimension + col] = newValue
        }
    }
    
    /*
     为了能够在实例方法中修改属性值，可以在方法定义前添加关键字mutating
     */
    mutating func setAll(to item: T) {
        for i in 0..<dimension {
            for j in 0..<dimension {
                self[i, j] = item
            }
        }
    }
}


class AuxiliaryModels: NSObject {

}
