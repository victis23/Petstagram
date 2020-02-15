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
	
	var account : PetstagramUsers!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setNavigationBar()
		setAccountVisuals()
		getProfileDescription(user: account)
	}
	
	/// Sets description to view using helper class to get data from Google FireStore database.
	func getProfileDescription(user:PetstagramUsers){
		
		let descriptionRetriever = DescriptionRetriever(userID: user.uid)
		
		descriptionRetriever.getDescription { retrievedString in
			
			self.profileDescription.text = retrievedString
		}
	}
	
	func setAccountVisuals(){
		userName.text = account.username
		profileImage.image = account.image
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
	
	func getImagesForAccount(){
		
		let imageDownloader = ImageDownloader(account: account.uid)
		
		imageDownloader.downloadImages { (metaData) in
			imageDownloader.downloadImages(for: metaData.name) { (image) in
				
				guard let timestamp = metaData.timeCreated,
					let id = metaData.name else {return}
				
				let item = AccountImages(image: image, timeStamp: timestamp, metaData: metaData, id: id)
				
				let contains = self.accountImages.contains { accountImageItem in
					accountImageItem.id == item.id || item.id == "profileImage"
				}
				
				if !contains {
					
					self.accountImages.append(item)
					
					self.accountImages.sort { (value1, value2) -> Bool in
						value1.timeStamp > value2.timeStamp
					}
				}
			}
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
	
	func setLayout(){
		
		// Group height is 40% the height of the UICollectionView Frame.
		let collectionBuilder = CollectionViewBuilder(cellFractionalHeight: 1, cellFractionalWidth: 1, groupFractionalHeight: 0.4, groupFractionalWidth: 1, columns: 3, evenInsets: 1)
		
		let layout = collectionBuilder.setLayout()
		accountImageCollection.collectionViewLayout = layout
	}
}
