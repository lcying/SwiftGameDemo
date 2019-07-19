//
//  CALayer+Category.swift
//  DoubleGames
//
//  Created by 刘岑颖 on 2019/6/25.
//  Copyright © 2019 lcy. All rights reserved.
//

import UIKit

extension CALayer {
    func transformRotationAngle() -> CGFloat {
        /*
         atan 和 atan2 都是求反正切函数，如：有两个点 point(x1,y1), 和 point(x2,y2);
         那么这两个点形成的斜率的角度计算方法分别是：
         float angle = atan( (y2-y1)/(x2-x1) );
         或
         float angle = atan2( y2-y1, x2-x1 );
         
         atan 和 atan2 区别：
         1、参数的填写方式不同；
         2、atan2 的优点在于 如果 x2-x1等于0 依然可以计算，但是atan函数就会导致程序出错
         
         结论： atan 和 atan2函数，建议用 atan2函数
         */
        var degreeAngle:CGFloat = -CGFloat(atan2f(Float(self.presentation()!.transform.m21), Float(self.presentation()!.transform.m22)))
        if (degreeAngle < 0.0) {
            degreeAngle = degreeAngle + (CGFloat)(2.0 * Double.pi)
        }
        return degreeAngle;
    }
    
    //pink
    func convertPointWhenRotatingWithBenchmarkPoint(point:CGPoint,radius:CGFloat) -> CGPoint {
        let rotationAngle:CGFloat = (self.presentation()?.transformRotationAngle())!
        return CGPoint.init(x: point.x + CGFloat(sinf(Float(rotationAngle))) * radius, y: point.y - radius + CGFloat(cosf(Float(rotationAngle))) * radius)
    }
    
    //blue
    func convertPointWhenRotatingWithBenchmarkPoint2(point2:CGPoint,radius2:CGFloat) -> CGPoint {
        let rotationAngle:CGFloat = (self.presentation()?.transformRotationAngle())!
        return CGPoint.init(x: point2.x - CGFloat(sinf(Float(rotationAngle))) * radius2, y: point2.y - radius2 - CGFloat(cosf(Float(rotationAngle))) * radius2)
    }
    
    ///暂停动画
    func pauseAnimation() {
        //取出当前时间,转成动画暂停的时间
        let pausedTime = self.convertTime(CACurrentMediaTime(), from: nil)
        //设置动画运行速度为0
        self.speed = 0.0;
        //设置动画的时间偏移量，指定时间偏移量的目的是让动画定格在该时间点的位置
        self.timeOffset = pausedTime
    }
    ///恢复动画
    func resumeAnimation() {
        //获取暂停的时间差
        let pausedTime = self.timeOffset
        self.speed = 1.0
        self.timeOffset = 0.0
        self.beginTime = 0.0
        //用现在的时间减去时间差,就是之前暂停的时间,从之前暂停的时间开始动画
        let timeSincePause = self.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        self.beginTime = timeSincePause
    }
    
}
