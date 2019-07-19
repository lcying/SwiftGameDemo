//
//  CircleFactory.swift
//  CircleGame
//
//  Created by 刘岑颖 on 2019/6/19.
//  Copyright © 2019 lcy. All rights reserved.
//

import UIKit

/*
 CircleFactory 类是一个单例工厂类，维持一个 Circle 的数组，在每次游戏重新开始的时候会清空这个数组，并且通过 addCircle 向这个数组中添加新的 Circle 对象。添加新圆的逻辑很简单，就是一个无限循环，直到算出来一个合格的圆为止。判断圆是否可用的方法是 isCircleAvailable，就是判断两个圆是否相交。
 
但是屏幕区域毕竟是有限的，不可能会一直找到一个可用的圆，圆的个数大于40的时候每次计算的耗时就会显著增加，界面也会因为计算而卡住
 */
class CircleFactory: NSObject {

    //最大圆的数量
    static let MaxCircleCount = 40
    
    static let sharedCircleFactory = CircleFactory()
    
    //圆与圆之间的最小间隙
    let RadiusGap:Float = 10
    
    var circles = [Circle]()
    
    private override init() {
        super.init()
        self.circles.removeAll()
    }
    
    func addCircle() {
        while true {
            let aCircle = Circle.randomCircle()
            if isCircleAvailable(aCircle: aCircle) {
                self.circles.append(aCircle)
                break;
            }
            continue
        }
    }
    
    func isCircleAvailable(aCircle: Circle) -> Bool {
        for circle in self.circles {
            let distance = hypotf(Float(circle.center.x - aCircle.center.x), Float(circle.center.y - aCircle.center.y))
            if distance < Float(circle.radius + aCircle.radius) + RadiusGap {
                return false
            }
        }
        return true
    }
    
}
