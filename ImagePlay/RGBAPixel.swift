//
//  RGBAPixel.swift
//  ImagePlay
//
//  Created by Thomas Hirth on 2016-03-17.
//  Copyright © 2016 robbo. All rights reserved.
//

import UIKit

public struct RGBAPixel {
    public init( rawVal : UInt32  ) {
        raw = rawVal
    }
    public init( r: UInt8, g:UInt8, b:UInt8) {
        raw = 0xFF000000 | UInt32(r) | UInt32(g)<<8 | UInt32(b)<<16
    }
    public init( uiColor: UIColor ) {
        var r: CGFloat = 0.0;
        var g: CGFloat = 0.0;
        var b: CGFloat = 0.0;
        var alpha: CGFloat = 0.0;
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &alpha)
        
        self.init(r: UInt8(r*255), g: UInt8(g*255), b: UInt8(b*255))
    }
    
    public var raw: UInt32
    public var red: UInt8 {
        get { return UInt8(raw & 0xFF) }
        set { raw = UInt32(newValue) | (raw & 0xFFFFFF00) }
    }
    public var green: UInt8 {
        get { return UInt8( (raw & 0xFF00) >> 8 ) }
        set { raw = (UInt32(newValue) << 8) | (raw & 0xFFFF00FF) }
    }
    public var blue: UInt8 {
        get { return UInt8( (raw & 0xFF0000) >> 16 ) }
        set { raw = (UInt32(newValue) << 16) | (raw & 0xFF00FFFF) }
    }
    public var alpha: UInt8 {
        get { return UInt8( (raw & 0xFF000000) >> 24 ) }
        set { raw = (UInt32(newValue) << 24) | (raw & 0x00FFFFFF) }
    }
    public var averageIntensity: UInt8 {
        get { return UInt8 ( (UInt32(red)+UInt32(green)+UInt32(blue))/3 ) }
    }
    public func findClosestMatch( _ palette: [RGBAPixel] ) -> RGBAPixel {
        var closestMatch: RGBAPixel = palette[0];
        var bestMatchSoFar: Int = palette[0].pixelDelta(self)
        for pixel in palette {
            let delta: Int = pixel.pixelDelta(self)
            if ( delta < bestMatchSoFar ) {
                closestMatch = pixel
                bestMatchSoFar = delta
            }
        }
        return closestMatch

    }
    public func pixelDelta( _ otherPixel: RGBAPixel ) -> Int {
        let rDelta = abs( Int(self.red) - Int(otherPixel.red) )
        let gDelta = abs( Int(self.green) - Int(otherPixel.green) )
        let bDelta = abs( Int(self.blue) - Int(otherPixel.blue) )
        return rDelta + gDelta + bDelta
    }
    public func toUIColor() -> UIColor {
        return UIColor(red: CGFloat(self.red)/CGFloat(255),
                       green: CGFloat(self.green)/CGFloat(255),
                       blue: CGFloat(self.blue)/CGFloat(255),
                       alpha: CGFloat(self.alpha)/CGFloat(255))
    }
    
    
}

