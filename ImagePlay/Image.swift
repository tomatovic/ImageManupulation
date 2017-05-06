//
//  Image.swift
//  ImagePlay
//
//  Created by Robert Patterson on 2016-03-17.
//  Copyright © 2016 robbo. All rights reserved.
//
import UIKit

open class Image {
    let pixels: UnsafeMutableBufferPointer<RGBAPixel>
    let height: Int;
    let width: Int;
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
    let bitsPerComponent = 8
    let bytesPerRow: Int

    public init( width: Int, height: Int ) {
        self.height = height
        self.width = width
        bytesPerRow = 4 * width
        let rawdata = UnsafeMutablePointer<RGBAPixel>.allocate(capacity: width * height)
        pixels = UnsafeMutableBufferPointer<RGBAPixel>(start: rawdata, count: width * height)
    }

    public init( image: UIImage ) {
        height = Int(image.size.height)
        width = Int(image.size.width)
        bytesPerRow = 4 * width
        
        let rawdata = UnsafeMutablePointer<RGBAPixel>.allocate(capacity: width * height)
        let imageContext = CGContext(data: rawdata, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        imageContext?.draw(image.cgImage!, in: CGRect(origin: CGPoint.zero, size: image.size));
        
        pixels = UnsafeMutableBufferPointer<RGBAPixel>(start: rawdata, count: width * height)
    }
    
    open func getPixel( _ x: Int, y: Int ) -> RGBAPixel {
        return pixels[x+y*width];
    }

    open func setPixel( _ value: RGBAPixel, x: Int, y: Int )  {
        pixels[x+y*width] = value;
    }
    
    
    open func toUIImage() -> UIImage {
        let outContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)
        return UIImage(cgImage: outContext!.makeImage()!)
    }
    
    open func transformPixels( _ tranformFunc: (RGBAPixel)->RGBAPixel ) -> Image {
        let newImage = Image(width: self.width, height: self.height)
        for y in 0 ..< height {
            for x in 0 ..< width {
                let p1 = getPixel(x, y: y)
                let p2 = tranformFunc(p1)
                newImage.setPixel(p2, x: x, y: y)
            }
        }
        return newImage
    }
}
