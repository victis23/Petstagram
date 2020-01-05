//
//  UserProfileViewController.swift
//  fakerGram
//
//  Created by Scott Leonard on 12/7/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserProfileViewController: UIViewController {
	
	enum Sections {
		case main
	}
	
	struct UserProfileImageCollection : Hashable, Identifiable {
		var image : UIImage
		var id = UUID().uuidString
		
	}
	
	
	@IBOutlet weak var accountImages: UICollectionView!
	
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	let coreDataModel = AuthenticationItems(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
	
	var datasource : UICollectionViewDiffableDataSource<Sections,UserProfileImageCollection>!
	
	var images : [UserProfileImageCollection] = [] {
		didSet {
			setSnapShot()
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		setNavigationBar()
		setDataSource()
		setSnapShot()
		setCollectionViewLayout()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		getUserImageData()
	}
	
	func getUserImageData(){
		
		self.images = []
		let userProfileInstance = UserProfile.shared()
		userProfileInstance.getImagesFromCloud()
		guard let accountImages = userProfileInstance.images else {return}
		
		accountImages.forEach({ imageData in
			guard let image = UIImage(data: imageData) else {return}
			self.images.append(UserProfileImageCollection(image: image))
		})
		
	}
	
	func setCollectionViewLayout(){
		
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
		let cell = NSCollectionLayoutItem(layoutSize: itemSize)
		cell.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
		
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.4))
		let cellGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: cell, count: 3)
		
		let section = NSCollectionLayoutSection(group: cellGroup)
		
		let layout = UICollectionViewCompositionalLayout(section: section)
		accountImages.collectionViewLayout = layout
	}
    
	func setNavigationBar(){
		self.navigationItem.title = "Petstagram"
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Billabong", size: 35)!]
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.stack.3d.up"), style: .plain, target: self, action: #selector(temporaryMethodForLoggingOut))
		self.navigationController?.navigationBar.tintColor = .label
	}
	
	func setDataSource(){
		datasource = UICollectionViewDiffableDataSource<Sections,UserProfileImageCollection>(collectionView: accountImages, cellProvider: { (collectionView, indexPath, ImageObject) -> UICollectionViewCell? in
			
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as? UserImageCollectionViewCell else {fatalError()}
			
			cell.imageCell.image = ImageObject.image
			cell.imageCell.contentMode = .scaleAspectFill
			
			return cell
		})
	}
	
	func setSnapShot(){
		var snapShot = NSDiffableDataSourceSnapshot<Sections,UserProfileImageCollection>()
		snapShot.appendSections([.main])
		snapShot.appendItems(self.images, toSection: .main)
		datasource.apply(snapShot, animatingDifferences: true, completion: {
			
		})
	}
	
	
	
	@objc func temporaryMethodForLoggingOut(){
		
		coreDataModel.coreDataEmail = nil
		coreDataModel.coreDataPassword = nil
		coreDataModel.coreDataCredential = nil
		coreDataModel.coreDataUserName = nil
		
		appDelegate.saveContext()
		
		do {
			try Auth.auth().signOut()
		}catch(let error){
			print(error.localizedDescription)
		}
		
		performSegue(withIdentifier: Keys.Segues.signOut, sender: nil)
		
	}
}
