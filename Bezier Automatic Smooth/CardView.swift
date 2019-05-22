//
//  CardView.swift
//  Set Game
//
//  Created by Bogdan Chernobrivec on 27.07.2018.
//  Copyright © 2018 Bogdan Chornobryvets. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    override func draw(_ rect: CGRect) {
        let shape = drawSquiggle()
        let path = shape.drawShape()
        path.lineWidth = strokeWidth
        let color = UIColor.green
        color.setStroke()
        color.setFill()
        path.stroke()
        
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        drawStripes(outline: path) // fills shape with stripes
        context.restoreGState()
        
        drawBezierControls(smoothBezier: shape) // Draw Bezier control points, comment it in real use
        
        self.sizeToFit()
    }
    
    func drawStripes(outline: UIBezierPath) {
        outline.addClip()
        let stripes = UIBezierPath()
        var xOffset: CGFloat = 0
        while xOffset < frame.width {
            stripes.move(to: CGPoint(x: xOffset, y: 0))
            stripes.addLine(to: CGPoint(x: xOffset, y: frame.height))
            xOffset += strokeWidth * 3
        }
        stripes.lineWidth = strokeWidth
        stripes.stroke()
    }
    
    //drawBezierControls(smoothBezier:) draw Bezier control points just for you to visually see result
    func drawBezierControls(smoothBezier bezier: SmoothBezier) {
        let thinStrokeWidth = strokeWidth / 2
        
        for (_, smoothPoint) in bezier.smoothControlPoints.enumerated() {
            let circle1 = UIBezierPath(arcCenter: smoothPoint.point, radius: thinStrokeWidth, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            let circle2 = UIBezierPath(arcCenter: smoothPoint.controlPointAfter, radius: thinStrokeWidth, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            let circle3 = UIBezierPath(arcCenter: smoothPoint.controlPointBefore, radius: thinStrokeWidth, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            let line = UIBezierPath()
            line.move(to: smoothPoint.controlPointAfter)
            line.addLine(to: smoothPoint.controlPointBefore)
            line.lineWidth = strokeWidth / 2
            UIColor.yellow.setStroke()
            line.stroke()
            UIColor.red.setFill()
            circle1.fill()
            UIColor.purple.setFill()
            circle2.fill()
            circle3.fill()
        }
    }
    
    // drawSquiggle() contains just certain control points for future bezier. Try to copy function and replace control points with another array of points
    func drawSquiggle() -> SmoothBezier {
        let controlPointsNumbers: [[CGFloat]] = [[0, shapeHeight * 0.66],
                                          [shapeWidth * 0.33, shapeHeight * 0.1],
                                          [shapeWidth * 0.66, shapeHeight * 0.25],
                                          [shapeWidth * 0.9, 0],
                                          [shapeWidth, shapeHeight * 0.33],
                                          [shapeWidth * 0.66, shapeHeight * 0.9],
                                          [shapeWidth * 0.33, shapeHeight * 0.75],
                                          [shapeWidth * 0.1, shapeHeight]]
        let shape = SmoothBezier(points: controlPointsNumbers, boundsWidth: frame.size.width, boundsHeight: frame.size.height, margin: shapeMargin, smoothinessRatio: 0.35)
        return shape
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = UIView.ContentMode.redraw
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinited shape...")
    }
    
}

//===== SmoothBezier class automatically generating bezier control points for perfect smoothing
//===== Points for initializer are ralative values from 0 to 1 inside bounds (height and width) for ease of size changing. You don't need to update all coordinates if you want to change shape size, just set bounds!
//===== Look for drawSquiggle() function to see SmoothBezier in use, it's pretty simple
struct SmoothBezier {
    var controlPoints: [CGPoint] {
        didSet {
            calculateSmoothPoints()
        }
    }
    var smoothControlPoints = [SmoothPoint]()
    var shapeWidth: CGFloat
    var shapeHeight: CGFloat
    var smoothinessRatio: CGFloat
    
    init (points: [[CGFloat]], boundsWidth: CGFloat, boundsHeight: CGFloat, margin: CGFloat = 0, smoothinessRatio: CGFloat = 33) {
        controlPoints = [CGPoint]()
        shapeWidth = boundsWidth - margin * 2
        shapeHeight = boundsHeight - margin * 2
        self.smoothinessRatio = smoothinessRatio
        for point in points { controlPoints.append(CGPoint(x: point[0] + margin, y: point[1] + margin))}
        calculateSmoothPoints()
    }
    
    func drawShape() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: smoothControlPoints.first!.point)
        for (index, smoothPoint) in smoothControlPoints.enumerated() {
            switch index {
            case _ where index < smoothControlPoints.count - 1:
                path.addCurve(to: smoothControlPoints[index + 1].point, controlPoint1: smoothPoint.controlPointAfter, controlPoint2: smoothControlPoints[index + 1].controlPointBefore)
            case _ where index == smoothControlPoints.count - 1:
                path.addCurve(to: smoothControlPoints.first!.point, controlPoint1: smoothPoint.controlPointAfter, controlPoint2: smoothControlPoints.first!.controlPointBefore)
            default:
                break
            }
        }
        path.close()
        return path
    }
    
    private mutating func calculateSmoothPoints() {
        smoothControlPoints = [SmoothPoint]()
        for (index, point) in controlPoints.enumerated() {
            switch index {
            case 0 where index < controlPoints.count - 1:
                smoothControlPoints.append(SmoothPoint(point: point, previousPoint: controlPoints.last!, nextPoint: controlPoints[index + 1], smoothinessRatio: smoothinessRatio))
            case _ where index < controlPoints.count - 1 && index > 0:
                smoothControlPoints.append(SmoothPoint(point: point, previousPoint: controlPoints[index - 1], nextPoint: controlPoints[index + 1], smoothinessRatio: smoothinessRatio))
            case _ where index == controlPoints.count - 1:
                smoothControlPoints.append(SmoothPoint(point: point, previousPoint: controlPoints[index - 1], nextPoint: controlPoints.first!, smoothinessRatio: smoothinessRatio))
            default:
                break
            }
        }
    }
    
    struct SmoothPoint {
        var point: CGPoint
        var controlPointBefore: CGPoint
        var controlPointAfter: CGPoint
        
        init (point: CGPoint, previousPoint: CGPoint, nextPoint: CGPoint, smoothinessRatio: CGFloat) {
            self.point = point
            
            let previousDistance = point.distance(to: previousPoint)
            let nextDistance = point.distance(to: nextPoint)
            let distance = previousPoint.distance(to: nextPoint)
            
            var previousRatio = previousDistance / distance
            var nextRatio = nextDistance / distance
            previousRatio = previousRatio > 1 ? smoothinessRatio : previousRatio * smoothinessRatio
            nextRatio = nextRatio > 1 ? smoothinessRatio : nextRatio * smoothinessRatio
            let offset = nextPoint.resetOrigin(to: previousPoint)
            controlPointAfter = CGPoint(x: point.x - offset.x * nextRatio, y: point.y - offset.y * nextRatio)
            controlPointBefore = CGPoint(x: point.x + offset.x * previousRatio, y: point.y + offset.y * previousRatio)
        }
    }
}

extension CGPoint {
    func resetOrigin(to previousPoint: CGPoint) -> CGPoint {
        return CGPoint(x: previousPoint.x - self.x, y: previousPoint.y - self.y)
    }
    func distance(to targetPoint: CGPoint) -> CGFloat {
        let basePoint = self.resetOrigin(to: targetPoint)
        return (basePoint.x.magnitude * basePoint.x.magnitude + basePoint.y.magnitude * basePoint.y.magnitude).squareRoot()
    }
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

extension CardView {
    private var strokeWidth: CGFloat {
        return frame.size.width * 0.02
    }
    private var shapeMargin: CGFloat {
        return strokeWidth * 4
    }
    private var shapeWidth: CGFloat {
        return frame.width - shapeMargin * 2
    }
    private var shapeHeight: CGFloat {
        return frame.height - shapeMargin * 2
    }
    private var shapeSize: CGSize {
        return CGSize(width: shapeWidth, height: shapeHeight)
    }
}
