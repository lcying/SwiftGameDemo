//
//  Circle.swift
//  CircleGame
//
//  Created by 刘岑颖 on 2019/6/19.
//  Copyright © 2019 lcy. All rights reserved.
//

import UIKit

/*
 Circle 类的作用是代表一个圆的实体信息，包括三个属性：颜色，圆心坐标和半径
 还有一个 class function是用来生成一个随机的圆
 首先计算一个随机的半径（在一定的范围内，不同的屏幕尺寸下这个范围是不一样的）
 然后在合理的屏幕区域内随机一个点作为圆心
 */

class Circle {
    
    static var minRadius: Int {
        switch ScreenUtils.screenWidthModel() {
            //只做iphone的
            default:
                return 20
        }        
    }
    
    static var maxRadius: Int {
        return 50
    }
    
    //颜色
    var color: UIColor
    //半径，范围在minRadius～maxRadius之间
    var radius: Int
    //中心
    var center: CGPoint
    
    init(color: UIColor, radius: Int, center: CGPoint) {
        self.color = color
        self.radius = radius
        self.center = center
    }
    
    /*
     类方法
     */
    class func randomCircle() -> Circle {
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        let randomRadius = minRadius + Int(arc4random_uniform(UInt32(maxRadius - minRadius + 1)))
        
        let areaWidth = Int(screenWidth) - (randomRadius << 1);
        let areaHeight = Int(screenHeight) - (randomRadius << 1) - 20;
        
        let x = randomRadius + Int(arc4random_uniform(100000)) % areaWidth
        //20是电池条高度
        let y = 20 + randomRadius + Int(arc4random_uniform(100000)) % areaHeight
        let randomPoint = CGPoint(x: x, y: y)
        
        let randomColor = ColorUtils.randomColor()
        
        let circle = Circle.init(color: randomColor, radius: randomRadius, center: randomPoint)
        return circle
    }

}
