//
//  String+Category.swift
//  DoubleGames
//
//  Created by 刘岑颖 on 2019/6/24.
//  Copyright © 2019 lcy. All rights reserved.
//

import UIKit

extension NSAttributedString {
    class func createScoreString(score1: Int, score2: Int) -> NSAttributedString {
        let attribitedString = NSMutableAttributedString()
        
        let score1AttributedString: NSAttributedString = NSAttributedString.init(string: String(format: "%d", score1), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22), NSAttributedString.Key.foregroundColor: pinColor])
        
        let colonAttributedString: NSAttributedString = NSAttributedString.init(string: " : ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22), NSAttributedString.Key.foregroundColor: UIColor.white])

        
        let score2AttributedString: NSAttributedString = NSAttributedString.init(string: String(format: "%d", score2), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22), NSAttributedString.Key.foregroundColor: blueColor])

        attribitedString.append(score1AttributedString)
        attribitedString.append(colonAttributedString)
        attribitedString.append(score2AttributedString)
        
        return attribitedString
    }
}
