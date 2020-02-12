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
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
			return cell
		})
	}
	
	func setSnapShot(users : [PetstagramUsers]){
		var snapShot = NSDiffableDataSourceSnapshot<Section,PetstagramUsers>()
		snapShot.appendSections([.main])
		snapShot.appendItems(users, toSection: .main)
		dataSource.apply(snapShot, animatingDifferences: true, completion: {})
	}
}
