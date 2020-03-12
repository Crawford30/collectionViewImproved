//
//  ViewController.swift
//  CollectionViewAlamofire
//
//  Created by JOEL CRAWFORD on 2/18/20.
//  Copyright © 2020 JOEL CRAWFORD. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage



class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
        
    enum myTabButtons: Int {
        
        case tabAllServices
        case tabFeatured
        case tabFavourites
        
    }
    
    //--------------------------------------------------------------------------------------------------------
    
    
    @IBOutlet weak var faketabbar:      UIButton!
    @IBOutlet weak var featuredButton:  UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    
    @IBOutlet weak var collectionView:           UICollectionView!
    @IBOutlet weak var horizontalcollectionView: UICollectionView!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var navBarTitle: UINavigationItem!
    
    
    //=======  ARRAYS  ===========================================================================================
    
    var categoriesArray:       [ Categories ] = []

    var allServicesArray:      [ Services ]  = [] //holding ID's of every section in any category
    var selectedServicesArray: [ Services ]  = []
    var favouritesArray:       [ Services ]  = []
    var featuredArray:         [ Services ]  = []
    
    var showSelectedServices:  Bool          = false // No categories selected yet
    
    
    
    
    //=========  TITLES  ========================================================================================
    let navTitle = ["All Services", "Featured Services", "Favourite Services"]
    
    var currentCategory: Int = 0 // Just making sure they are initialized
    var currentSection:  Int = 0
    
    //==========  API Links  =============================================================================
    
    let categoryLink = "https://api.ichuzz2work.com/api/services/categories"
    
    let servicesLink = "https://api.ichuzz2work.com/api/services"
    
    let featuredLink = "https://ichuzz2work.com/api/services/featured"

    //========================================================================================================
    
    let iPhone8PlusHeight: CGFloat = 736.0
    
    var tabButtonMode:     Int     = myTabButtons.tabAllServices.rawValue // Default mode
    
    var vertCVExpanded:    CGRect  = CGRect()
    var vertCVCompressed:  CGRect  = CGRect()
    
    var showAllServices:   Bool    = true
    
    let docsDir: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    //==============  Constants for collectionView's  =====================================
    
    let horizontalCVCellSize:     CGSize  = CGSize( width:  88, height:  90 )
    let myCellSize:               CGSize  = CGSize( width: 150, height: 150 ) // Vertical CV cell size
    
    let myVertCVSpacing:          CGFloat = CGFloat(  8.0 )
    let myHorizCVSpacing:         CGFloat = CGFloat(  4.0 )
    
    let buttonFontSize:           CGFloat = CGFloat( 15.0 )
    let buttonEmphasizedFontSize: CGFloat = CGFloat( 18.0 )
    
    let myCornerRadius:           CGFloat = CGFloat(  6.0 )
    
    
//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        prepUI()
        
        createDir(dir: "Categories" )   // Create necessary image directories,
                                        // does nothing if they already exist
        createDir(dir: "AllServices" )

        //-----------------------------------------------------------------------------------------------------
        
        LoadCategories()    // Only done once
        
        LoadServices()
        
        LoadFeatured()
        
        enableDisableFavouritesButton()
        
        //-----------------------------------------------------------------------------------------------------
        
        horizontalcollectionView.delegate   = self
        horizontalcollectionView.dataSource = self
        
        collectionView.delegate             = self
        collectionView.dataSource           = self
                
    }
    
//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
    
    @IBAction func vCVFaveButtonTapped(_ sender: UIButton) {
        
        let whichService: Int    = sender.tag
        
        var isInFavourites: Bool = false    // Assume not already in Favourites
        
        switch tabButtonMode {
            
            case myTabButtons.tabAllServices.rawValue:
            
                if showSelectedServices {

                    isInFavourites = isFavourite(theID: selectedServicesArray[ whichService ] )

                } else {
                
                    isInFavourites = isFavourite(theID: allServicesArray[ whichService ] )

                }
                
                break
                
            case myTabButtons.tabFeatured.rawValue:
                
                isInFavourites = isFavourite(theID: featuredArray[ whichService ] )

                break
            
            case myTabButtons.tabFavourites.rawValue:
            
                isInFavourites = isFavourite(theID: favouritesArray[ whichService ] )

                break
            
            default:
            
                break
            
        }
        
        
        if isInFavourites {
            
            switch tabButtonMode {
                
                case myTabButtons.tabAllServices.rawValue:
                
                    if showSelectedServices {
                        
                        removeFavourite( theID: selectedServicesArray[ whichService ] )

                    } else {

                        removeFavourite( theID: allServicesArray[ whichService ] )

                    }

                    break
                    
                case myTabButtons.tabFeatured.rawValue:
                    
                    removeFavourite( theID: featuredArray[ whichService ] )

                    break
                
                case myTabButtons.tabFavourites.rawValue:
                
                    removeFavourite( theID: favouritesArray[ whichService ] )

                    break
                
                default:
                
                    break
                
            }
            
        } else {
            
            switch tabButtonMode {
                
                case myTabButtons.tabAllServices.rawValue:
                
                    if showSelectedServices {

                        favouritesArray.append( selectedServicesArray[ whichService ] )

                    } else {

                        favouritesArray.append( allServicesArray[ whichService ] )

                    }

                    break
                    
                case myTabButtons.tabFeatured.rawValue:
                    
                    favouritesArray.append( featuredArray[ whichService ] )

                    break
                
                case myTabButtons.tabFavourites.rawValue:
                
                    // In this case, the service is already in Favourites... cannot be added again
                    // Favourites can only be added from All Services and Featured Services
                    
                    break
                
                default:
                
                    break
                
            }
                                    
        }
        
        if favouritesArray.count > 1 {  // Only sort if more than one item in Favourites
            
            self.favouritesArray.sort {
                
                $0.title.lowercased() < $1.title.lowercased()
                
            }

        }

        enableDisableFavouritesButton()
        
        collectionView.reloadData()
        
        saveFavorites()
        
    }
    
    
    
    
//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var returnValue: Int
        
        //=======for horizonatl collection view=====
        if (collectionView == horizontalcollectionView) {
            
            returnValue = categoriesArray.count
            
        } else {
            
            switch tabButtonMode {

                case myTabButtons.tabAllServices.rawValue:
                    
                    if showSelectedServices {

                        returnValue = selectedServicesArray.count

                    } else {

                        returnValue = allServicesArray.count

                    }
                    

                    break
                    
                case myTabButtons.tabFeatured.rawValue:
                    
                    returnValue = featuredArray.count

                    break
                    
                case myTabButtons.tabFavourites.rawValue:
                    
                    returnValue = favouritesArray.count

                    break

                default:

                    returnValue = allServicesArray.count
            
            }
            
        }

        return returnValue

    }
    
    //🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if ( collectionView != horizontalcollectionView ) {
            
            return
            
        }
        
        if categoriesArray[ indexPath.item ].categoryID == currentCategory   {
            
            return
            
        }
        
        currentCategory = categoriesArray[ indexPath.item ].categoryID  // Translate to real Category ID
        
        self.navBar.topItem!.title = categoriesArray[ indexPath.item ].categoryTitle
        
        //=========want to get category id=====
        //
        //  https://api.ichuzz2work.com/api/services/category
        //  https://api.ichuzz2work.com/api/services
        
        let servicesAtCatID = "https://api.ichuzz2work.com/api/services/category/\(String(currentCategory))"
        
        fetchSericesFromCategory( servicesAtCatID )
        
        showSelectedServices = true // Switch to showing selected services instead of all services
        
    }

//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    func fetchSericesFromCategory(_ theURL: String ) {
        
        Alamofire.request( theURL ).responseJSON { (response) in
            
            guard response.result.isSuccess else {
                print("Error with response: \(String(describing: response.result.error))")
                return
            }
            
            guard let dictService = response.result.value as? Dictionary <String,AnyObject> else {
                print("Error with dictionary: \(String(describing: response.result.error))")
                return
            }
            
            guard let dictServiceData = dictService["data"] as? [Dictionary <String,AnyObject>] else {
                print("Error with dictionary data: \(String(describing: response.result.error))")
                return
            }
            
            var tempID: Services
            
            self.selectedServicesArray = [] // Temporarily clear selectedServicesArray when loading new Sections

            for serviceData in dictServiceData {
                
                tempID = Services.init()
                                
                tempID.categoryID = self.currentCategory
                
                tempID.serviceID  = serviceData["id"]    as! Int
                tempID.image      = serviceData["image"] as! String
                tempID.title      = serviceData["name"]  as! String
                
                self.selectedServicesArray.append( tempID )
                
            }
            
            self.selectedServicesArray.sort {         // Sort selectedServicesArray based on serviceTitle
                
                $0.title.lowercased() < $1.title.lowercased()
                
            }

            self.collectionView.reloadData()
            
            self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true )
            
        }
        
    }
    
//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //===========for Horizontal collection view==============
        
        if ( collectionView == horizontalcollectionView ) {
            
            let horizontalcell = horizontalcollectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalCell", for: indexPath) as! horizontalCollectionViewCell
            
            horizontalcell.categoryLabel.text = self.categoriesArray[indexPath.item].categoryTitle
            
            let localID = categoriesArray[indexPath.item].categoryID
            
            if doesCategoryImageExist(categoryID: localID ) {
                
                horizontalcell.categoryImageView.image = loadCategoryImage(categoryID: localID )
                
            } else {
                
                let categoryImageURL = normalizeURL( self.categoriesArray[indexPath.item].categoryImage )
                    
                Alamofire.request("https://api.ichuzz2work.com/" + categoryImageURL ).responseImage { (response) in
                    
                    if let categoryImage = response.result.value {
                        
                        DispatchQueue.main.async {
                            
                            let scaledCategoryImage = self.resizeImage(theImage: categoryImage, theSize: self.horizontalCVCellSize )

                            horizontalcell.categoryImageView?.image = scaledCategoryImage
                                                            
                            self.saveCategoriesImage(categoryID: localID, image: scaledCategoryImage )
                            
                        }
                        
                    }
                    
                }
                
            }
            
            return horizontalcell
            
        }
        
        //================  for vertical / Services collection view  ===============================================
        
        var returnCell: CollectionViewCell
        
        switch tabButtonMode {

            case myTabButtons.tabAllServices.rawValue:
                
                if showSelectedServices {

                    returnCell = getSelectedServicesCell( indexPath: indexPath )

                } else {
                 
                    returnCell = getAllServicesCell(indexPath: indexPath )

                }
                
            //---------------------------------------------------------------------------------------------------
            
            case myTabButtons.tabFeatured.rawValue:
                
                returnCell = getFeaturedServicesCell(indexPath: indexPath )
                
            //---------------------------------------------------------------------------------------------------
                
            case myTabButtons.tabFavourites.rawValue:
                
                returnCell = getFavouriteServicesCell(indexPath: indexPath )
                
            //---------------------------------------------------------------------------------------------------
                
            default:
                
                returnCell = getAllServicesCell(indexPath: indexPath )
            
        }
        
        returnCell.backgroundColor = UIColor.clear
        
        return returnCell
        
    }

   
    
    
    //🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    func getAllServicesCell ( indexPath: IndexPath ) -> CollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        cell.servicelabel.text                      = self.allServicesArray[ indexPath.item ].title
        cell.servicelabel.layer.cornerRadius        = myCornerRadius
        cell.servicelabel.clipsToBounds             = true
        
        cell.bookNowButtonOutlet.layer.cornerRadius = myCornerRadius
        cell.bookNowButtonOutlet.clipsToBounds      = true
        cell.bookNowButtonOutlet.tag                = indexPath.item

        if isFavourite(theID: allServicesArray[ indexPath.item ] ) {
            
            cell.favouriteBtn.setImage(UIImage(named:"redHeart"), for: .normal)
            
        } else {
            
            cell.favouriteBtn.setImage(UIImage(named:"whiteHeart"), for: .normal)
            
        }
        
        cell.favouriteBtn.tag = indexPath.item
        cell.shareBtn.tag     = indexPath.item

        let catID  = allServicesArray[ indexPath.item ].categoryID
        let servID = allServicesArray[ indexPath.item ].serviceID
        
        if doesServiceImageExist(categoryID: catID, serviceID: servID) {
            
            cell.serviceimage.image = loadServiceImage(categoryID: catID, serviceID: servID )
            
        } else {
            
            let imageUrl = normalizeURL( self.allServicesArray[ indexPath.item ].image )
                
            Alamofire.request("https://api.ichuzz2work.com/" + imageUrl).responseImage { (response) in
                
                if let image = response.result.value  {
                    
                    DispatchQueue.main.async {
                        
                        //scale the size disregarding the aspect ratio
                        let scaledImage = self.resizeImage(theImage: image, theSize: self.myCellSize )
                        
                        cell.serviceimage?.image = scaledImage
                        
                        self.saveServiceImage(categoryID: catID, serviceID: servID, image: scaledImage )
                        
                    }
                    
                }
                
            }
            
        }

        return cell
        
    }
    
    
    
    
    func getSelectedServicesCell ( indexPath: IndexPath ) -> CollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        cell.servicelabel.text                      = self.selectedServicesArray[ indexPath.item ].title
        cell.servicelabel.layer.cornerRadius        = myCornerRadius
        cell.servicelabel.clipsToBounds             = true
        
        cell.bookNowButtonOutlet.layer.cornerRadius = myCornerRadius
        cell.bookNowButtonOutlet.clipsToBounds      = true
        cell.bookNowButtonOutlet.tag                = indexPath.item

        if isFavourite(theID: selectedServicesArray[ indexPath.item ] ) {
            
            cell.favouriteBtn.setImage(UIImage(named:"redHeart"), for: .normal)
            
        } else {
            
            cell.favouriteBtn.setImage(UIImage(named:"whiteHeart"), for: .normal)
            
        }
        
        cell.favouriteBtn.tag = indexPath.item
        cell.shareBtn.tag     = indexPath.item

        let catID  = selectedServicesArray[ indexPath.item ].categoryID
        let servID = selectedServicesArray[ indexPath.item ].serviceID
        
        if doesServiceImageExist(categoryID: catID, serviceID: servID) {
            
            cell.serviceimage.image = loadServiceImage(categoryID: catID, serviceID: servID )
            
        } else {
            
            let imageUrl = normalizeURL( self.selectedServicesArray[ indexPath.item ].image )
                
            Alamofire.request("https://api.ichuzz2work.com/" + imageUrl).responseImage { (response) in
                
                if let image = response.result.value  {
                    
                    DispatchQueue.main.async {
                        
                        //scale the size disregarding the aspect ratio
                        let scaledImage = self.resizeImage(theImage: image, theSize: self.myCellSize )
                        
                        cell.serviceimage?.image = scaledImage
                        
                        self.saveServiceImage(categoryID: catID, serviceID: servID, image: scaledImage )
                        
                    }
                    
                }
                
            }
            
        }

        return cell
        
    }

   
    
    
    
    //🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    func getFeaturedServicesCell ( indexPath: IndexPath ) -> CollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell

        cell.servicelabel.text                      = self.featuredArray[ indexPath.item ].title
        cell.servicelabel.layer.cornerRadius        = myCornerRadius
        cell.servicelabel.clipsToBounds             = true
        
        cell.bookNowButtonOutlet.layer.cornerRadius = myCornerRadius
        cell.bookNowButtonOutlet.clipsToBounds      = true
        cell.bookNowButtonOutlet.tag                = indexPath.item

        if isFavourite(theID: featuredArray[ indexPath.item ] ) {
            
            cell.favouriteBtn.setImage(UIImage(named:"redHeart"), for: .normal)
            
        } else {
            
            cell.favouriteBtn.setImage(UIImage(named:"whiteHeart"), for: .normal)
            
        }
        
        cell.favouriteBtn.tag = indexPath.item
        cell.shareBtn.tag     = indexPath.item
        
        let catID  = featuredArray[ indexPath.item ].categoryID
        let servID = featuredArray[ indexPath.item ].serviceID
        
        if doesServiceImageExist(categoryID: catID, serviceID: servID) {

            cell.serviceimage.image = loadServiceImage(categoryID: catID, serviceID: servID )
            
        } else {
            
            let imageUrl = normalizeURL( self.featuredArray[ indexPath.item ].image )
                
            Alamofire.request("https://api.ichuzz2work.com/" + imageUrl).responseImage { (response) in
                
                if let image = response.result.value  {
                    
                    DispatchQueue.main.async {
                        
                        //scale the size disregarding the aspect ratio
                        let scaledImage = self.resizeImage(theImage: image, theSize: self.myCellSize)
                        
                        cell.serviceimage?.image = scaledImage
                                                    
                        self.saveServiceImage(categoryID: catID, serviceID: servID, image: scaledImage )
                        
                    }
                    
                }
                
            }
            
        }

        return cell
        
    }

    //🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    func getFavouriteServicesCell ( indexPath: IndexPath ) -> CollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        cell.servicelabel.text                      = self.favouritesArray[ indexPath.item ].title
        cell.servicelabel.layer.cornerRadius        = myCornerRadius
        cell.servicelabel.clipsToBounds             = true
        
        cell.bookNowButtonOutlet.layer.cornerRadius = myCornerRadius
        cell.bookNowButtonOutlet.clipsToBounds      = true
        cell.bookNowButtonOutlet.tag                = indexPath.item

        cell.favouriteBtn.setImage(UIImage(named:"redHeart"), for: .normal)
        
        cell.favouriteBtn.tag = indexPath.item
        cell.shareBtn.tag     = indexPath.item
        
        let catID  = favouritesArray[ indexPath.item ].categoryID
        let servID = favouritesArray[ indexPath.item ].serviceID

        cell.serviceimage.image = loadServiceImage(categoryID: catID, serviceID: servID )
            
        return cell
        
    }

    //🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    func normalizeURL (_ theString:String ) -> String {
        
        return theString.replacingOccurrences(of: " ", with: "%20", options: .literal)
        
    }
    
    //🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if ( collectionView == horizontalcollectionView ) {
            
            return horizontalCVCellSize
            
        } else {
            
            return myCellSize
            
        }
        
    }
    
    //🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
    //🔷🔷🔷🔷🔷  Load services in the vertical scroll view  🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
    
    func LoadServices() {
        
        Alamofire.request( servicesLink, method: .get )
            
            .validate()
            
            .responseJSON { (response) in
                
                guard response.result.isSuccess else {
                    print("Error with response: \(String(describing: response.result.error))")
                    return
                }
                
                guard let dict = response.result.value as? Dictionary <String,AnyObject> else {
                    print("Error with dictionary: \(String(describing: response.result.error))")
                    return
                }
                
                guard let dictData = dict["data"] as? [Dictionary <String,AnyObject>] else {
                    print("Error with dictionary data: \(String(describing: response.result.error))")
                    return
                }
                
                var tempID: Services
                
                self.allServicesArray = [] // Temporarily clear allServicesArray when loading new Sections
                
                for serviceData in dictData {
                    
                    tempID = Services.init()
                    
                    
                    
                    tempID.categoryID = serviceData["category_id"] as! Int
                    tempID.serviceID  = serviceData["id"]          as! Int
                    tempID.desc       = serviceData["description"] as? String ?? ""
                    tempID.image      = serviceData["image"]       as! String
                    tempID.title      = serviceData["name"]        as! String
                    
                    self.allServicesArray.append( tempID )
                    
                }
                
                self.allServicesArray.sort {         // Sort allServicesArray based on serviceTitle
                    
                    $0.title.lowercased() < $1.title.lowercased()
                    
                }

                self.collectionView.reloadData()
                
                return
                
        }
        
    }
    
    //🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
    //🔷🔷🔷🔷🔷🔷  Load categories in the horizonalscroll view  🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
    
    func LoadCategories() {
        
        Alamofire.request(categoryLink, method: .get)
            
            .validate()
            
            .responseJSON { (response) in
                
                guard response.result.isSuccess else {
                    print("Error with response: \(String(describing: response.result.error))")
                    return
                }
                
                guard let dict = response.result.value as? Dictionary <String,AnyObject> else {
                    print("Error with dictionary: \(String(describing: response.result.error))")
                    return
                }
                
                guard let dictData = dict["data"] as? [Dictionary <String,AnyObject>] else {
                    print("Error with dictionary data: \(String(describing: response.result.error))")
                    return
                }
                
                var tempID: Categories
                
                for categoryData in dictData {
                    
                    tempID = Categories.init()
                    
                    tempID.categoryID    = categoryData["id"]    as! Int
                    tempID.categoryTitle = categoryData["name"]  as! String
                    tempID.categoryImage = categoryData["image"] as! String
                    
                    self.categoriesArray.append( tempID )
                                        
                }
                
                self.categoriesArray.sort {
                    
                    $0.categoryTitle.lowercased() < $1.categoryTitle.lowercased()
                    
                }
                
                self.horizontalcollectionView.reloadData()
                
                return
                
        }
        
    }
    
//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
//🔷🔷🔷🔷🔷🔷  Load Featured  🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    func LoadFeatured() {
        
        Alamofire.request(featuredLink, method: .get).validate().responseJSON { (response) in
            
            guard response.result.isSuccess else {
                print("Error with response: \(String(describing: response.result.error))")
                return
            }
            
            guard let featuredDict = response.result.value as? Dictionary <String,AnyObject> else {
                print("Error with dictionary: \(String(describing: response.result.error))")
                return
            }
            
            guard let dictData = featuredDict["data"] as? [Dictionary <String,AnyObject>] else {
                print("Error with dictionary data: \(String(describing: response.result.error))")
                return
            }
            
            var tempID: Services
            
            self.featuredArray = []  // making sure its empty
           
            for featuredData in dictData {
            
                tempID = Services.init()
                
                tempID.serviceID = featuredData["id"]    as! Int
                tempID.title     = featuredData["name"]  as! String
                tempID.image     = featuredData["image"] as! String

                self.featuredArray.append(tempID)
                                
            }
            
            self.featuredArray.sort {   // Sort featuredArray based on lowercase serviceTitle

                $0.title.lowercased() < $1.title.lowercased()

            }
            
        }
        
    }
    
//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    @IBAction func bookNowTapped(_ sender: UIButton) {
        
        print("Book Now \(String(sender.tag)) pressed!")
        
    }

//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
    
    func prepUI() {
        
        var tempNavBarRect: CGRect = navBar.frame
        
        if self.view.frame.size.height <= iPhone8PlusHeight {
            
            tempNavBarRect.origin.y = 20
            
            navBar.frame = tempNavBarRect
            
            
            var tabBarRect: CGRect = faketabbar.frame
            
            tabBarRect.size.width = self.view.frame.size.width / 3
            
            let newYOrigin = self.view.frame.size.height - tabBarRect.size.height
            
            tabBarRect.origin.y = newYOrigin
            faketabbar.frame    = tabBarRect
            
            tabBarRect.origin.x += tabBarRect.size.width
            tabBarRect.origin.y  = newYOrigin
            featuredButton.frame = tabBarRect
            
            tabBarRect.origin.x  += tabBarRect.size.width
            tabBarRect.origin.y   = newYOrigin
            favouriteButton.frame = tabBarRect
            
        }
        
        navBar.topItem!.title = "ichuzz2work Services"
        
        horizontalcollectionView.backgroundColor = UIColor(named: "myGreenTint")
        
        setTabBarButtonColors()
        
        var tempHCV: CGRect = horizontalcollectionView.frame
        
        tempHCV.origin.x    = 0
        tempHCV.origin.y    = faketabbar.frame.origin.y - ( horizontalcollectionView.frame.size.height + 8 )
        tempHCV.size.width  = self.view.frame.size.width //only one item in a row, but with spaces between them
        
        horizontalcollectionView.frame = tempHCV
        
        collectionView.backgroundColor = .clear
        
        var tempRect: CGRect = collectionView.frame
        tempRect.origin.y    = tempNavBarRect.origin.y + tempNavBarRect.size.height + 8 // 8 pixels below navBar
        tempRect.size.width  = ( myCellSize.width * 2 ) + ( myVertCVSpacing * 3 )
        tempRect.size.height = ( horizontalcollectionView.frame.origin.y - tempRect.origin.y ) - 8
        tempRect.origin.x    = CGFloat( roundf( Float( ( self.view.frame.size.width - tempRect.size.width ) / 2.0) ) ) //centers the collection view horizonatlly
        
        collectionView.frame = tempRect
        
        vertCVCompressed = tempRect // Calculate expanded and compressed frames once
        
        tempRect.size.height = ( horizontalcollectionView.frame.size.height + horizontalcollectionView.frame.origin.y ) - collectionView.frame.origin.y
        
        vertCVExpanded = tempRect // Height is the only difference
        
    }
    
//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
    
    func setTabBarButtonColors() {
        
        switch tabButtonMode {
            
        case myTabButtons.tabAllServices.rawValue:
            
            faketabbar.titleLabel?.font = UIFont.boldSystemFont(ofSize: buttonEmphasizedFontSize )
            faketabbar.setTitleColor( UIColor(named: "myGreenTint"), for: UIControl.State.normal )
            faketabbar.backgroundColor = .white
            
            featuredButton.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize )
            featuredButton.setTitleColor( .white, for: UIControl.State.normal )
            featuredButton.backgroundColor = UIColor(named: "myGreenTint")
            
            favouriteButton.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize )
            favouriteButton.tintColor = UIColor.white
            favouriteButton.backgroundColor = UIColor(named: "myGreenTint")
            
            break
            
        case myTabButtons.tabFeatured.rawValue:
            
            faketabbar.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize )
            faketabbar.setTitleColor( .white, for: UIControl.State.normal )
            faketabbar.backgroundColor = UIColor(named: "myGreenTint")
            
            featuredButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: buttonEmphasizedFontSize )
            featuredButton.setTitleColor( UIColor(named: "myGreenTint"), for: UIControl.State.normal )
            featuredButton.backgroundColor = .white
            
            favouriteButton.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize )
            favouriteButton.tintColor = UIColor.white
            favouriteButton.backgroundColor = UIColor(named: "myGreenTint")
            
            break
            
        case myTabButtons.tabFavourites.rawValue:
            
            faketabbar.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize )
            faketabbar.setTitleColor( .white, for: UIControl.State.normal )
            faketabbar.backgroundColor = UIColor(named: "myGreenTint")
            
            featuredButton.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize )
            featuredButton.setTitleColor( .white, for: UIControl.State.normal )
            featuredButton.backgroundColor = UIColor(named: "myGreenTint")
            
            favouriteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: buttonEmphasizedFontSize )
            favouriteButton.tintColor = UIColor(named: "myGreenTint")
            favouriteButton.backgroundColor = .white
            
            break
            
        default:
            
            return
            
        }
        
    }
    
    
    
    
    
//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
    
    @IBAction func menuButtonTapped(_ sender: UIBarButtonItem) {
        
        print("Menu button tapped!")
        
    }
    
    
    
    
    
//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
    
    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
        
        print("Search button tapped!")
        
    }
    
    
    
    
    
//🔷🔷🔷🔷🔷🔷🔷🔷  ACTIONS FOR THE TAB BAR BUTTONS  🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
    
    @IBAction func AllServicesAction(_ sender: UIButton) {
        
        if tabButtonMode == myTabButtons.tabAllServices.rawValue {
            
            if showSelectedServices == false {
                
                return
                
            }
            
        }
        
        currentCategory      = -1    // No current category
        
        showSelectedServices = false // Show ALL SERVICES
        
        commonTabButtonCode( myTabButtons.tabAllServices.rawValue )

    }
    
//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
    
    @IBAction func FeaturedAction(_ sender: UIButton) {
        
        if tabButtonMode == myTabButtons.tabFeatured.rawValue {
            
            return // Do nothing if already in that mode
            
        }

        commonTabButtonCode( myTabButtons.tabFeatured.rawValue )
        
    }
    
//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
    
    @IBAction func FavouriteAction(_ sender: UIButton) {
        
        if tabButtonMode == myTabButtons.tabFavourites.rawValue {
            
            return // Do nothing if already in that mode
            
        }
        
        commonTabButtonCode( myTabButtons.tabFavourites.rawValue )

    }
    
    
    
    
    

//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    func commonTabButtonCode (_ theButton: Int ) {
        
        tabButtonMode = theButton
        
        if tabButtonMode == myTabButtons.tabAllServices.rawValue {
            
            horizontalcollectionView.isHidden = false   // Show Categories collectionView

            collectionView.frame = vertCVCompressed
            
        } else {
            
            horizontalcollectionView.isHidden = true
            
            collectionView.frame = vertCVExpanded

        }
        
        self.navBar.topItem!.title = navTitle[ tabButtonMode ]

        setTabBarButtonColors()
        
        collectionView.reloadData() // Show the Services
        
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true )

    }
    
    
    
    
//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    func isFavourite( theID: Services ) -> Bool {
        
        if favouritesArray.count == 0 {
            
            return false
            
        }
        
        for localID in favouritesArray {
            
            if localID.categoryID == theID.categoryID {
                
                if localID.serviceID == theID.serviceID {
                    
                    return true
                    
                }
                
            }
            
        }
        
        return false
        
    }
    
    
    
    
//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    func removeFavourite( theID: Services ) {
        
        if favouritesArray.count == 0 {
            
            return
            
        }
        
        var localIndex: Int = 0
        
        for localID in favouritesArray {
            
            if localID.categoryID == theID.categoryID {
                
                if localID.serviceID == theID.serviceID {
                    
                    favouritesArray.remove(at: localIndex)
                    
                    
                    
                    if favouritesArray.count == 0 {
                        
                        // Simulate pressing All Services tab button after removing last Favourite
                        
                        currentCategory      = -1    // No current category

                        showSelectedServices = false //
                        
                        commonTabButtonCode( myTabButtons.tabAllServices.rawValue )
                        
                    }

                    return
                    
                }
                
            }
            
            localIndex += 1
            
        }
        
    }
    
//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    func enableDisableFavouritesButton() {
        
        if favouritesArray.count > 0 {
            
            favouriteButton.isEnabled = true
            
        } else {
            
            favouriteButton.isEnabled = false

        }
        
    }

//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    @IBAction func vCVShareButtonTapped(_ sender: UIButton) {
        
        let activityVC = UIActivityViewController(activityItems: [link], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        activityVC.excludedActivityTypes = [        // Anything you want to exclude

            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList

        ]
        
        self.present(activityVC, animated: true, completion: nil)
        
    }
    
    
    
    
    
//🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼

// Support for images - The functions below were created to access saved images just using ID's
    
    func saveServiceImage( categoryID: Int, serviceID: Int, image: UIImage ) {
        
        let imageName = getServiceImagePath(categoryID: categoryID, serviceID: serviceID )

        let imageURL  = URL.init(fileURLWithPath: docsDir + imageName )
        
        if let data = image.pngData() {

            do {
                
                try data.write(to: imageURL )

            } catch {

                print("error saving", error)

            }

        }
        
    }
    
    //----------------------------------------------------------------------------------------------------------

    func saveCategoriesImage( categoryID: Int, image: UIImage ) {
        
        let imageName = getCategoryImagePath(categoryID: categoryID )

        let imageURL  = URL.init(fileURLWithPath: docsDir + imageName )
        
        if let data = image.pngData() {

            do {
                
                try data.write(to: imageURL )

            } catch {

                print("error saving", error)

            }

        }
        
    }
    
    
    
    
    
    
    //----------------------------------------------------------------------------------------------------------

    func createDir( dir: String ) {
        
        let fullDirPath           = docsDir + "/" + dir
        
        print(fullDirPath) //‼️‼️‼️‼️ Only here for development - Remove before uploading to Apple ‼️‼️‼️‼️‼️‼️‼️‼️

        let fileManager           = FileManager.default
        var isDirectory: ObjCBool = false

        if !fileManager.fileExists(atPath: fullDirPath, isDirectory: &isDirectory) {

            // Only create the directory if it does not already exist
            
            do {
                    try FileManager.default.createDirectory(atPath: fullDirPath, withIntermediateDirectories: true, attributes: nil)
                
                    print("Subdirectory " + dir + " created")  // Remove before uploading to Apple
                
                  } catch {

                    print(error)
                  
            }
            
        }
        
    }
    
    
    
    
    
    
    //----------------------------------------------------------------------------------------------------------

    func doesCategoryImageExist( categoryID: Int ) -> Bool {
        
        let docsDirPath       = NSURL(string: docsDir )!

        let imageFilePath     = docsDirPath.appendingPathComponent( getCategoryImagePath(categoryID: categoryID ) )

        let fileManager           = FileManager.default
        var isDirectory: ObjCBool = false

        var exists: Bool = false
        
        if fileManager.fileExists(atPath: imageFilePath!.path, isDirectory: &isDirectory) {

            exists = true

        }
        
        return exists
        
    }
    
    
    
    //----------------------------------------------------------------------------------------------------------

    func doesServiceImageExist( categoryID: Int, serviceID: Int ) -> Bool {
        
        let docsDirPath       = NSURL(string: docsDir )!

        let imageFilePath     = docsDirPath.appendingPathComponent( getServiceImagePath(categoryID: categoryID, serviceID: serviceID) )

        let fileManager           = FileManager.default
        var isDirectory: ObjCBool = false

        var exists: Bool = false
        
        if fileManager.fileExists(atPath: imageFilePath!.path, isDirectory: &isDirectory) {

            exists = true

        }
        
        return exists
        
    }
    
    
    
    
    //----------------------------------------------------------------------------------------------------------

    func loadCategoryImage( categoryID : Int ) -> UIImage {
        
        let imageURL = URL(fileURLWithPath: docsDir).appendingPathComponent( getCategoryImagePath(categoryID: categoryID) )
        
        guard let image = UIImage(contentsOfFile: imageURL.path) else { return  UIImage.init() }

        return image

    }
    
    
    
    //----------------------------------------------------------------------------------------------------------

    func loadServiceImage( categoryID : Int, serviceID : Int ) -> UIImage {
        
        let imageURL = URL(fileURLWithPath: docsDir).appendingPathComponent( getServiceImagePath(categoryID: categoryID, serviceID: serviceID) )
        
        guard let image = UIImage(contentsOfFile: imageURL.path) else { return  UIImage.init() }

        return image

    }

    
    
    
    //----------------------------------------------------------------------------------------------------------

    func getCategoryImagePath( categoryID : Int ) -> String {
        
        return "/Categories/\(String(categoryID)).png"
        
    }
    
    
    

    
    
    //----------------------------------------------------------------------------------------------------------

    func getServiceImagePath( categoryID : Int, serviceID : Int ) -> String {
        
        return "/AllServices/\(String(categoryID))-\(String(serviceID)).png"
        
    }
    
    
    
    //----------------------------------------------------------------------------------------------------------
    
    // The function below is necessary because AlamoFire WAS NOT scaling the images 😔😔😔😔😔😔
    
    func resizeImage( theImage: UIImage, theSize: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext( theSize )
        
        // Draw the image inside the correctly sized temporary context
        theImage.draw(in: CGRect( x: 0, y:0, width: theSize.width, height: theSize.height) )
        
        let returnImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return returnImage
        
    }
    
//🖼🖼🖼🖼  END OF IMAGE SUPPORT  🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼🖼

    
    // SAVE FAVORITES
    
    func saveFavorites() {
        

    }
    
}


//❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌
//❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌
//❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌


//🔷🔷🔷🔷🔷  extention for UICollectionViewDelegateFlowLayout  🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

extension ViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if ( collectionView == horizontalcollectionView ) {
            
            return UIEdgeInsets(top: myHorizCVSpacing, left: myHorizCVSpacing, bottom: myHorizCVSpacing, right: myHorizCVSpacing)
            
        } else {
            
            return UIEdgeInsets(top: myVertCVSpacing, left: myVertCVSpacing, bottom: myVertCVSpacing, right: myVertCVSpacing)
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        if ( collectionView == horizontalcollectionView ) {
            
            return myHorizCVSpacing
            
        } else {
            
            return myVertCVSpacing
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if ( collectionView == horizontalcollectionView ) {
            
            return myHorizCVSpacing
            
        } else {
            
            return myVertCVSpacing
            
        }
        
    }
    
}

//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷



