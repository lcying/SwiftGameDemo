//
//  GameModel.swift
//  swift_2048
//
//  Created by 刘岑颖 on 2018/5/28.
//  Copyright © 2018年 lcy. All rights reserved.
//

import UIKit

//这是一个能够让GameModel和它的父ViewController沟通的协议
protocol GameModelProtocol : class {
    
    func scoreChanged(to score: Int)
    
    func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int)
    
    func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int)
    
    func insertTile(at location: (Int, Int), withValue value: Int)
}

class GameModel: NSObject {
    let dimension : Int
    let threshold : Int
    /*
     从表面的行为上来说 unowned 更像以前的 unsafe_unretained ，而 weak 就是以前的 weak
     用通俗的话说，就是 unowned设置以后即使它原来引用的内容已经被释放了，它仍然会保持对被已经释放了的对象的一个 "无效的" 引用，它不能是 Optional 值，也不会被指向 nil 。如果你尝试调用这个引用的方法或者访问成员属性的话，程序就会崩溃。而 weak 则友好一些，在引用的内容被释放后，标记为 weak 的成员将会自动地变成 nil (因此被标记为 @ weak 的变量一定需要是 Optional 值)。
     
     关于两者使用的选择，Apple 给我们的建议是如果能够确定在访问时不会已被释放的话，尽量使用 unowned ，如果存在被释放的可能，那就选择用 weak 
     */
    unowned let delegate : GameModelProtocol
    
    //分数
    var score : Int = 0 {
        didSet {
            delegate.scoreChanged(to: score)
        }
    }
    
    var queue: [MoveCommand]
    var timer: Timer
    
    let maxCommands = 100
    let queueDelay = 0.3
    
    var gameboard: SquareGameboard<TileObject>
    
    init(dimension d: Int, threshold t: Int, delegate: GameModelProtocol) {
        dimension = d
        threshold = t
        self.delegate = delegate
        queue = [MoveCommand]()
        timer = Timer()
        gameboard = SquareGameboard(dimension: d, initialValue: .empty)
        super.init()
    }
}

extension GameModel {
    func reset() {
        score = 0
        gameboard.setAll(to: .empty)
        queue.removeAll(keepingCapacity: true)
        timer.invalidate()
    }
    
    //移动方格
    func queueMove(direction: MoveDirection, onCompletion: @escaping (Bool) -> ()) {
        guard queue.count <= maxCommands else {
            return
        }
        queue.append(MoveCommand(direction: direction, completion: onCompletion))
        if !timer.isValid {
            timeFired(timer)
        }
    }
    
    @objc func timeFired(_ : Timer) {
        if queue.count == 0 {
            return
        }
        
        var changed = false
        while queue.count > 0 {
            let command = queue[0]
            //保存第0个后删除第0个
            queue.remove(at: 0)
            changed = performMove(direction: command.direction)
            command.completion(changed)
            if changed {
                break
            }
        }
        
        if changed {
            //结束后继续下一个操作
            timer = Timer.scheduledTimer(timeInterval: queueDelay, target: self, selector: #selector(GameModel.timeFired(_:)), userInfo: nil, repeats: false)
        }
        
    }
    
    
    //移动
    func performMove(direction: MoveDirection) -> Bool {
        
        //传入Int得到内容是(Int, Int)格式的数组
        let coordinateGenerator: (Int) -> [(Int, Int)] = { (iteration: Int) -> [(Int, Int)] in
            
            /*
             var someArray = [SomeType](repeating: InitialValue, count: NumbeOfElements)
             eg：
             以下实例创建了一个类型为 Int ，数量为 3，初始值为 0 的空数组：
             var someInts = [Int](repeating: 0, count: 3)
             */
            var buffer = Array<(Int, Int)>(repeating: (0, 0), count: self.dimension)
            
            for i in 0 ..< self.dimension {
                switch direction {
                case .up: buffer[i] = (i, iteration)
                case .down: buffer[i] = (self.dimension - i - 1, iteration)
                case .left: buffer[i] = (iteration, i)
                case .right: buffer[i] = (iteration, self.dimension - i - 1)
                }
            }
            return buffer
        }
        
        var atLeastOneMove = false
        
        for i in 0 ..< dimension {
            
            let coords = coordinateGenerator(i)
            
            //得到数组
            let tiles = coords.map({ (c: (Int, Int)) -> TileObject in
                let (x, y) = c
                return self.gameboard[x, y]
            })
            
            let orders = merge(tiles)
            
            atLeastOneMove = orders.count > 0 ? true : atLeastOneMove
            
            for object in orders {
                switch object {
                case let MoveOrder.singleMoveOrder(source: s, destionation: d, value: v, wasMerge: wasMerge):
                    let (sx, sy) = coords[s]
                    let (dx, dy) = coords[d]
                    if wasMerge {
                        score += v
                    }
                    gameboard[sx, sy] = TileObject.empty
                    gameboard[dx, dy] = TileObject.tile(v)
                    delegate.moveOneTile(from: coords[s], to: coords[d], value: v)
                    
                case let MoveOrder.doubleMoveOrder(firstSource: s1, secondSource: s2, destination: d, value: v):
                    let (s1x, s1y) = coords[s1]
                    let (s2x, s2y) = coords[s2]
                    let (dx, dy) = coords[d]
                    
                    score += v
                    gameboard[s1x, s1y] = TileObject.empty
                    gameboard[s2x, s2y] = TileObject.empty
                    gameboard[dx, dy] = TileObject.tile(v)
                    
                    delegate.moveTwoTiles(from: (coords[s1], coords[s2]), to: coords[d], value: v)

                }
            }
            
        }
        
        return atLeastOneMove
    }
    
    func userHasWon() -> (Bool, (Int, Int)?) {
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                if case let .tile(v) = gameboard[i, j], v >= threshold {
                    return (true, (i, j))
                }
            }
        }
        return (false, nil)
    }
    
    func userHasLost() -> Bool {
        guard gameboardEmptySpots().isEmpty else {
            return false
        }
        
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                switch gameboard[i, j] {
                case .empty:
                    assert(false, "Gameboard reported itself as full, but we still found an empty tile. This is a logic error.")
                case let .tile(v):
                    if tileBelowHasSameValue(location: (i, j), value: v) || tileToRightHasSameValue(location: (i, j), value: v) {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    //在游戏板面上随机插入数字为value的方格
    func insertTileAtRandomLocation(withValue value: Int) {
        let openSpots = gameboardEmptySpots()
        if openSpots.isEmpty {
            //如果已经没有空的方格了，就直接返回
            return
        }
        
        //随机取一个方格
        let idx = Int(arc4random_uniform(UInt32(openSpots.count - 1)))
        //得到该方格的x,y
        let (x, y) = openSpots[idx]
        //插入方格
        insertTile(at: (x, y), value: value)
    }
    
    //得到游戏板面所有数值空的方格
    func gameboardEmptySpots() -> [(Int, Int)] {
        var buffer : [(Int, Int)] = []
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                if case .empty = gameboard[i, j] {
                    buffer += [(i, j)]
                }
            }
        }
        return buffer
    }
    
    //在location的位置插入值为value的方格
    func insertTile(at location: (Int, Int), value: Int) {
        let (x, y) = location
        if case .empty = gameboard[x, y] {
            gameboard[x, y] = TileObject.tile(value)
            delegate.insertTile(at: location, withValue: value)
        }
    }
    
    func tileBelowHasSameValue(location: (Int, Int), value: Int) -> Bool {
        
        let (x, y) = location
        guard y != dimension - 1 else {
            return false
        }

        if case let .tile(v) = gameboard[x, y + 1] {
            return v == value
        }
        
        return false
    }
    
    func tileToRightHasSameValue(location: (Int, Int), value: Int) -> Bool {
        
        let (x, y) = location
        
        guard x != dimension - 1 else {
            return false
        }

        if case let .tile(v) = gameboard[x + 1, y] {
            return v == value
        }
        
        return false
    }
    
    //quiescent 静态的
    class func quiescentTileStillQuiescent(inputPosition: Int, outputLength: Int, originalPosition: Int) -> Bool {
        return (inputPosition == outputLength) && (originalPosition == inputPosition)
    }
    
    //融合
    func merge(_ group: [TileObject]) -> [MoveOrder] {
        return convert(collapse(condense(group)))
    }
    
    //转换
    func convert(_ group: [ActionToken]) -> [MoveOrder] {
        var moveBuffer = [MoveOrder]()
        for (idx, t) in group.enumerated() {
            switch t {
            case let .move(s, v):
                moveBuffer.append(MoveOrder.singleMoveOrder(source: s, destionation: idx, value: v, wasMerge: false))
            case let .singleCombine(s, v):
                moveBuffer.append(MoveOrder.singleMoveOrder(source: s, destionation: idx, value: v, wasMerge: true))
            case let .doubleCombine(s1, s2, v):
                moveBuffer.append(MoveOrder.doubleMoveOrder(firstSource: s1, secondSource: s2, destination: idx, value: v))
            default:
                break
            }
        }
        return moveBuffer
    }
    
    //瓦解、奔溃
    func collapse(_ group: [ActionToken]) -> [ActionToken] {
        var tokenBuffer = [ActionToken]()
        
        var skipNext = false
        
        for (idx, token) in group.enumerated() {
            if skipNext {
                skipNext = false
                continue
            }
            
            switch token {
            case .singleCombine:
                assert(false, "Cannot have single combine token in input")
                
            case .doubleCombine:
                assert(false, "Cannot have double combine token in input")
                
            case let .noAction(s, v) where (idx < group.count - 1 && v == group[idx + 1].getValue() && GameModel.quiescentTileStillQuiescent(inputPosition: idx, outputLength: tokenBuffer.count, originalPosition: s)):
                let next = group[idx + 1]
                let nv = v + group[idx + 1].getValue()
                skipNext = true
                tokenBuffer.append(ActionToken.singleCombine(source: next.getSource(), value: nv))
                
            case let t where (idx < group.count - 1 && t.getValue() == group[idx + 1].getValue()):
                let next = group[idx + 1]
                let nv = t.getValue() + group[idx + 1].getValue()
                skipNext = true
                tokenBuffer.append(ActionToken.doubleCombine(source: t.getSource(), second: next.getSource(), value: nv))
                
            case let .noAction(s, v) where !GameModel.quiescentTileStillQuiescent(inputPosition: idx, outputLength: tokenBuffer.count, originalPosition: s):
                tokenBuffer.append(ActionToken.move(source: s, value: v))
            
            case let .noAction(s,v):
                tokenBuffer.append(ActionToken.noAction(source: s, value: v))

            case let .move(s, v):
                tokenBuffer.append(ActionToken.move(source: s, value: v))
                
            default:
                break
            }
        }
        return tokenBuffer
    }

    //压缩 -----
    func condense(_ group: [TileObject]) -> [ActionToken] {
        var tokenBuffer = [ActionToken]()
        
        for (idx, tile) in group.enumerated() {
            switch tile {
            case let .tile(value) where tokenBuffer.count == idx:
                tokenBuffer.append(ActionToken.noAction(source: idx, value: value))
            case let .tile(value):
                tokenBuffer.append(ActionToken.move(source: idx, value: value))
            default:
                break
            }
        }
        
        return tokenBuffer
    }

}



