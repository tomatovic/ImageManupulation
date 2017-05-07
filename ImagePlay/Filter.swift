//
//  Filter.swift
//  ImagePlay
//
//  Created by Thomas Hirth on 2016-03-17.
//  Copyright © 2016 robbo. All rights reserved.
//

import Foundation

protocol Filter {
    var name: String { get }
    func apply( _ input: Image ) -> Image
}

protocol LinearAdjustableFilter: Filter {
    var value: Double { get set }
    var min: Double { get }
    var max: Double { get }
    var defaultValue: Double { get }
}
