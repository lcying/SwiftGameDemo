//
//  ScreenUtils.swift
//  CircleGame
//
//  Created by 刘岑颖 on 2019/6/19.
//  Copyright © 2019 lcy. All rights reserved.
//

import UIKit

enum LScreenWidth {
    case Width320
    case Width375
    case Width414
    case Other
}

class ScreenUtils: NSObject {
    //func前面加class就是类方法
    
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    
    class func screenWidthModel () -> LScreenWidth {
        let screenWidth = UIScreen.main.bounds.size.width
        /*
         只做iphone，并且只能竖屏
         */
        if screenWidth == 320 {
            return LScreenWidth.Width320
        }
        if screenWidth == 375 {
            return LScreenWidth.Width375
        }
        if screenWidth == 414 {
            return LScreenWidth.Width414
        }
        
        return LScreenWidth.Other
    }

}
