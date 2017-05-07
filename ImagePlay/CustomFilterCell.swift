//
//  CustomFilterCell.swift
//  ImagePlay
//
//  Created by Thomas Hirth on 2016-03-31.
//  Copyright © 2016 robbo. All rights reserved.
//

import UIKit

class CustomFilterCell: UITableViewCell {
    @IBOutlet var customLabel: UILabel!

    @IBOutlet var editButton: UIButton!

    @IBOutlet var previewImage: UIImageView!
    
    func updateForFilter(_ filter:Filter, tag: Int) {
        self.customLabel.text = filter.name
        self.showsReorderControl = true
        if ( filter is LinearAdjustableFilter ) {
            self.editButton.isHidden = false
        } else {
            self.editButton.isHidden = true
        }
        self.editButton.tag = tag
    }

}
