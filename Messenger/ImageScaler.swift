//
//  ImageScaler.swift
//  Messenger
//
//  Created by Александр Шерий on 09.07.2023.
//

import UIKit

extension CGSize {
  enum Aspect {
    case portrait, landscape, square
  }
  var aspect: Aspect {
    switch width / height {
    case 1.0:
      return .square
        case 1.0...:
      return .landscape
    default:
      return .portrait
    }
  }
  var aspectRatio: CGFloat {
    return width / height
  }
}

extension CGRect {
  func scaled(toFillSize targetSize: CGSize) -> CGRect {
    var scaledRect = self
    switch (size.aspect, targetSize.aspect) {
        case (.portrait, .portrait), (.portrait, .square):
            scaledRect.size.height = width / targetSize.aspectRatio
            scaledRect.size.width = width
            if scaledRect.height > height {
              scaledRect.size = size
            }
            scaledRect.origin.y -= (scaledRect.height - height) / 2
        
        case (.portrait, .landscape), (.square, .landscape):
            scaledRect.size.height = width / targetSize.aspectRatio
            scaledRect.size.width = width
            if scaledRect.height > height {
              scaledRect.size = size
            }
            scaledRect.origin.y -= (scaledRect.height - height) / 2
        
        case (.landscape, .portrait), (.square, .portrait):
            scaledRect.size.height = height
            scaledRect.size.width = height * targetSize.aspectRatio
            if scaledRect.width > width {
              scaledRect.size = size
            }
            scaledRect.origin.x -= (scaledRect.width - width) / 2
        
        case (.landscape, .landscape), (.landscape, .square):
            scaledRect.size.height = height
            scaledRect.size.width = height * targetSize.aspectRatio
            if scaledRect.size.width > width {
              scaledRect.size = size
            }
            scaledRect.origin.x -= (scaledRect.width - width) / 2
        
        case (.square, .square):
            return self
    }
    return scaledRect.integral
  }
}

struct ImageScaler {
  static func scaleToFill(_ image: UIImage, in targetSize: CGSize, from fromRect: CGRect = .zero) -> UIImage {
    let rect = fromRect.isEmpty ? CGRect(origin: .zero, size: image.size) : fromRect
    let scaledRect = rect.scaled(toFillSize: targetSize)
    return scale(image, fromRect: scaledRect, targetSize: targetSize)
  }
    
  private static func scale(_ image: UIImage, fromRect: CGRect = .zero, targetSize: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    return renderer.image { context in
      // UIImage and CGContext coordinates are flipped.
      var transform = CGAffineTransform(translationX: 0.0, y: targetSize.height)
      transform = transform.scaledBy(x: 1, y: -1)
      context.cgContext.concatenate(transform)
      // UIImage -> cropped CGImage
      let makeCroppedCGImage: (UIImage) -> CGImage? = { image in
        guard let cgImage = image.cgImage else { return nil }
        guard !fromRect.isEmpty else { return cgImage }
        return cgImage.cropping(to: fromRect)
      }
      if let cgImage = makeCroppedCGImage(image) {
        context.cgContext.draw(cgImage, in: CGRect(origin: .zero, size: targetSize))
      }
      else if let ciImage = image.ciImage {
        var transform = CGAffineTransform(translationX: 0.0, y: image.size.height)
        transform = transform.scaledBy(x: 1, y: -1)
        let adjustedFromRect = fromRect.applying(transform)
        let ciContext = CIContext(cgContext: context.cgContext, options: nil)
        ciContext.draw(ciImage, in: CGRect(origin: .zero, size: targetSize), from: adjustedFromRect)
      }
    }
  }
}
