//
//  CircleView.swift
//  CircleGame
//
//  Created by 刘岑颖 on 2019/6/19.
//  Copyright © 2019 lcy. All rights reserved.
//

import UIKit

/*
 CircleView 类是 Circle 对象在 UI 上的体现，实现上只是增加了一个自定义的初始化方法，参数是一个 Circle 对象，根据其信息设置 view 的大小、位置和颜色，并且通过 layer 将 view 设置成圆形。
 */

class CircleView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(circle: Circle) {
        let frame = CGRect(x: 0, y: 0, width: circle.radius * 2, height: circle.radius * 2)
        super.init(frame: frame)
        self.backgroundColor = circle.color
        self.center = circle.center
        self.layer.cornerRadius = CGFloat(circle.radius)
    }
    
}
