//
//  ColorUtils.swift
//  CircleGame
//
//  Created by 刘岑颖 on 2019/6/19.
//  Copyright © 2019 lcy. All rights reserved.
//

import UIKit

class ColorUtils: NSObject {
    class func randomColor() -> UIColor {
        let red = CGFloat(arc4random() % 256) / 255.0
        let green = CGFloat(arc4random() % 256) / 255.0
        let blue = CGFloat(arc4random() % 256) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
