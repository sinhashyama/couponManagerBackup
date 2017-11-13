//
//  ViewController.swift
//  CouponManage
//
//  Created by Singh, Abhay on 7/5/17.
//  Copyright © 2017 SHC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var barNavigation: UINavigationItem!
    @IBOutlet weak var addbutton: UIButton!
    
    @IBOutlet weak var searchButtonIcon: UIBarButtonItem!
    
    @IBOutlet weak var menuButtonIcon: UIBarButtonItem!
    
    
    var gradientLayer: CAGradientLayer!
    var searchController:UISearchController!
    var searchtext = ""
    
    var desscription = ["OFF ANY ONE REGULAR PRICE ITEM", "Off on your entire purchase of $75 or more", "Off with a $70 minimum purchase"]
    var valueDiscount = ["10%", "$15", "$10"]
    var filteredArray:[String] = []
    var countNumber = 0
    var shouldShowSearchResults = false
    var searchResult = 0
    let searchBar = UISearchBar()
    
    let padding:CGFloat = 10.0
    let numberOfColumn:CGFloat = 2.0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        countNumber = desscription.count
        self.collectionView?.register(UINib(nibName: "CouponCell", bundle: nil), forCellWithReuseIdentifier: "pinInrestCell")
        
    }
    
    func createSearchBar(){
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Enter your search here"
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        let topColor = UIColor(red: 15/255, green: 118/255, blue: 128/255, alpha: 1)
        let bottomColor = UIColor(red: 84/255, green: 187/255, blue: 187/255, alpha: 1)
        let gradientColor = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocation = [0.0, 0.1]
        gradientLayer.colors = gradientColor
        gradientLayer.locations = gradientLocation as [NSNumber]?
        self.view.layer.addSublayer(gradientLayer)
    }


    @IBAction func addButtonAction(_ sender: Any) {
    }
    
    @IBAction func searchAction(_ sender: Any) {
        createSearchBar()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.text = searchtext
    }
    
    @IBAction func menuAction(_ sender: Any) {
    }


}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return filteredArray.count
        }
        else {
            return countNumber
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //do nothing so far
        let cell = collectionView.cellForItem(at: indexPath) as! CouponCell
        UIView.transition(with: cell.contentView, duration: 0.5, options: .transitionFlipFromRight, animations: {
            if !(cell.showingBack) {
                cell.showingBack = true
                cell.cardView.isHidden = true
                cell.offerView.isHidden = false
            } else {
                cell.showingBack = false
                cell.cardView.isHidden = false
                cell.offerView.isHidden = true
            }
        }, completion: nil)
    }
    
    //We use this method to deques the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pinInrestCell", for: indexPath) as! CouponCell
        cell.awakeFromNib()
        cell.delegate = self
        return cell
    }
    
    //populate data for the cell
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let couponCell = cell as! CouponCell
        var headlineText:String?
        if shouldShowSearchResults {
            headlineText = filteredArray[indexPath.row].lowercased()
        } else {
            headlineText = desscription[indexPath.row].lowercased()
        }
        var discountValuetext = valueDiscount[indexPath.row]
        couponCell.headline.text = headlineText
        let firstFont = UIFont(name: "HelveticaNeue-Bold", size: 35)
        let secondFont = UIFont(name: "HelveticaNeue-Bold", size: 20)
        var desiredValue:NSAttributedString?
        if discountValuetext.contains("%") {
            desiredValue = utilities.superScript(discountValuetext, locationInt: discountValuetext.characters.count-1, length: 1, font1: firstFont!, font2: secondFont!)
        } else if discountValuetext.contains("$") {
            desiredValue = utilities.superScript(discountValuetext, locationInt: 0, length: 1, font1: firstFont!, font2: secondFont!)
        } else {
            desiredValue = utilities.superScript(discountValuetext, locationInt: 0, length: 0, font1: firstFont!, font2: secondFont!)
        }
        couponCell.discountValue.attributedText = desiredValue
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - (padding*2))/numberOfColumn, height: 160)
    }
}

extension ViewController: PinterestLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForPhotoAt indexPath: IndexPath, with width: CGFloat) -> CGFloat {
        return 42
    }
    
    func collectionView(collectionView: UICollectionView, heightForCaptionAt indexPath: IndexPath, with width: CGFloat) -> CGFloat {
        let text = desscription[indexPath.row]
        let font = UIFont(name: "HelveticaNeue-Bold", size: 17.0)
        let height = utilities.heightForView(text: text, font: font!, width: width)
        print(height)
        return 120
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchtext = searchBar.text!
        self.navigationItem.title = searchtext.uppercased()
        //do calculation to update result array
        self.collectionView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
}

extension ViewController: CouponCellDeleteDelegate {
    func deleteCell(cell: CouponCell) {
        if let indexPath = collectionView.indexPath(for: cell){
            desscription.remove(at: indexPath.row)
            valueDiscount.remove(at: indexPath.row)
            countNumber = countNumber - 1
            self.collectionView.deleteItems(at: [indexPath])
        }
    }
}
