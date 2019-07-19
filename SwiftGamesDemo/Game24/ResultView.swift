//
//  ResultView.swift
//  DoubleGames
//
//  Created by 刘岑颖 on 2019/6/24.
//  Copyright © 2019 lcy. All rights reserved.
//

import UIKit

class ResultView: UIView {
    
    var block:nextBlock?
    
    var color: UIColor! {
        didSet {
            self.backView.backgroundColor = color
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(traslucentBackView)
        self.addSubview(backView)
        self.backView.addSubview(correctLabel)
        self.backView.addSubview(scoreLabel)
        self.backView.addSubview(continueLabel)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hide))
        self.backView.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - methods ----
    func show(score: String, title: String) {
        self.scoreLabel.text = score
        self.correctLabel.text = title
        self.isHidden = false
        self.traslucentBackView.alpha = 0.0
        let frame = CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: ScreenHeight / 2)
        self.backView.frame = frame
        UIView.animate(withDuration: 0.4, animations: {
            self.traslucentBackView.alpha = 1.0
            let frame = CGRect(x: 0, y: ScreenHeight / 2.0, width: ScreenWidth, height: ScreenHeight / 2)
            self.backView.frame = frame
        }) { (finished) in
        }
    }
    
    @objc func hide() {
        UIView.animate(withDuration: 0.4, animations: {
            self.traslucentBackView.alpha = 0
            let frame = CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: ScreenHeight / 2)
            self.backView.frame = frame
        }) { (finished) in
            if finished {
                if(self.block != nil){
                    self.block!()
                }
                self.isHidden = true
            }
        }
    }
    
    // MARK: - lazy loading ----
    lazy var traslucentBackView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        view.backgroundColor = UIColorFromRgb(rgbValue: 0x000000, a: 0.6)
        return view
    }()
    
    lazy var backView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: ScreenHeight / 2.0, width: ScreenWidth, height: ScreenHeight))
        return view
    }()
    
    lazy var correctLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: 0, y: ScreenHeight / 4 - 60, width: ScreenWidth, height: 40))
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textColor = .black
        label.text = "Correct！"
        return label
    }()
    
    lazy var scoreLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: 0, y: self.correctLabel.top - 45, width: ScreenWidth, height: 20))
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.text = "Score："
        return label
    }()

    lazy var continueLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: 0, y: self.correctLabel.bottom + 45, width: ScreenWidth, height: 20))
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.text = "Click to continue!"
        return label
    }()
    
}
