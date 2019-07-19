//
//  PlayView.swift
//  DoubleGames
//
//  Created by 刘岑颖 on 2019/6/21.
//  Copyright © 2019 lcy. All rights reserved.
//

import UIKit

class PlayView: UIView {
    
    var block:nextBlock?

    /*
     数字 tag = 100 101 102 103
     符号 tag = 110 111 112 113
     */
    @IBOutlet var numberAndSymbolButtons: [UIButton]!
    
    /*
     数字框 tag = 10 11 12 13
     符号框 tag = 20 21 22
     */
    @IBOutlet var answerButtons: [LCYButton]!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    var question: Question! {
        didSet {
            let button0 = self.viewWithTag(100) as! UIButton
            button0.setTitle(question.number0, for: .normal)
            
            let button1 = self.viewWithTag(101) as! UIButton
            button1.setTitle(question.number1, for: .normal)
            
            let button2 = self.viewWithTag(102) as! UIButton
            button2.setTitle(question.number2, for: .normal)
            
            let button3 = self.viewWithTag(103) as! UIButton
            button3.setTitle(question.number3, for: .normal)
        }
    }
    
    //记录当前拖动的按钮的原始中心
    var originalPoint: CGPoint!
    
    var theme: Theme! {
        didSet {
            self.backgroundColor = theme.backColor
            for button in numberAndSymbolButtons {
                button.layer.borderColor = theme.borderColor.cgColor
            }
            
            for button in answerButtons {
                button.layer.borderColor = theme.borderColor.cgColor
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        warningLabel.isHidden = true
        warningLabel.layer.cornerRadius = 4
        warningLabel.layer.masksToBounds = true
        
        for button in numberAndSymbolButtons {
            self.bringSubviewToFront(button)
            button.layer.cornerRadius = 25
            button.layer.masksToBounds = true
            button.layer.borderWidth = 2
            
            //添加拖动事件
            let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panAction(sender:)))
            button.addGestureRecognizer(pan)
        }
        
        for button in answerButtons {
            self.sendSubviewToBack(button)
            button.layer.cornerRadius = 6
            button.layer.borderWidth = 2
            button.layer.masksToBounds = true
        }
    }
    
    // MARK: - methods ----
    
    @IBAction func resetAction(_ sender: UIButton) {
        reset()
    }
    
    public func reset() {
        for button in numberAndSymbolButtons {
            button.isHidden = false
        }
        
        for button in answerButtons {
            if button.tag > 0 {
                button.setTitle("", for: .normal)
                button.currentNumberButtonTag = nil
            }
        }
    }
    
    @IBAction func okAction(_ sender: Any) {
        for button in answerButtons {
            if button.currentTitle == "" || button.currentTitle == nil {
                showWarning(string: "  请填写完整  ")
                return
            }
        }
        
        if calculate() == true {
            //成功
            showWarning(string: "  成功  ")
            if(self.block != nil){
                self.block!()
            }
        } else {
            //失败
            showWarning(string: "  失败  ")
        }
    }
    
    func calculate() -> Bool {
        var numbers = [String]()
        var symbols = [String]()
        for i in 10 ... 13 {
            let button = self.viewWithTag(i) as! UIButton
            numbers.append(button.currentTitle!)
        }
        
        for i in 20 ... 22 {
            let button = self.viewWithTag(i) as! UIButton
            symbols.append(button.currentTitle!)
        }
        
        var result: Float = Float(numbers.first!)!
        for i in 0 ... symbols.count - 1 {
            let number = numbers[i+1]
            let string = symbols[i]
            if string == "+" {
                result = result + Float(number)!
            }
            if string == "-" {
                result = result - Float(number)!
            }
            if string == "X" {
                result = result * Float(number)!
            }
            if string == "/" {
                result = result / Float(number)!
            }
        }
        
        if result == 24 {
            return true
        }
        
        return false
    }
    
    func showWarning(string: String) {
        warningLabel.text = string
        warningLabel.isHidden = false
        warningLabel.alpha = 0
        UIView.animate(withDuration: 0.8, animations: {
            self.warningLabel.alpha = 1
        }) { (finished) in
            UIView.animate(withDuration: 0.8, animations: {
                self.warningLabel.alpha = 0
            }, completion: { (finished) in
                self.warningLabel.isHidden = true
            })
        }
    }
    
    @objc func panAction(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            self.originalPoint = sender.view?.center
        case .ended:
            let button = sender.view as! UIButton
            self.check(button: button)
            button.center = originalPoint
        default:
            let point = sender.translation(in: sender.view)
            sender.view?.center = CGPoint.init(x: (sender.view?.center.x)! + point.x, y: (sender.view?.center.y)! + point.y)
            sender.setTranslation(CGPoint.zero, in: self)
            break;
        }
    }
    
    func check(button: UIButton) -> Void {
        let currentTitle = button.currentTitle
        //如果是+-x/
        if currentTitle == "+" || currentTitle == "-" || currentTitle == "X" || currentTitle == "/"  {
            
            for answerButton in answerButtons {
                if answerButton.tag > 19 && answerButton.tag < 23 && answerButton.frame.intersects(button.frame) {
                    answerButton.setTitle(currentTitle, for: .normal)
                    return
                }
            }
            
        } else {
            //如果是数字
            //循环所有的答案框，判断是否有与当前拖动的按钮重叠的答案框
            for answerButton in answerButtons {
                //判断是数字框并且重叠
                if answerButton.tag < 14 && answerButton.tag > 9 && answerButton.frame.intersects(button.frame) {
                    //如果当前重叠的答案框是空的
                    if answerButton.currentTitle == nil {
                        answerButton.currentNumberButtonTag = button.tag
                        button.isHidden = true
                    } else {
                        //如果当前答案框有答案的
                        if (answerButton.currentNumberButtonTag != nil) {
                            //找到被替换的数字的按钮，展示
                            let needShowButton = self.viewWithTag(answerButton.currentNumberButtonTag!) as! UIButton
                            needShowButton.isHidden = false
                        }
                        answerButton.currentNumberButtonTag = button.tag
                        button.isHidden = true
                    }
                    
                    answerButton.setTitle(currentTitle, for: .normal)

                    return
                }
            }
        }
        
        
    }
    
}
