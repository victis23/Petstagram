//
//  GenericProfileViewController.swift
//  Petstagram
//
//  Created by Scott Leonard on 2/13/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

class GenericProfileViewController: UIViewController {
	
	@IBOutlet weak var profileImage: UIImageView!
	@IBOutlet weak var userName: UILabel!
	@IBOutlet weak var accountImageCollection: UICollectionView!
	@IBOutlet weak var followButton: UIButton!
	@IBOutlet weak var profileDescription: UILabel!
	@IBOutlet weak var postCount: UILabel!
	
	var account : PetstagramUsers!
	
	var accountImages : [AccountImages] = [] {
		didSet {
			postCount.text = "\(accountImages.count)"
		}
	}
	
	var dataSource : UICollectionViewDiffableDataSource<Sections,AccountImages>!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setNavigationBar()
		setAccountVisuals()
		setLayout()
		getProfileDescription(user: account)
		getImagesForAccount()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		setDataSource()
		setSnapShot()
	}
	
	/// Sets the aesthetic properties on views.
	func setAccountVisuals(){
		
		userName.text = account.username
		userName.font = UIFont.monospacedSystemFont(ofSize: 30, weight: .heavy)
		
		profileImage.image = account.image
		profileImage.layer.borderColor = UIColor.label.cgColor
		profileImage.layer.borderWidth = 2
		profileImage.layer.cornerRadius = 5
		
		followButton.layer.cornerRadius = 5
	}
	
	/// Sets attributes for navigation bar.
	func setNavigationBar(){
		self.navigationItem.title = "Petstagram"
		
		if let font = UIFont(name: "Billabong", size: 34) {
			
			self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : font]
		}
		
		self.navigationController?.navigationBar.tintColor = .label
	}
	
	/// Sets description to view using helper class to get data from Google FireStore database.
	func getProfileDescription(user:PetstagramUsers){
		
		let descriptionRetriever = DescriptionRetriever(userID: user.uid)
		
		descriptionRetriever.getDescription { retrievedString in
			
			self.profileDescription.text = retrievedString
		}
	}
	
	/// Retrieves images from firebase storage using metadata.
	func getImagesForAccount(){
		
		let imageDownloader = ImageDownloader(account: account.uid)
		
		// Retrieves metadata information for each image on storage.
		imageDownloader.downloadImages { (metaData) in
			
			// Uses metadata to provide actual image.
			imageDownloader.downloadImages(for: metaData.name) { (image) in
				
				guard let timestamp = metaData.timeCreated,
					let id = metaData.name else {return}
				
				let item = AccountImages(image: image, timeStamp: timestamp, metaData: metaData, id: id)
				
				// Check for repeated images or profile images.
				let contains = self.accountImages.contains { accountImageItem in
					accountImageItem.id == item.id || item.id == "profileImage"
				}
				
				// Adds images to collection.
				self.updateCollectionViewContent(contains: contains, accountImage: item)
			}
		}
	}
	
	/// Makes sure items added to collectionview are unique and sorted with the last added item first.
	func updateCollectionViewContent(contains:Bool, accountImage:AccountImages){
		
		guard !contains else {return}
		
		accountImages.append(accountImage)
		sort()
		setSnapShot()
	}
	
	/// Sorts objects from last to first.
	func sort(){
		accountImages.sort { value1, value2 -> Bool in
			value1.timeStamp > value2.timeStamp
		}
	}
	
	func setDataSource(){
		
		dataSource = UICollectionViewDiffableDataSource<Sections,AccountImages>(collectionView: accountImageCollection, cellProvider: { (collectionView, indexPath, images) -> UICollectionViewCell? in
			
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "accountImages", for: indexPath) as? UserImageCollectionViewCell else {fatalError()}
			
			cell.imageCell.image = images.image
			cell.imageCell.layer.cornerRadius = 5
			cell.imageCell.contentMode = .scaleAspectFill
			
			return cell
		})
	}
	
	func setSnapShot(){
		
		var snapshot = NSDiffableDataSourceSnapshot<Sections,AccountImages>()
		snapshot.appendSections([.main])
		snapshot.appendItems(accountImages, toSection: .main)
		dataSource.apply(snapshot, animatingDifferences: false, completion: {})
	}
	
	/// Sets layout for collectionView.
	func setLayout(){
		
		// Group height is 40% the height of the UICollectionView Frame.
		let collectionBuilder = CollectionViewBuilder(cellFractionalHeight: 1, cellFractionalWidth: 1, groupFractionalHeight: 0.4, groupFractionalWidth: 1, columns: 3, evenInsets: 1)
		
		let layout = collectionBuilder.setLayout()
		accountImageCollection.collectionViewLayout = layout
	}
}
