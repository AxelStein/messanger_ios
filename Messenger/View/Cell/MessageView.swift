//
//  MessageView.swift
//  Project
//
//  Created by Александр Шерий on 01.07.2023.
//

import UIKit

@IBDesignable class MessageView: UIView {
    private var messageId: Int64 = 0
    private var replyAuthor = NSMutableAttributedString()
    private var replyText = NSMutableAttributedString()
    
    private var text = NSMutableAttributedString()
    private var time = NSMutableAttributedString()
    
    private let defaultCornerSize = CGFloat(16)
    private let smallCornerSize = CGFloat(4)
    private let tailSize = CGFloat(12)
    
    private var topLeftCorner = CGFloat(0)
    private var topRightCorner = CGFloat(0)
    private var bottomRightCorner = CGFloat(0)
    private var bottomLeftCorner = CGFloat(0)
    
    private var drawTail = true
    private var cardRect = CGRect()
    private var contentRect = CGRect()
    private var replyRect = CGRect()
    private var messageRect = CGRect()
    private var imageRect = CGRect()
    
    private var image: UIImage? = nil
    private var imageUrl: URL? = nil
    private var cropImage = false
    private let textPadding = CGFloat(8)
    private let iconRead = UIImage(named: "done_all")
    private let iconUnread = UIImage(named: "done")
    private let iconPlay = UIImage(named: "play_24pt")
    private let iconSize = CGFloat(14)
    private let replyDividerWidth = CGFloat(2)
    private var replyDividerHeight = CGFloat(0)
    private var srcImageWidth = CGFloat(0)
    private var srcImageHeight = CGFloat(0)
    
    private var hasReply = false
    private var hasImage = false
    private var hasFile = false
    private var hasAudio = false
    private var hasJson = false
    private var hasVideo = false
    
    private var statusIcon: UIImage? {
        get {
            if isRead {
                return iconRead
            }
            return iconUnread
        }
    }
    
    @IBInspectable var isRead: Bool = false
    
    @IBInspectable var isOwn: Bool = true
    
    @IBInspectable var messageText: String {
        set {
            text.mutableString.setString(newValue)
            invalidateIntrinsicContentSize()
        }
        get { return text.string }
    }
    
    @IBInspectable var messageTime: String {
        set {
            time.mutableString.setString(newValue)
            invalidateIntrinsicContentSize()
        }
        get { return time.string }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
    private func _init() {
        topLeftCorner = defaultCornerSize
        topRightCorner = defaultCornerSize
        bottomLeftCorner = defaultCornerSize
        bottomRightCorner = defaultCornerSize
    }
    
    func setMessage(_ message: Message.Data) {
        messageId = message.id
        // setMessageGroup(message.group)
        text.mutableString.setString(message.content.text ?? "")
        time.mutableString.setString(message.time)
        isRead = message.isRead
        isOwn = message.isOwn
        hasImage = message.content.mimeType == .image || message.content.mimeType == .video
        hasFile = message.content.mimeType == .file
        hasAudio = message.content.mimeType == .audio
        hasJson = message.content.mimeType == .text
        hasVideo = message.content.mimeType == .video
        image = nil
        cropImage = false
        if let s = message.content.file?.conversionsImages?["thumb_big"], let url = URL(string: s) {
            imageUrl = url
        } else {
            imageUrl = nil
        }
        if let resolution = message.content.file?.metadata?.resolution {
            srcImageWidth = CGFloat(resolution.width)
            srcImageHeight = CGFloat(resolution.height)
        } else {
            srcImageWidth = .zero
            srcImageHeight = .zero
        }
        /*
        hasReply = message.reply != nil
        replyAuthor.mutableString.setString(message.reply?.author ?? "")
        replyText.mutableString.setString(message.reply?.text ?? "")
        */
        
        let replyAuthorRange = NSRange(location: 0, length: replyAuthor.length)
        let replyTextRange = NSRange(location: 0, length: replyText.length)
        let textRange = NSRange(location: 0, length: text.length)
        let timeRange = NSRange(location: 0, length: time.length)
        
        let oneLineParagraphStyle = NSMutableParagraphStyle()
        oneLineParagraphStyle.lineBreakMode = .byTruncatingTail
        
        let textParagraphStyle = NSMutableParagraphStyle()
        textParagraphStyle.lineSpacing = 2
        
        let singleImage = hasImage && text.length == 0
        
        if isOwn {
            replyAuthor.setAttributes([.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.white, .paragraphStyle: oneLineParagraphStyle], range: replyAuthorRange)
            replyText.setAttributes([.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.white.withAlphaComponent(0.75), .paragraphStyle: oneLineParagraphStyle], range: replyTextRange)
            
            text.setAttributes([.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.white, .paragraphStyle: textParagraphStyle], range: textRange)
            time.setAttributes([.font: UIFont.systemFont(ofSize: 12), .foregroundColor: singleImage ? UIColor.white : UIColor.white.withAlphaComponent(0.75)], range: timeRange)
        } else {
            replyAuthor.setAttributes([.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.black, .paragraphStyle: oneLineParagraphStyle], range: replyAuthorRange)
            replyText.setAttributes([.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.black.withAlphaComponent(0.75), .paragraphStyle: oneLineParagraphStyle], range: replyTextRange)
            
            text.setAttributes([.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.black, .paragraphStyle: textParagraphStyle], range: textRange)
            time.setAttributes([.font: UIFont.systemFont(ofSize: 12), .foregroundColor: singleImage ? UIColor.white : UIColor.systemGray], range: timeRange)
        }
        
        invalidateIntrinsicContentSize()
        setNeedsDisplay()
    }
    
    func setMessageGroup(_ group: Message.Group) {
        drawTail = group == .end || group == .none
        switch group {
        case .start:
            topLeftCorner = defaultCornerSize
            topRightCorner = defaultCornerSize
            bottomRightCorner = isOwn ? smallCornerSize : defaultCornerSize
            bottomLeftCorner = isOwn ? defaultCornerSize : smallCornerSize
        case .body:
            topLeftCorner = isOwn ? defaultCornerSize : smallCornerSize
            topRightCorner = isOwn ? smallCornerSize : defaultCornerSize
            bottomRightCorner = isOwn ? smallCornerSize : defaultCornerSize
            bottomLeftCorner = isOwn ? defaultCornerSize : smallCornerSize
        case .end:
            topLeftCorner = isOwn ? defaultCornerSize : smallCornerSize
            topRightCorner = isOwn ? smallCornerSize : defaultCornerSize
            bottomRightCorner = isOwn ? smallCornerSize : defaultCornerSize
            bottomLeftCorner = defaultCornerSize
        case .none:
            topLeftCorner = defaultCornerSize
            topRightCorner = defaultCornerSize
            bottomRightCorner = defaultCornerSize
            bottomLeftCorner = defaultCornerSize
        }
    }
    
    override func prepareForInterfaceBuilder() {
        invalidateIntrinsicContentSize()
    }
    
    func resizeImage(image: UIImage?, rect: CGRect) -> UIImage? {
        guard let image = image else { return nil }
        return ImageScaler.scaleToFill(image, in: rect.size)
    }
    
    /*
    func resizeImage(with image: UIImage?, rect: CGRect) -> UIImage? {
        guard let image = image else { return nil }
        if image.size.width == 0 { return nil }
        if image.size.height == 0 { return nil }
        let scaleSize = rect.size
        let scale = max(scaleSize.width / image.size.width, scaleSize.height / image.size.height)
        let width = image.size.width * scale
        let height = image.size.height * scale
        let imageRect = CGRect(x: (scaleSize.width - width) / 2.0, y: (scaleSize.height - height) / 2.0, width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        image.draw(in: CGRect(x: x, y: y, width: rect.width, height: rect.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    */
    
    override var intrinsicContentSize: CGSize {
        let parentWidth = superview?.superview?.frame.width ?? 0
        if hasAudio || hasFile {
            return CGSize(width: parentWidth, height: 0)
        }
        let maxContentWidth = max(parentWidth - 48 - tailSize, 0)
        let messageSize = measureMessageText(maxContentWidth: maxContentWidth)
        var replySize = CGSize()
        var imageSize = CGSize()

        if hasImage {
            imageSize = measureImage(maxContentWidth: maxContentWidth)
        }
        if hasReply {
            replySize = measureReply(maxContentWidth: max(messageSize.width, imageSize.width))
        }
        
        var totalSize = CGSize()
        totalSize.width = max(messageSize.width, replySize.width)
        totalSize.width = max(totalSize.width, imageSize.width)
        totalSize.height = messageSize.height
        if hasReply {
            totalSize.height += replySize.height + 8
        }
        if hasImage {
            totalSize.height += imageSize.height
            if hasReply {
                totalSize.height += 8
            }
        }
        
        cardRect = CGRect(origin: .zero, size: totalSize)
        cardRect.size.width += tailSize
        if messageSize != .zero {
            cardRect.size.height += 16
        }
        if isOwn {
            cardRect.origin.x = parentWidth - cardRect.width
        }
        
        contentRect = CGRect(origin: cardRect.origin, size: totalSize)
        if !isOwn {
            contentRect.origin.x += tailSize
        }
        if messageSize != .zero {
            contentRect = contentRect.offsetBy(dx: 0, dy: 8)
        }
        
        if hasReply {
            replyRect = CGRect(origin: contentRect.origin, size: replySize)
        } else {
            replyRect = CGRect()
        }
        if hasImage {
            imageRect = CGRect(origin: CGPoint(x: contentRect.origin.x, y: contentRect.origin.y - (messageSize == .zero ? 0 : 8)), size: imageSize)
            if hasReply {
                imageRect = CGRect(origin: CGPoint(x: contentRect.origin.x, y: replyRect.maxY + 8), size: imageSize)
            }
        } else {
            imageRect = CGRect()
        }
        
        messageRect = CGRect(origin: contentRect.origin, size: messageSize)
        if hasReply {
            messageRect.origin.y = replyRect.maxY
            messageRect = messageRect.offsetBy(dx: 0, dy: 8)
        }
        if hasImage {
            messageRect.origin.y = imageRect.maxY
            messageRect = messageRect.offsetBy(dx: 0, dy: 8)
            
            if imageRect.width > messageRect.width {
                messageRect.size.width = imageRect.width
            }
            
            if totalSize.width > imageSize.width {
                cropImage = true
                imageRect = CGRect(origin: imageRect.origin, size: CGSize(width: totalSize.width, height: imageRect.height))
            }
            
            if let url = imageUrl {
                imageLoader.load(url: url, id: messageId) { id, img in
                    if self.messageId == id {
                        self.image = self.cropImage ? self.resizeImage(image: img, rect: self.imageRect) : img
                        self.setNeedsDisplay()
                    }
                }
            }
        }
        return CGSize(width: parentWidth, height: cardRect.height + 4)
    }
    
    private func measureImage(maxContentWidth: CGFloat) -> CGSize {
        let srcSize = CGSize(width: srcImageWidth, height: srcImageHeight) // image?.size else { return CGSize() }
        
        let maxWidth = maxContentWidth
        let maxHeight = maxWidth * 1.1
        let minSize = maxWidth / 4
        
        var width = maxContentWidth
        var height = width * srcSize.height / srcSize.width
        if height < minSize {
            height = minSize
            width = maxHeight * srcSize.width / srcSize.height
        } else if height > maxHeight {
            height = maxHeight
            width = maxHeight * srcSize.width / srcSize.height
        }
        
        width = constrainValue(value: width, min: minSize, max: maxWidth)
        height = constrainValue(value: height, min: minSize, max: maxHeight)
        
        return CGSize(width: width, height: height)
    }
    
    private func measureReply(maxContentWidth: CGFloat) -> CGSize {
        let totalPadding = textPadding * 3 + replyDividerWidth
        let maxTextWidth = maxContentWidth - totalPadding
        let authorSize = replyAuthor.size()
        let textSize = replyText.size()
        let w = min(
            maxTextWidth,
            max(
                ceil(authorSize.width),
                ceil(textSize.width)
            )
        ) + totalPadding
        let h = ceil(authorSize.height) + ceil(textSize.height)
        replyDividerHeight = h
        return CGSize(width: w, height: h)
    }
    
    private func measureMessageText(maxContentWidth: CGFloat) -> CGSize {
        if text.length == 0 {
            return .zero
        }
        
        let padding = textPadding * 2
        let maxWidth = maxContentWidth - padding
        let timeRect = time.boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            context: nil
        )
        
        var iconWidth = CGFloat(0)
        if isOwn {
            iconWidth += iconSize
            iconWidth += 4
        }
        
        let endPadding = NSTextAttachment()
        endPadding.bounds = CGRect(
            origin: .zero,
            size: CGSize(
                width: ceil(timeRect.width) + textPadding + iconWidth,
                height: .zero
            )
        )
        text.append(NSAttributedString(attachment: endPadding))
        
        let textRect = text.boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            context: nil
        )
        return CGSize(
            width: ceil(textRect.width) + padding,
            height: ceil(textRect.height)
        )
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if hasFile || hasAudio {
            return
        }
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let singleImage = hasImage && text.length == 0
        if !singleImage {
            if isOwn {
                drawOwnBubble()
            } else {
                drawPartnerBubble()
            }
        }
        
        if hasReply {
            if isOwn {
                UIColor.white.setFill()
            } else {
                UIColor.systemBlue.setFill()
            }
            ctx.fill([
                CGRect(
                    origin: CGPoint(x: replyRect.origin.x + textPadding, y: replyRect.origin.y),
                    size: CGSize(width: replyDividerWidth, height: replyDividerHeight)
                )
            ])
            
            var baseRect = replyRect.offsetBy(dx: replyDividerWidth + textPadding * 2, dy: 0)
            baseRect.size.width -= (replyDividerWidth + textPadding * 3)
            
            let authorRect = CGRect(origin: baseRect.origin, size: CGSize(width: baseRect.width, height: replyAuthor.size().height))
            replyAuthor.draw(in: authorRect)
            
            let textRect = CGRect(origin: CGPoint(x: authorRect.origin.x, y: authorRect.maxY), size: CGSize(width: baseRect.width, height: replyText.size().height))
            replyText.draw(in: textRect)
        }
        
        if hasImage {
            ctx.saveGState()
            if !hasReply {
                var path: CGPath!
                if !singleImage {
                    path = UIBezierPath(roundedRect: imageRect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: defaultCornerSize, height: defaultCornerSize)).cgPath
                } else {
                    path = UIBezierPath(roundedRect: imageRect, cornerRadius: defaultCornerSize).cgPath
                }
                ctx.addPath(path)
                ctx.clip()
            }
            image?.draw(in: imageRect)
            ctx.restoreGState()
            
            if hasVideo {
                if let icon = iconPlay {
                    let iconRect = CGRect(x: imageRect.midX - icon.size.width / 2, y: imageRect.midY - icon.size.height / 2, width: icon.size.width, height: icon.size.height)
                    
                    UIColor.black.withAlphaComponent(0.4).set()
                    ctx.fillEllipse(in: iconRect.insetBy(dx: -12, dy: -12))
                    
                    UIColor.white.set()
                    icon.draw(at: iconRect.origin)
                }
            }
        }
        
        text.draw(in: messageRect.insetBy(dx: textPadding, dy: 0))
        
        let iconSpace = isOwn ? iconSize + 4 : .zero
        let timeSize = time.size()
        let originSrc = singleImage ? imageRect.offsetBy(dx: -8, dy: -12) : messageRect
        let timeOrigin = CGPoint(
            x: originSrc.maxX - timeSize.width - textPadding - iconSpace,
            y: originSrc.maxY - timeSize.height
        )
        let iconOrigin = CGPoint(
            x: originSrc.maxX - iconSize - textPadding,
            y: originSrc.maxY - iconSize
        )
        if singleImage {
            let bgRect = CGRect(origin: timeOrigin, size: CGSize(width: timeSize.width + iconSpace, height: max(timeSize.height, (isOwn ? iconSize : .zero)))).insetBy(dx: -8, dy: -4)
            UIColor.black.withAlphaComponent(0.3).setFill()
            UIBezierPath(roundedRect: bgRect, cornerRadius: bgRect.height / 2).fill()
        }
        time.draw(at: timeOrigin)
        if isOwn {
            statusIcon?.draw(in: CGRect(origin: iconOrigin, size: CGSize(width: iconSize, height: iconSize)))
        }
    }
    
    private func drawOwnBubble() {
        let topLeft = cardRect.origin
        let topRight = CGPoint(x: cardRect.maxX - tailSize, y: cardRect.minY)
        let bottomRight = CGPoint(x: cardRect.maxX - tailSize, y: cardRect.maxY)
        let bottomLeft = CGPoint(x: cardRect.minX, y: cardRect.maxY)
        
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
                to: CGPoint(x: frame.width, y: bottomRight.y),
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
        
        UIColor.systemBlue.set()
        path.fill()
    }
    
    private func drawPartnerBubble() {
        let topLeft = CGPoint(x: cardRect.minX + tailSize, y: cardRect.minY)
        let topRight = CGPoint(x: cardRect.maxX, y: cardRect.minY)
        let bottomRight = CGPoint(x: cardRect.maxX, y: cardRect.maxY)
        let bottomLeft = CGPoint(x: cardRect.minX + tailSize, y: cardRect.maxY)
        
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
        
        UIColor.systemGray5.set()
        path.fill()
    }
}
