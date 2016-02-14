/*
 * Copyright (c) 2016 Tim van Elsloo
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import UIKit

class KnobView: UIView {
    private let thinLayer   = CAShapeLayer()
    private let thickLayer  = CAShapeLayer()
    private let arrowLayer  = CAShapeLayer()
    private let stableLayer = CALayer()
    private let turnLayer   = CALayer()
    private let labels      = (0 ... 4).map { _ in CATextLayer() }
    private var timer: NSTimer?
    
    var distance: Double = 0 {
        didSet {
            let angle = CGFloat(distance * M_PI)
            turnLayer.setAffineTransform(CGAffineTransformMakeRotation(-angle))
            
            for label in labels {
                label.setAffineTransform(CGAffineTransformMakeRotation(angle))
            }
        }
    }
    
    var pitch: Pitch? = nil {
        didSet {
            if pitch != nil {
                updated = 1
                UIView.animateWithDuration(0.2, delay: 0.0,
                        usingSpringWithDamping: 1.0,
                        initialSpringVelocity: 0.0,
                        options: .CurveLinear, animations: {
                    self.alpha = 1.0
                }, completion: nil)

                for (i, label) in labels.enumerate() {
                    label.string = (pitch! + i - 2).description
                }
            }else {
                for label in labels {
                    label.string = ""
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.alpha                 = 0.5
        
        turnLayer.frame            = self.bounds
        self.layer.addSublayer(turnLayer)

        let frame                  = CGRectInset(self.bounds, 8.0, 8.0)
        let path                   = UIBezierPath(ovalInRect: frame).CGPath
        let strokeColor            = UIColor.whiteColor().CGColor

        thinLayer.frame            = frame
        thinLayer.path             = path
        thinLayer.strokeColor      = strokeColor
        thinLayer.lineWidth        = 16.0
        thinLayer.fillColor        = UIColor.clearColor().CGColor
        thinLayer.lineDashPattern  = [ 0.5, 5.5 ]
        thinLayer.lineDashPhase    = 0.25
        turnLayer.addSublayer(thinLayer)
        
        thickLayer.frame           = frame
        thickLayer.path            = path
        thickLayer.strokeColor     = strokeColor
        thickLayer.lineWidth       = 16.0
        thickLayer.fillColor       = UIColor.clearColor().CGColor
        thickLayer.lineDashPattern = [ 1.5, 58.5 ]
        thickLayer.lineDashPhase   = 0.75
        turnLayer.addSublayer(thickLayer)
        
        let arrowPath = UIBezierPath()
        arrowPath.moveToPoint(CGPointMake(8.0, 0.0))      /* Top */
        arrowPath.addLineToPoint(CGPointMake(16.0, 13.0)) /* Right */
        arrowPath.addLineToPoint(CGPointMake(0.0,  13.0)) /* Left */
        arrowPath.addLineToPoint(CGPointMake(8.0,  0.0))  /* Back to top */
        arrowPath.closePath()
        
        arrowLayer.frame           = CGRectMake(0.0, 0.0, 16.0, 13.0)
        arrowLayer.path            = arrowPath.CGPath
        arrowLayer.fillColor       = UIColor.redColor().CGColor
        turnLayer.addSublayer(arrowLayer)
        
        stableLayer.frame           = CGRectMake(0.0, -56.0, 5.0, 72.0)
        stableLayer.backgroundColor = thickLayer.strokeColor
        self.layer.addSublayer(stableLayer)
        
        for (i, label) in labels.enumerate() {
            label.frame               = CGRectMake(0.0, 0.0, 80.0, 40.0)
            label.alignmentMode       = kCAAlignmentCenter
            label.contentsScale       = UIScreen.mainScreen().scale
            label.foregroundColor     = UIColor.whiteColor().CGColor
            label.font                = UIFont.systemFontOfSize(17, weight: UIFontWeightUltraLight)
            label.fontSize            = 17.0
            
            if i == 2 {
                label.font            = UIFont.systemFontOfSize(36, weight: UIFontWeightUltraLight)
                label.fontSize       *= 2.0
            }
            
            turnLayer.addSublayer(label)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var frame: CGRect {
        didSet {
            turnLayer.frame       = self.bounds
            turnLayer.anchorPoint = CGPointMake(0.5, 0.5)

            let frame         = CGRectInset(self.bounds, 8.0, 8.0)
            let path          = UIBezierPath(ovalInRect: thinLayer.bounds)
            
            thinLayer.frame   = frame
            thinLayer.path    = path.CGPath
            
            thickLayer.frame  = frame
            thickLayer.path   = path.CGPath
            
            arrowLayer.frame  = CGRect(
                origin: CGPoint(
                    x: round(self.bounds.width / 2.0 - 8.0),
                    y: -22.0
                ),
                size:   CGSize(
                    width:  16.0,
                    height: 13.0
                )
            )
            stableLayer.frame = CGRect(
                origin: CGPoint(
                    x: round(self.bounds.width / 2.0 - 2.5),
                    y: -56.0
                ),
                size:  CGSize(
                    width:  5.0,
                    height: 72.0
                )
            )
            
            
            for (i, label) in labels.enumerate() {
                let offset: CGFloat = 30.0 + (i == 2 ? 50.0 : 0.0)
                
                let half = CGSizeMake(self.bounds.width / 2.0 + offset, self.bounds.height / 2.0 + offset)
                let center = CGPointMake(half.width - half.width * sin(CGFloat(i - 5) / 6 * 2 * 3.14) - offset,
                                         half.height + half.height * cos(CGFloat(i - 5) / 6 * 2 * 3.14) - offset)
                label.frame.origin.x = center.x - label.frame.size.width / 2.0
                label.frame.origin.y = center.y - label.frame.size.height / 2.0
            }
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        if self.window == nil {
            self.timer?.invalidate()
        }else {
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
                                                   selector: "tick",
                                                   userInfo: nil, repeats: true)
        }
    }

    private var updated = 0

    func tick() {
        if updated == 0 {
            self.distance = 0.0
            self.pitch    = nil

            UIView.animateWithDuration(1.0, delay: 0.0,
                                       usingSpringWithDamping: 1.0,
                                       initialSpringVelocity: 0.0,
                                       options: .CurveLinear, animations: {
                self.alpha = 0.5
            }, completion: nil)
        }else {
            updated = 0
        }
    }
}
