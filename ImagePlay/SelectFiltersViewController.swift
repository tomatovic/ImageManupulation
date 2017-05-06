//
//  SelectFiltersViewController.swift
//  ImagePlay
//
//  Created by Robert Patterson on 2016-03-19.
//  Copyright © 2016 robbo. All rights reserved.
//

import UIKit

class SelectFiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var filtersModel: FiltersModel = FiltersModel()
    var originalThumbnail: UIImage = UIImage()
    var filteredThumbnailsCache: [Image] = []

    @IBOutlet var filtersTable: UITableView!
    @IBOutlet var noFilterView: UIView!
    
    @IBAction func onEdit(_ sender: AnyObject) {
        let button = sender as! UIButton
        let filter = filtersModel.filters[ button.tag ];
        let viewController = storyboard?.instantiateViewController(withIdentifier: "LinearAdjustableViewController") as! LinearAdjustmentViewController
        viewController.filter = filter as? LinearAdjustableFilter
        navigationController?.pushViewController(viewController, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        filtersTable.isEditing=true
        NotificationCenter.default.addObserver(self, selector: #selector(SelectFiltersViewController.filtersUpdated(_:)), name: NSNotification.Name(rawValue: "FiltersUpdated"), object: nil)
        filtersTable.backgroundView = noFilterView
        handleFiltersChanged()
    }
    
    @IBAction func onDeleteAll(_ sender: AnyObject) {
        
        let ac = UIAlertController(title: "Confirm", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Delete All", style: .default, handler: { (action) -> Void in
            self.filtersModel.filters = []
            self.handleFiltersChanged()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(ac, animated: true, completion: nil)
    }
    
    func handleFiltersChanged() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "FiltersChanged"), object: nil)
        filtersTable.reloadData()
        noFilterView.isHidden = (filtersModel.filters.count>0)
        filteredThumbnailsCache = []
    }
    
    func setOriginalImageForPreview( _ originalImage: UIImage ) {
        let imageShrinker = ImageResizer(maxDimension: 128)
        originalThumbnail = imageShrinker.resizeImage(originalImage)
    }
    
    func filtersUpdated(_ notification: Notification) {
        handleFiltersChanged()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtersModel.filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! CustomFilterCell
        let filter = filtersModel.filters[ indexPath.row ]
        cell.updateForFilter(filter, tag: indexPath.row)
        
        cell.previewImage.image = getFilteredImageForRow(indexPath.row).toUIImage()
        
        return cell
    }
    
    func getFilteredImageForRow( _ row: Int ) -> Image {
        if (row<0) {
            return Image(image: originalThumbnail) // Special case for first row.
        }
        if (row<filteredThumbnailsCache.count) {
            return filteredThumbnailsCache[row]
        } else {
            let filter = filtersModel.filters[row]
            let previousImage = getFilteredImageForRow( row-1 )
            let filteredImage = filter.apply(previousImage)
            filteredThumbnailsCache.append(filteredImage)
            return filteredImage
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if ( editingStyle==UITableViewCellEditingStyle.delete) {
            filtersModel.filters.remove(at: indexPath.row)
            handleFiltersChanged()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = filtersModel.filters[ sourceIndexPath.row ]
        filtersModel.filters.remove(at: sourceIndexPath.row)
        filtersModel.filters.insert(item, at: destinationIndexPath.row  )
        handleFiltersChanged()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddFilterViewController {
            vc.filtersModel = self.filtersModel
        }
    }
}
