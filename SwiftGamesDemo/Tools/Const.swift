//
//  Const.swift
//  DoubleGames
//
//  Created by 刘岑颖 on 2019/6/21.
//  Copyright © 2019 lcy. All rights reserved.
//

import UIKit
import Foundation

typealias nextBlock = () -> ()

func UIColorFromRgb(rgbValue: Int, a: CGFloat) -> UIColor {
    return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(rgbValue & 0xFF))/255.0, alpha: a)
}

let blueColor = UIColorFromRgb(rgbValue: 0xB0E5FE, a: 1)
let pinColor = UIColorFromRgb(rgbValue: 0xFFC9BE, a: 1)

let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height

/*
 24所有组合
 */
var args:[[String]] = [
    ["6", "6" , "4", "6"],
    ["3", "4" , "4", "3"],
    ["7", "1" , "10", "6"],
    ["8", "4" , "2", "6"],
    ["9", "8" , "3", "1"],
    ["1", "2" , "3", "4"],
    ["6", "2" , "3", "6"],
    ["2", "7" , "1", "3"],
    ["3", "2" , "10", "8"],
    ["5", "1" , "5", "1"],
    ["5", "3" , "9", "2"],
    ["10", "10" , "8", "4"],
    ["7", "3" , "5", "2"],
    ["2", "6" , "2", "1"],
    ["5", "5" , "7", "6"],
    ["4", "9" , "8", "4"],
    ["3", "3" , "3", "3"],
    ["8", "7" , "8", "1"],
    ["5", "9" , "5", "2"],
    ["7", "4" , "7", "3"]
]
