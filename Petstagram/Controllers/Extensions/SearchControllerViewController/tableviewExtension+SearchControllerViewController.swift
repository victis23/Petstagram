//
//  tableviewExtension+SearchControllerViewController.swift
//  Petstagram
//
//  Created by Scott Leonard on 2/12/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

/// Handles required methods for UITableViewDiffableDataSource & building tableview for user.
extension SearchControllerViewController : UITableViewDelegate {
	
	// FIXME: Need to add TableView Cell Class to Method.
	
	func setDataSource(){
		dataSource = UITableViewDiffableDataSource<Section,PetstagramUsers>(tableView: tableView, cellProvider: { (tableView, indexPath, appUsers) -> UITableViewCell? in
			
			guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? AccountSearchTableViewCell else {fatalError()}
			
			cell.userName.text = appUsers.username
			cell.followButton.layer.cornerRadius = 5
			
			DispatchQueue.main.async {
				self.getProfilePhoto(user: appUsers.uid) { (image) in
					cell.profilePhoto.layer.cornerRadius = cell.profilePhoto.frame.height / 2
					cell.profilePhoto.image = image
					cell.profilePhoto.contentMode = .scaleAspectFit
				}
			}
			
			return cell
		})
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
		
		let selectedAccount = dataSource.itemIdentifier(for: indexPath)
		
		performSegue(withIdentifier: Keys.Segues.otherUsers, sender: selectedAccount)
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
