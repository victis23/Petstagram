//
//  UserFeedViewController.swift
//  fakerGram
//
//  Created by Scott Leonard on 12/6/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CoreData

class UserFeedViewController: UIViewController {
	
	@IBOutlet weak var tableView : UITableView!
	@IBOutlet weak var collectionView : UICollectionView!
	
	var tableViewDataSource : UITableViewDiffableDataSource<Section,AccountImages>?
	var collectionViewDataSource : UICollectionViewDiffableDataSource<Section,PetstagramUsers>?
	
	var following : [AccountImages] = []
	var friends : [PetstagramUsers] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupNavigation()
		tableView.delegate = self
		collectionView.delegate = self
		setDataSource()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		tableViewSnapShot(following: following)
		collectionViewSnapShot(friends: friends)
	}
	
	func setupNavigation(){
		// used navigataion item title property instead of \.view.title because I dont want titles in tab bar.
		self.navigationItem.title = "Petstagram"
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Billabong", size: 34)!]
		
	}
}

extension UserFeedViewController : UITableViewDelegate, UICollectionViewDelegate {
	
	
	// MARK: TableView & collectionView Methods
	
	func setDataSource(){
		
		tableViewDataSource = UITableViewDiffableDataSource<Section,AccountImages>(tableView: tableView, cellProvider: { (tableView, indexPath, profileImages) -> UITableViewCell? in
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "feedCells", for: indexPath) as! FeedTableViewCell
			cell.feedImage.image = profileImages.image
			
			return cell
		})
		
		collectionViewDataSource = UICollectionViewDiffableDataSource<Section,PetstagramUsers>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, account) -> UICollectionViewCell? in
			
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friendsListCells", for: indexPath) as! FeedCollectionViewCell
			cell.username.text = account.username
			
			return cell
		})
	}
	
	func tableViewSnapShot(following : [AccountImages]){
		var snapshot = NSDiffableDataSourceSnapshot<Section,AccountImages>()
		snapshot.appendSections([.main])
		snapshot.appendItems(following, toSection: .main)
		tableViewDataSource?.apply(snapshot, animatingDifferences: true, completion: {})
	}
	
	func collectionViewSnapShot(friends : [PetstagramUsers]){
		var snapshot = NSDiffableDataSourceSnapshot<Section,PetstagramUsers>()
		snapshot.appendSections([.main])
		snapshot.appendItems(friends, toSection: .main)
		collectionViewDataSource?.apply(snapshot, animatingDifferences: true, completion: {})
	}
	
}

class FeedTableViewCell : UITableViewCell {
	
	@IBOutlet weak var feedImage: UIImageView!
}

class FeedCollectionViewCell : UICollectionViewCell {
	
	@IBOutlet weak var FriendImages: UIImageView!
	@IBOutlet weak var username: UILabel!
}
