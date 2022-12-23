//
//  Ext.swift
//  Messenger
//
//  Created by Александр Шерий on 17.12.2022.
//

import UIKit

extension UINavigationController {
    func replaceTopViewController(with viewController: UIViewController, animated: Bool) {
        var vcs = viewControllers
        vcs[vcs.count - 1] = viewController
        setViewControllers(vcs, animated: animated)
    }
}

extension String {
    var asDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.date(from: self)
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { it in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func resizedCircle(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { it in
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).addClip()
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension Date {
    var monthDayText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: self)
    }
    
    var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    var millis: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}

extension UIScrollView {

  var minContentOffset: CGPoint {
    return CGPoint(
      x: -contentInset.left,
      y: -contentInset.top)
  }

  var maxContentOffset: CGPoint {
    return CGPoint(
      x: contentSize.width - bounds.width + contentInset.right,
      y: contentSize.height - bounds.height + contentInset.bottom)
  }

  func scrollToMinContentOffset(animated: Bool) {
    setContentOffset(minContentOffset, animated: animated)
  }

  func scrollToMaxContentOffset(animated: Bool) {
    setContentOffset(maxContentOffset, animated: animated)
  }
}

extension UITextView {
    func adjustHeight() {
        translatesAutoresizingMaskIntoConstraints = true
        let fixedWidth = frame.size.width
        let newSize = sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: min(newSize.height, CGFloat(256)))
        frame = newFrame
    }
}


extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

func formatAudioDuration(seconds: Int) -> String {
    var seconds = seconds
    let hours = seconds / 3600
    seconds -= hours * 3600
    let minutes = seconds / 60
    seconds -= minutes * 60
    
    if hours > 0 {
        let m = NSString(format:"%.2d", minutes)
        let s = NSString(format: "%.2d", seconds)
        return "\(hours):\(m):\(s)"
    } else {
        let s = NSString(format: "%.2d", seconds)
        return "\(minutes):\(s)"
    }
}

func formatAudioDuration(millis: Int64) -> String {
    var seconds = millis / 1000
    let hours = seconds / 3600
    seconds -= hours * 3600
    let minutes = seconds / 60
    seconds -= minutes * 60
    
    if hours > 0 {
        let m = NSString(format:"%.2d", minutes)
        let s = NSString(format: "%.2d", seconds)
        return "\(hours):\(m):\(s)"
    } else {
        let s = NSString(format: "%.2d", seconds)
        return "\(minutes):\(s)"
    }
}
