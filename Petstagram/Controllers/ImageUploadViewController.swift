//
//  ImageUploadViewController.swift
//  fakerGram
//
//  Created by Scott Leonard on 12/7/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit

/// Accesses user image albums and presents them in a collectionView.
class ImageUploadViewController: UIViewController {

	//MARK: - Instance Properties
	
	// Collection that holds Images obtained from user's image assets.
	 lazy var imageArray = [UIImage]()
	
	@IBOutlet weak var shareView: UIView!
	@IBOutlet weak var shareButton: UIButton!
	@IBOutlet weak var selectedImage: UIImageView!
	@IBOutlet weak var albumImageCollection: UICollectionView!
	
	 var albumImages : [ImageAlbum] = [] {
		didSet {
			createSnapshot(images: albumImages)
		}
	}
	
	var datasource : UICollectionViewDiffableDataSource<Sections,ImageAlbum>!
	
	// Indicator that shows user that images are being retrieved.
	var activityIndicator : UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView()
		indicator.hidesWhenStopped = true
		indicator.style = .large
		indicator.color = UIColor.label
		indicator.translatesAutoresizingMaskIntoConstraints = true
		return indicator
	}()
	
	lazy var selectedImageData : Data = Data()
	lazy var userProfileInstance : UserProfile = UserProfile.shared()
	
	//MARK: View LifeCycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setNavigationBar()
		setIndicator()
		shareView.isHidden = true
		albumImageCollection.collectionViewLayout = setCollectionViewLayout() as UICollectionViewLayout
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		setDataSource()
		createSnapshot(images: albumImages)
		self.selectImageWithPicker()
		albumImageCollection.delegate = self
	}
	
	//MARK: Instance Methods
	
	func setNavigationBar(){
		self.navigationItem.title = "Petstagram"
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Billabong", size: 34)!]
		self.navigationController?.navigationBar.tintColor = .label
		self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage.init(systemName: "camera.circle"), style: .plain, target: self, action: #selector(cameraButtonSelected))]
	}
	
	/// Presents Camera Interface to user.
	@objc func cameraButtonSelected(){
		selectImageWithPicker(isCameraImage: true)
	}
	
	/// Sets the visible appearance of views presented to user.
	func setViewAesthetics(){
		shareButton.setTitle("", for: .normal)
		selectedImage.layer.cornerRadius = 5
		
		let maskLayer = CAGradientLayer()
		maskLayer.frame = shareView.bounds
		maskLayer.shadowRadius = 4
		let shape = shareView.bounds.insetBy(dx: 0, dy: 5)
		maskLayer.shadowPath = CGPath(rect: shape, transform: nil)
		maskLayer.shadowOpacity = 1
		maskLayer.shadowOffset = CGSize.zero
		maskLayer.shadowColor = UIColor.white.cgColor
		shareView.layer.mask = maskLayer
		
	}
	
	/// Places the indicatorView in the center of the main view and activates it.
	func setIndicator(){
		activityIndicator.center = self.view.center
		self.view.addSubview(activityIndicator)
		activityIndicator.startAnimating()
	}
	
	/// Set appearance and distribution of cells in the collection view.
	/// - IMPORTANT: 4 Cells in each horizontal group | Only two groups are visible in collectionView.
	func setCollectionViewLayout()->UICollectionViewCompositionalLayout{
		
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1))
		let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(view.frame.width - 20), heightDimension: .fractionalHeight(0.49))
		
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
		
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 4)
		group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
		
		let section = NSCollectionLayoutSection(group: group)
		let layout = UICollectionViewCompositionalLayout(section: section)
		
		return layout
	}
	
	/// Captures selected image; converts it into data; and uploads it to firebase.
	@IBAction func shareToProfileTapped(sender: UIButton) {
		
		guard let imageData = selectedImage.image?.pngData() else {fatalError()}
		
		userProfileInstance.imageData = imageData
		
		userProfileInstance.uploadDataToFireBase()
		
	}
	
}


