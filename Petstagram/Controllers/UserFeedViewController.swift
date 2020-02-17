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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigation()
	}
	
	func setupNavigation(){
		// used navigataion item title property instead of \.view.title because I dont want titles in tab bar.
		self.navigationItem.title = "Petstagram"
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Billabong", size: 34)!]
		
	}
	
}

extension UserFeedViewController : UITableViewDelegate {
	
	
	// MARK: TableView & collectionView Methods
	
	func setDataSource(){
		tableViewDataSource = UITableViewDiffableDataSource<Section,AccountImages>(tableView: tableView, cellProvider: { (tableView, indexPath, profileImages) -> UITableViewCell? in
			let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
			return cell
		})
		
		collectionViewDataSource = UICollectionViewDiffableDataSource<Section,PetstagramUsers>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, account) -> UICollectionViewCell? in
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
			return cell
		})
	}
	
	func tableViewSnapShot(){
		
	}
	
	func collectionViewSnapShot(){
		
	}
	
}
