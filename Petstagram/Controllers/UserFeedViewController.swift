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
	
	var following : [AccountImages] = [] {
		didSet {
			tableViewSnapShot(following: following)
		}
	}
	var friends : [PetstagramUsers] = [] {
		didSet {
			collectionViewSnapShot(friends: friends)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupNavigation()
		tableView.delegate = self
		collectionView.delegate = self
		setCollectionViewLayout()
		setDataSource()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		friends.removeAll()
		following.removeAll()
		tableViewSnapShot(following: following)
		collectionViewSnapShot(friends: friends)
		getFriends()
	}
	
	func setCollectionViewLayout(){
		
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
		let cell = NSCollectionLayoutItem(layoutSize: itemSize)
		cell.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
		
		
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1))
		let cellGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: cell, count: 1)
		
		let section = NSCollectionLayoutSection(group: cellGroup)
		section.orthogonalScrollingBehavior = .continuous
		
		let layout = UICollectionViewCompositionalLayout(section: section)
		
		collectionView.collectionViewLayout = layout
	}
	
	func getFriends(){
		
		FollowerTracker.getFollowingList(completion: { accounts in
			accounts.forEach { account in
				let descriptionRetriever = DescriptionRetriever(userID: account)
				let imageDownloader = ImageDownloader(account: account)
				descriptionRetriever.getUserName(completion: { userName in
					self.friends.append(PetstagramUsers(userName, account))
					imageDownloader.downloadImages { (metadata) in
						imageDownloader.downloadImages(for: metadata.name, imageItem: { image in
							guard let timestamp = metadata.timeCreated, let id = metadata.name else {return}
							let contains = self.following.contains { (image) -> Bool in
								image.id == id
							}
							if !contains {
								self.following.append(AccountImages(image: image, timeStamp: timestamp, metaData: metadata, id: id))
							}
							self.sort()
						})
					}
				})
			}
		})
	}
	
	func sort(){
		following.sort { value1, value2 -> Bool in
			value1.timeStamp > value2.timeStamp
		}
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
			cell.feedImage.contentMode = .scaleAspectFill
			
			return cell
		})
		
		collectionViewDataSource = UICollectionViewDiffableDataSource<Section,PetstagramUsers>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, account) -> UICollectionViewCell? in
			
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friendsListCells", for: indexPath) as! FeedCollectionViewCell
			cell.username.text = account.username
			
			let descriptionRetriever = DescriptionRetriever(userID: account.uid)
			descriptionRetriever.getProfilePhoto(completion: { image in
				
				cell.FriendImages.image = image
				cell.FriendImages.layer.cornerRadius = cell.FriendImages.frame.width / 2
				cell.FriendImages.contentMode = .scaleAspectFit
				cell.FriendImages.layer.borderColor = UIColor.label.cgColor
				cell.FriendImages.layer.borderWidth = 2
				cell.FriendImages.layer.masksToBounds = true
				cell.FriendImages.clipsToBounds = true
			})
			
			return cell
		})
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 600
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
