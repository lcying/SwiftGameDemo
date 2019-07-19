//
//  AccessoryView.swift
//  swift_2048
//
//  Created by 刘岑颖 on 2018/5/29.
//  Copyright © 2018年 lcy. All rights reserved.
//

import UIKit

protocol ScoreViewProtocol {
    func scoreChanged(to s: Int)
}

class ScoreView: UIView, ScoreViewProtocol {
    
    var label: UILabel
    
    let defaultFrame = CGRect(x: 0, y: 0, width: 140, height: 40)

    var score : Int = 0 {
        didSet {
            label.text = "SCROE:\(score)"
        }
    }
    
    init(backgroundColor bgcolor: UIColor, textColor tColor: UIColor, font: UIFont, radius r:CGFloat) {
        label = UILabel(frame: defaultFrame)
        label.textAlignment = .center
        
        super.init(frame: defaultFrame)
        
        backgroundColor = bgcolor
        label.textColor = tColor
        label.font = font
        layer.cornerRadius = r
        
        self.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scoreChanged(to s: Int) {
        score = s
    }
    
}

class ControlView {
    let defaultFrame = CGRect(x: 0, y: 0, width: 140, height: 40)
}
