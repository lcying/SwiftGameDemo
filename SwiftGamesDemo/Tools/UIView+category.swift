//
//  UIView+category.swift
//  DoubleGames
//
//  Created by 刘岑颖 on 2019/6/21.
//  Copyright © 2019 lcy. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    public var x:CGFloat {
        set {
            var f = self.frame
            f.origin.x = newValue
            self.frame = f
        }
        
        get {
            return self.frame.origin.x
        }
    }
    
    public var y:CGFloat {
        set {
            var f = self.frame
            f.origin.y = newValue
            self.frame = f
        }
        
        get {
            return self.frame.origin.y
        }
    }
    
    public var left:CGFloat{
        set{
            var f = self.frame
            f.origin.x = newValue
            self.frame = f
        }
        get{
            return self.frame.origin.x
        }
    }
    public var right:CGFloat{
        set{
            var f = self.frame
            f.origin.x = newValue - self.frame.size.width
            self.frame = f
        }
        get{
            return self.frame.origin.x+self.frame.size.width
        }
    }
    public var top:CGFloat{
        set{
            var f = self.frame
            f.origin.y = newValue
            self.frame = f
        }
        get{
            return self.frame.origin.y
        }
    }
    public var width:CGFloat{
        set{
            var f = self.frame
            f.size.width = newValue
            self.frame = f
        }
        get{
            return self.frame.size.width
        }
    }
    public var height:CGFloat
    {
        set{
            var f = self.frame
            f.size.height = newValue
            self.frame = f
        }
        get{
            return self.frame.size.height
        }
    }
    public var bottom:CGFloat
    {
        set{
            var f = self.frame
            f.origin.y = newValue - self.frame.size.width
            self.frame = f
        }
        get{
            return self.frame.origin.y + self.frame.size.height
        }
    }
    public func circleView()->Void
    {
        self.layer.cornerRadius = self.width * 0.5;
        self.clipsToBounds = true
    }
}
