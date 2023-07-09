//
//  ChatItemView.swift
//  Messenger
//
//  Created by Александр Шерий on 31.12.2022.
//

import UIKit

class ChatItemView: UIView {
    private let text = "Lorem Ipsum - это текст-рыба, часто используемый в печати и вэб-дизайне. Lorem Ipsum является стандартной рыбой для текстов на латинице с начала XVI века. В то время некий безымянный печатник создал большую коллекцию размеров и форм шрифтов, используя Lorem Ipsum для распечатки образцов. Lorem Ipsum не только успешно пережил без заметных изменений пять веков, но и перешагнул в электронный дизайн. Его популяризации в новое время послужили публикация листов Letraset с образцами Lorem Ipsum в 60-х годах и, в более недавнее время, программы электронной вёрстки типа Aldus PageMaker, в шаблонах которых используется Lorem Ipsum."
    private var message: NSString!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        message = NSString(string: text)
        
        translatesAutoresizingMaskIntoConstraints = true
        backgroundColor = UIColor.systemGray
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.textMatrix = .identity
        context.translateBy(x: 0, y: bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let attributedString = NSAttributedString(string: text)
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        let textFrame = CTFramesetterCreateFrame(framesetter, CFRange(), CGPath(rect: bounds, transform: nil), nil)
        
        CTFrameDraw(textFrame, context)
    }
    
    func setMessage() {
        guard let containerWidth = superview?.frame.width else { return }
        let maxContentWidth = containerWidth - 48
        frame = CGRect(origin: CGPoint(x: 0, y: 100), size: sizeOfString(string: text, constrainedToWidth: maxContentWidth))
        // message.draw(at: .zero)
        // message.draw(in: CGRect(origin: .zero, size: CGSize(width: maxContentWidth, height: 100)))
    }
    
    func sizeOfString (string: String, constrainedToWidth width: CGFloat) -> CGSize {
        let attString = NSAttributedString(string: string)
        let framesetter = CTFramesetterCreateWithAttributedString(attString)
        return CTFramesetterSuggestFrameSizeWithConstraints(
            framesetter,
            CFRange(),
            nil,
            CGSize(width: width, height: .greatestFiniteMagnitude),
            nil
        )
    }
}

extension UILabel {
    func getLastLineWidth() -> CGFloat {
        guard let message = self.attributedText else { return CGFloat.zero }

        let labelWidth = self.frame.width
        let labelHeight = self.frame.height
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let labelSize = CGSize(width: labelWidth, height: labelHeight)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: labelSize)
        let textStorage = NSTextStorage(attributedString: message)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = .byWordWrapping
        textContainer.maximumNumberOfLines = 0

        let lastGlyphIndex = layoutManager.glyphIndexForCharacter(at: message.length - 1)
        return layoutManager.lineFragmentUsedRect(forGlyphAt: lastGlyphIndex, effectiveRange: nil).width
        // let lastLineFragmentRect = layoutManager.lineFragmentUsedRect(forGlyphAt: lastGlyphIndex, effectiveRange: nil)
        //return lastLineFragmentRect.maxX
    }
}
