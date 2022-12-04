//
//  MessageCell.swift
//  Messenger
//
//  Created by Александр Шерий on 04.12.2022.
//

import UIKit

class BubbleView: UIView {
    @IBInspectable var isOwn: Bool = true
    
    private let defaultCornerSize = CGFloat(20)
    private let smallCornerSize = CGFloat(8)
    
    private var topLeftCorner = CGFloat(20)
    private var topRightCorner = CGFloat(20)
    private var bottomRightCorner = CGFloat(20)
    private var bottomLeftCorner = CGFloat(20)
    
    private var drawTail = true
    
    func setMessageGroup(_ group: Message.Group) {
        switch group {
        case .start:
            topLeftCorner = defaultCornerSize
            topRightCorner = defaultCornerSize
            bottomRightCorner = isOwn ? smallCornerSize : defaultCornerSize
            bottomLeftCorner = isOwn ? defaultCornerSize : smallCornerSize
            drawTail = false
        case .body:
            topLeftCorner = isOwn ? defaultCornerSize : smallCornerSize
            topRightCorner = isOwn ? smallCornerSize : defaultCornerSize
            bottomRightCorner = isOwn ? smallCornerSize : defaultCornerSize
            bottomLeftCorner = isOwn ? defaultCornerSize : smallCornerSize
            drawTail = false
        case .end:
            drawTail = true
            topLeftCorner = isOwn ? defaultCornerSize : smallCornerSize
            topRightCorner = isOwn ? smallCornerSize : defaultCornerSize
            bottomRightCorner = isOwn ? smallCornerSize : defaultCornerSize
            bottomLeftCorner = defaultCornerSize
        case .none:
            drawTail = true
            topLeftCorner = defaultCornerSize
            topRightCorner = defaultCornerSize
            bottomRightCorner = defaultCornerSize
            bottomLeftCorner = defaultCornerSize
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if isOwn {
            drawOwnBubble()
        } else {
            drawPartnerBubble()
        }
    }
    
    private func drawOwnBubble() {
        let tailSize = CGFloat(12)
        let topLeft = CGPoint(x: 0, y: 0)
        let topRight = CGPoint(x: frame.width - tailSize, y: 0)
        let bottomRight = CGPoint(x: frame.width - tailSize, y: frame.height)
        let bottomLeft = CGPoint(x: 0, y: frame.height)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: topLeft.x, y: topLeft.y + topLeftCorner))
        
        // top left corner
        path.addQuadCurve(
            to: CGPoint(x: topLeft.x + topLeftCorner, y: topLeft.y),
            controlPoint: topLeft
        )
        path.addLine(to: CGPoint(x: topRight.x - topRightCorner, y: topRight.y))
        
        // top right corner
        path.addQuadCurve(
            to: CGPoint(x: topRight.x, y: topRight.y + topRightCorner),
            controlPoint: topRight
        )
        
        // bottom right tail
        if drawTail {
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y - tailSize))
            path.addQuadCurve(
                to: CGPoint(x: frame.width, y: frame.height),
                controlPoint: CGPoint(x: bottomRight.x, y: bottomRight.y)
            )
        } else {
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y - bottomRightCorner))
            path.addQuadCurve(
                to: CGPoint(x: bottomRight.x - bottomRightCorner, y: bottomRight.y),
                controlPoint: bottomRight
            )
        }
        path.addLine(to: CGPoint(x: bottomLeft.x + bottomLeftCorner, y: bottomLeft.y))
        
        // bottom left corner
        path.addQuadCurve(
            to: CGPoint(x: bottomLeft.x, y: bottomLeft.y - bottomLeftCorner),
            controlPoint: bottomLeft
        )
        path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y + topLeftCorner))
        
        UIColor.init(named: "chat_bubble_own")?.set()
        path.fill()
    }
    
    private func drawPartnerBubble() {
        let tailSize = CGFloat(12)
        let topLeft = CGPoint(x: tailSize, y: 0)
        let topRight = CGPoint(x: frame.width, y: 0)
        let bottomRight = CGPoint(x: frame.width, y: frame.height)
        let bottomLeft = CGPoint(x: tailSize, y: frame.height)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: topLeft.x, y: topLeft.y + topLeftCorner))
        
        // top left corner
        path.addQuadCurve(
            to: CGPoint(x: topLeft.x + topLeftCorner, y: topLeft.y),
            controlPoint: topLeft
        )
        path.addLine(to: CGPoint(x: topRight.x - topRightCorner, y: topRight.y))
        
        // top right corner
        path.addQuadCurve(
            to: CGPoint(x: topRight.x, y: topRight.y + topRightCorner),
            controlPoint: topRight
        )
        
        // bottom right corner
        path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y - bottomRightCorner))
        path.addQuadCurve(
            to: CGPoint(x: bottomRight.x - bottomRightCorner, y: bottomRight.y),
            controlPoint: bottomRight
        )
        
        // bottom left tail
        if drawTail {
            path.addLine(to: CGPoint(x: 0, y: bottomLeft.y))
            path.addQuadCurve(
                to: CGPoint(x: bottomLeft.x, y: bottomLeft.y - tailSize),
                controlPoint: bottomLeft
            )
        } else {
            path.addLine(to: CGPoint(x: bottomLeft.x + bottomLeftCorner, y: bottomLeft.y))
            path.addQuadCurve(
                to: CGPoint(x: bottomLeft.x, y: bottomLeft.y - bottomLeftCorner),
                controlPoint: bottomLeft
            )
        }
        path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y + topLeftCorner))
        
        UIColor.init(named: "chat_bubble_partner")?.set()
        path.fill()
    }
}
