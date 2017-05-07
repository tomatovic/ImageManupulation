//
//  ViewController.swift
//  ImagePlay
//
//  Created by Thomas Hirth on 2016-03-13.
//  Copyright © 2016 robbo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate   {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var containView: UIView!
    @IBOutlet var transitionImageView: UIImageView!
    @IBOutlet var swapImageButton: UIBarButtonItem!
    @IBOutlet var busySpinner: UIActivityIndicatorView!
    @IBOutlet var imageView: UIImageView!
    var originalImage = UIImage(named: "becklehead.jpg")!
    var selectedFilters : FiltersModel = FiltersModel()
    var isFilteredShowing = false;
    let imageShrinker = ImageResizer(maxDimension: 1024)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.filtersChanged(_:)), name: NSNotification.Name(rawValue: "FiltersChanged"), object: nil)
        
        showOriginalImage()
    }
    
    func updateImage( _ image: UIImage ) {
        self.transitionImageView.alpha = 0
        self.transitionImageView.image = image;
        UIView.animate(
            withDuration: 0.7,
            animations: { () -> Void in
                self.transitionImageView.alpha = 1
            },
            completion: { (finished) -> Void in
                self.imageView.image = image
                self.transitionImageView.alpha = 0
            }
        );
    }
    
    @IBAction func onShare(_ sender: AnyObject) {
        let vc = UIActivityViewController(activityItems: [self.imageView.image!], applicationActivities: nil)
        self.present(vc, animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return containView
    }
    
    @IBAction func onCameraClick(_ sender: AnyObject) {
        let ac = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) -> Void in
            self.showPicker(.camera)
        }))
        ac.addAction(UIAlertAction(title: "Album", style: .default, handler: { (action) -> Void in
            self.showPicker(.photoLibrary)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(ac, animated: true, completion: nil)
    }
    
    func showPicker(_ sourceType:UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        self.present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismiss(animated: true, completion: nil)
        self.setOriginal( image )
        showOriginalImage()
    }
    
    func setOriginal(  _ image: UIImage ) {
        
        self.originalImage = imageShrinker.resizeImage(image)
        
    }
    
    func showOriginalImage() {
        updateImage( originalImage )
        swapImageButton.title = (selectedFilters.filters.count>0) ? ">Filtered" : ""
        self.navigationItem.title = "Original"
        isFilteredShowing = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if ( filtersHaveChanged ) {
            applyFilterAndShow()
            filtersHaveChanged = false
        }
        
    }
    
    @IBAction func swapImage(_ sender: AnyObject) {
        if(isFilteredShowing) {
            showOriginalImage()
        } else {
            applyFilterAndShow()
        }
    }
    
    var filtersHaveChanged = false
    func filtersChanged(_ notificaton: Notification) {
        filtersHaveChanged = true
    }
    
    func applyFilterAndShow() {
        
        busySpinner.startAnimating()
        
        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        backgroundQueue.async { () -> Void in
            var image = Image(image: self.originalImage)
            
            for filter in self.selectedFilters.filters {
                image = filter.apply(image)
            }
            DispatchQueue.main.async(execute: { () -> Void in
                self.busySpinner.stopAnimating()
                self.updateImage( image.toUIImage() )
                self.swapImageButton.title = ">Original"
                self.navigationItem.title = "Filtered"
                self.isFilteredShowing = true
            })
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectFiltersViewController = segue.destination as? SelectFiltersViewController {
            selectFiltersViewController.filtersModel = selectedFilters
            selectFiltersViewController.setOriginalImageForPreview(originalImage)
        }
    }


}

