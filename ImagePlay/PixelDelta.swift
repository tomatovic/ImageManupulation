//
//  PixelDelta.swift
//  ImagePlay
//
//  Created by Robert Patterson on 2016-03-25.
//  Copyright © 2016 robbo. All rights reserved.
//

import Foundation

public struct PixelDelta {
    init( rDelta: Int, gDelta: Int, bDelta: Int ) {
        self.rDelta = rDelta
        self.gDelta = gDelta
        self.bDelta = bDelta
    }
    func add( _ p: RGBAPixel ) -> PixelDelta {
        return PixelDelta( rDelta: self.rDelta+Int(p.red), gDelta: self.gDelta+Int(p.green), bDelta: self.bDelta+Int(p.blue) )
    }
    func subtract( _ p: RGBAPixel ) -> PixelDelta {
        return PixelDelta( rDelta: self.rDelta-Int(p.red), gDelta: self.gDelta-Int(p.green), bDelta: self.bDelta-Int(p.blue) )
    }
    func asPixel() -> RGBAPixel {
        return RGBAPixel(
            r: limitToLegalColorChannelRange(rDelta),
            g: limitToLegalColorChannelRange(gDelta),
            b: limitToLegalColorChannelRange(bDelta))
        
    }
    func limitToLegalColorChannelRange( _ delta: Int ) -> UInt8 {
        if (delta<0) {
            return 0
        } else if (delta>0xFF) {
            return 0xFF
        } else {
            return UInt8(delta)
        }
    }
    
    let rDelta: Int
    let gDelta: Int
    let bDelta: Int
}
