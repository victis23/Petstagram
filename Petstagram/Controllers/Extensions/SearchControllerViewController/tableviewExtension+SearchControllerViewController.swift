//
//  tableviewExtension+SearchControllerViewController.swift
//  Petstagram
//
//  Created by Scott Leonard on 2/12/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

/// Handles required methods for UITableViewDiffableDataSource & building tableview for user.
extension SearchControllerViewController : UITableViewDelegate, AccountSearchDelegate {
	
	func setDataSource(){
		dataSource = UITableViewDiffableDataSource<Section,PetstagramUsers>(tableView: tableView, cellProvider: { (tableView, indexPath, appUsers) -> UITableViewCell? in
			
			guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? AccountSearchTableViewCell else {fatalError()}
			
			cell.delegate = self
			cell.account = appUsers
			cell.userName.text = appUsers.username
			cell.followButton.layer.cornerRadius = 5
			
			self.checkFollowStatus(account: appUsers, completion: {
				
				//Control checks if user is a follower of not.
				if appUsers.following {
					cell.followButton.setTitle("Unfollow", for: .normal)
					cell.followButton.backgroundColor = .red
				}else{
					cell.followButton.setTitle("Follow", for: .normal)
					cell.followButton.backgroundColor = .link
				}
			})
			
			DispatchQueue.main.async {
				self.getProfilePhoto(user: appUsers.uid) { (image) in
					cell.profilePhoto.layer.cornerRadius = cell.profilePhoto.frame.height / 2
					appUsers.image = image
					cell.profilePhoto.image = appUsers.image
					cell.profilePhoto.contentMode = .scaleAspectFit
				}
			}
			
			return cell
		})
	}
	
	/// Conforms to protocol
	func updateFollower(account: PetstagramUsers) {
		let following = !account.following
		let followerTracker = FollowerTracker(follower: account, isFollowing: following)
		followerTracker.checkState()
		tableView.reloadData()
	}
	
	/// Checks database to determine is user follows the account in question. If the user does follow the account method updates list of accounts on client side.
	func checkFollowStatus(account:PetstagramUsers, completion : @escaping ()->Void) {
		
		guard let user = userProfile.user else {fatalError()}
		
		self.db.collection(user).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.following).addSnapshotListener(includeMetadataChanges: true) { (document, error) in
			
			if let error = error {
				print(error.localizedDescription)
			}
			
			guard let document = document, let profile = document[Keys.GoogleFireStore.following] as? [String:String] else {return}
			
			// If account is listed in the user's follower list control updates follow state for item.
			if profile[account.username] != nil {
				account.following = true
			}else{
				account.following = false
			}
			completion()
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}
	
	func setSnapShot(users : [PetstagramUsers]){
		var snapShot = NSDiffableDataSourceSnapshot<Section,PetstagramUsers>()
		snapShot.appendSections([.main])
		snapShot.appendItems(users, toSection: .main)
		dataSource.apply(snapShot, animatingDifferences: true, completion: {})
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		searchBar.text = nil
		searchBar.resignFirstResponder()
		
		let selectedAccount = dataSource.itemIdentifier(for: indexPath)
		
		performSegue(withIdentifier: Keys.Segues.otherUsers, sender: selectedAccount)
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
