//
//  Filters.swift
//  ImagePlay
//
//  Created by Thomas Hirth on 2016-03-17.
//  Copyright © 2016 robbo. All rights reserved.
//

import Foundation
import UIKit

let allFilters: [Filter] = [
    MirrorFilter(),
    MirrorTopBottomFilter(),
    ScaleIntensityFilter(),
    MixFilter(),
    HueFilter(),
    SaturationFilter(),
    BrightnessFilter(),
    GreyScaleFilter(),
    InvertFilter(),
    Colors8Filter(),
    Dither8Filter(),
    Colors16Filter(),
    Dither16Filter(),
]

let palette8: [RGBAPixel] = [
    RGBAPixel(r:0,g:0,b:0),
    RGBAPixel(r:0xFF,g:0xFF,b:0xFF),
    RGBAPixel(r:0xFF,g:0x0,b:0x0),
    RGBAPixel(r:0x0,g:0xFF,b:0x0),
    RGBAPixel(r:0x0,g:0x0,b:0xFF),
    RGBAPixel(r:0xFF,g:0xFF,b:0x0),
    RGBAPixel(r:0xFF,g:0x0,b:0xFF),
    RGBAPixel(r:0x0,g:0x0,b:0xFF),
];

let palette16: [RGBAPixel] = [
    RGBAPixel(r:0,g:0,b:0),
    RGBAPixel(r:0xFF,g:0xFF,b:0xFF),
    RGBAPixel(r:0xFF,g:0x0,b:0x0),
    RGBAPixel(r:0x0,g:0xFF,b:0x0),
    RGBAPixel(r:0x0,g:0x0,b:0xFF),
    RGBAPixel(r:0xFF,g:0xFF,b:0x0),
    RGBAPixel(r:0xFF,g:0x0,b:0xFF),
    RGBAPixel(r:0x0,g:0x0,b:0xFF),
    RGBAPixel(r:0x3F,g:0x3F,b:0x3F),
    RGBAPixel(r:0x7F,g:0x7F,b:0x7F),
    RGBAPixel(r:0x7F,g:0x0,b:0x0),
    RGBAPixel(r:0x0,g:0x7F,b:0x0),
    RGBAPixel(r:0x0,g:0x0,b:0x7F),
    RGBAPixel(r:0x7F,g:0x7F,b:0x0),
    RGBAPixel(r:0x7F,g:0x0,b:0x7F),
    RGBAPixel(r:0x0,g:0x0,b:0x7F),
];

class Colors8Filter : Filter {
    let name: String = "8 Colors Only"
    func apply(_ input: Image) -> Image {
        return input.transformPixels({ (p:RGBAPixel) -> RGBAPixel in
            return p.findClosestMatch(palette8)
        })
    }
}

class Colors16Filter : Filter {
    let name: String = "16 Colors Only"
    func apply(_ input: Image) -> Image {
        return input.transformPixels({ (p:RGBAPixel) -> RGBAPixel in
            return p.findClosestMatch(palette16)
        })
    }
}

class MirrorFilter : Filter {
    let name: String = "Mirror (right-left)"
    func apply(_ input: Image) -> Image {
        let newImage = Image(width: input.width, height: input.height)
        for y in 0 ..< input.height {
            for x in 0 ..< input.width {
                let p = input.getPixel(input.width-x-1, y: y)
                newImage.setPixel(p, x: x, y: y)
            }
        }
        return newImage
    }
}


class MirrorTopBottomFilter : Filter {
    let name: String = "Mirror (top-bottom)"
    func apply(_ input: Image) -> Image {
        let newImage = Image(width: input.width, height: input.height)
        for y in 0 ..< input.height {
            for x in 0 ..< input.width {
                let p = input.getPixel(x, y: input.height-y-1)
                newImage.setPixel(p, x: x, y: y)
            }
        }
        return newImage
    }
}

class Dither8Filter : Filter {
    let name: String = "Dither 8 Colors"
    func apply(_ input: Image) -> Image {
        var delta = PixelDelta(rDelta: 0, gDelta: 0, bDelta: 0)
        return input.transformPixels({ (requestedPixel:RGBAPixel) -> RGBAPixel in
            delta = delta.add(requestedPixel)
            let newPixel = delta.asPixel().findClosestMatch(palette8)
            delta = delta.subtract(newPixel)
            return newPixel
        })
    }
}

class Dither16Filter : Filter {
    let name: String = "Dither 16 Colors"
    func apply(_ input: Image) -> Image {
        var delta = PixelDelta(rDelta: 0, gDelta: 0, bDelta: 0)
        return input.transformPixels({ (requestedPixel:RGBAPixel) -> RGBAPixel in
            delta = delta.add(requestedPixel)
            let newPixel = delta.asPixel().findClosestMatch(palette16)
            delta = delta.subtract(newPixel)
            return newPixel
        })
    }
}

class ScaleIntensityFilter : Filter, LinearAdjustableFilter {
    let name: String = "Scale Intensity"
    var value: Double
    let min: Double = 0.0
    let max: Double = 1.0
    let defaultValue: Double = 0.75
    init() {
        self.value  = self.defaultValue
    }
    func apply(_ input: Image) -> Image {
        return input.transformPixels({ (p1:RGBAPixel) -> RGBAPixel in
            var p = p1
            p.red = UInt8( Double(p.red) * self.value )
            p.green = UInt8( Double(p.green) * self.value )
            p.blue = UInt8( Double(p.blue) * self.value )
            return p
        })
    }
}

class HueFilter : Filter, LinearAdjustableFilter {
    let name: String = "Hue"
    var value: Double
    let min: Double = 0.0
    let max: Double = 1.0
    let defaultValue: Double = 0.75
    init() {
        self.value  = self.defaultValue
    }
    func apply(_ input: Image) -> Image {
        return input.transformPixels({ (p:RGBAPixel) -> RGBAPixel in
            
            let uiColor =  p.toUIColor()
            var hls = HLSPixel()

            uiColor.getHue(&hls.h, saturation: &hls.s, brightness: &hls.l, alpha: &hls.a)
            let newUiColor = UIColor(hue: CGFloat(self.value), saturation: hls.s, brightness: hls.l, alpha: hls.a)
            
            return RGBAPixel(uiColor: newUiColor)
        })
    }
}

class SaturationFilter : Filter, LinearAdjustableFilter {
    let name: String = "Saturation"
    var value: Double
    let min: Double = 0.0
    let max: Double = 1.0
    let defaultValue: Double = 0.75
    //4.0 und 1.5 laufen auf Fehler
    
    init() {
        self.value  = self.defaultValue
    }
    func apply(_ input: Image) -> Image {
        return input.transformPixels({ (p:RGBAPixel) -> RGBAPixel in
            
            let uiColor =  p.toUIColor()
            var hls = HLSPixel()
            
            uiColor.getHue(&hls.h, saturation: &hls.s, brightness: &hls.l, alpha: &hls.a)
            let newUiColor = UIColor(hue: hls.h, saturation: CGFloat(hls.s) * CGFloat(self.value), brightness: hls.l, alpha: hls.a)
            
            return RGBAPixel(uiColor: newUiColor)
        })
    }
}

class BrightnessFilter : Filter, LinearAdjustableFilter {
    let name: String = "Brightness"
    var value: Double
    let min: Double = 0.0
    let max: Double = 1.0
    let defaultValue: Double = 0.75
    // 4.0 und 1.5 laufen auf Fehler
    
    init() {
        self.value  = self.defaultValue
    }
    func apply(_ input: Image) -> Image {
        return input.transformPixels({ (p:RGBAPixel) -> RGBAPixel in
            
            let uiColor =  p.toUIColor()
            var hls = HLSPixel()
            
            uiColor.getHue(&hls.h, saturation: &hls.s, brightness: &hls.l, alpha: &hls.a)
            let newUiColor = UIColor(hue: hls.h, saturation: hls.s, brightness: CGFloat(hls.l) * CGFloat(self.value), alpha: hls.a)
            
            return RGBAPixel(uiColor: newUiColor)
        })
    }
}


class MixFilter : Filter {
    let name: String = "Mix Filter"
    func apply(_ input: Image) -> Image {
        return input.transformPixels({ (p1:RGBAPixel) -> RGBAPixel in
            var p = p1
            let r = p.red
            p.red = p.blue
            p.blue = p.green
            p.green = r
            return p
        })
    }
}


class GreyScaleFilter : Filter {
    let name: String = "Grey Scale Filter"
    func apply(_ input: Image) -> Image {
        return input.transformPixels({ (p:RGBAPixel) -> RGBAPixel in
            let i = p.averageIntensity
            return RGBAPixel(r:i,g:i,b:i)
        })
    }
}



class InvertFilter : Filter {
    let name: String = "Invert Filter"
    func apply(_ input: Image) -> Image {
        return input.transformPixels({ (p:RGBAPixel) -> RGBAPixel in
            
            return RGBAPixel(r:(0xFF-p.red),g:(0xFF-p.green),b:(0xFF-p.blue))
        })
    }
}


