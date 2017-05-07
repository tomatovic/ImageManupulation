//
//  ImageResizer.swift
//  ImagePlay
//
//  Created by Thomas Hirth on 2016-03-25.
//  Copyright © 2016 robbo. All rights reserved.
//

import UIKit

class ImageResizer {
    let maxDimension: Int
    init ( maxDimension: Int ) {
        self.maxDimension = maxDimension
    }
    
    func isSmallEnough( _ w: Int, h: Int ) ->Bool {
        return w < maxDimension && h < maxDimension
    }
    
    func resizeImage(_ original:UIImage) -> UIImage {
        
        var w = Int(original.size.width)
        var h = Int(original.size.height)
        if ( isSmallEnough(w,h:h) ) {
            return original // Already small enought
        }
        
        while( !isSmallEnough(w,h:h) ) {
            w = w/2
            h = h/2
        }
        
        return scaleToNewSize( original, w:w, h:h )
    }

    fileprivate func scaleToNewSize( _ image: UIImage, w: Int, h: Int ) -> UIImage {
        let cgImage = image.cgImage
        let bitsPerComponent = cgImage?.bitsPerComponent
        let bytesPerRow = cgImage?.bytesPerRow
        let colorSpace = cgImage?.colorSpace
        let bitmapInfo = cgImage?.bitmapInfo
        let context = CGContext(data: nil, width: w, height: h, bitsPerComponent: bitsPerComponent!, bytesPerRow: bytesPerRow!, space: colorSpace!, bitmapInfo: (bitmapInfo?.rawValue)!)
        
        context!.interpolationQuality = CGInterpolationQuality.high
        context?.draw(cgImage!, in: CGRect(origin: CGPoint.zero, size: CGSize(width: CGFloat(w), height: CGFloat(h))))
        let scaledCGImage = context?.makeImage()!
        
        return UIImage(cgImage: scaledCGImage!)
    }
    
}
