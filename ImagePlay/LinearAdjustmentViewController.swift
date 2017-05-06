//
//  LinearAdjustmentViewController.swift
//  ImagePlay
//
//  Created by Robert Patterson on 2016-04-03.
//  Copyright © 2016 robbo. All rights reserved.
//

import UIKit

class LinearAdjustmentViewController: UIViewController {

    var filter: LinearAdjustableFilter?
    
    @IBOutlet var label: UILabel!
    @IBOutlet var slider: UISlider!
    @IBOutlet var previewImage: UIImageView!
    
    @IBAction func sliderChanged(_ sender: AnyObject) {
        filter?.value = Double(slider.value)
        applyFilterAndUpdatePreview()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "FiltersUpdated"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label?.text = filter?.name
        slider.minimumValue = Float((filter?.min)!)
        slider.maximumValue = Float((filter?.max)!)
        slider.value = Float((filter?.value)!)
        applyFilterAndUpdatePreview()
    }
    
    func applyFilterAndUpdatePreview() {
        let originalImage = Image( image: UIImage(named: "becklehead.jpg")! )
        let filteredImage = filter!.apply(originalImage)
        previewImage.image = filteredImage.toUIImage()
    }
}
