//
//  AccountImageListTableViewController.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/18/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

class AccountImageListTableViewController: UITableViewController {
	
	/// Enum that determines sections in source of truth
	private enum Sections {
		case images
		case comments
	}
	/*
	/// Manages user comments for images.
	struct Comments : Hashable, Equatable {
		var comment : [String]?
		var accountImage : AccountImages
		var id : String {
			return accountImage.id
		}
		
		init(accountImage : AccountImages) {
			self.accountImage = accountImage
		}
		
		func hash(into hasher : inout Hasher){
			hasher.combine(id)
		}
		
		static func == (lhs: Comments, rhs: Comments)->Bool{
			lhs.id == rhs.id
		}
	}
	*/
	
	// Stored Property that gets its initial value during segue.
	var profileImages : [AccountImages] = []
	var imagePointer : String?
	
	// source of truth instance.
	private var datasource : UITableViewDiffableDataSource<Sections,AccountImages>!

    override func viewDidLoad() {
		
        super.viewDidLoad()
		createDataSource()
		createSnapshot(accountImages: profileImages)
    }
	
	/// Utilizes snapshot data to display visual representation to user in a tableview.
	func createDataSource(){
		datasource = UITableViewDiffableDataSource<Sections,AccountImages>(tableView: tableView, cellProvider: { (tableView, indexPath, accountImages) -> UITableViewCell? in
			
			let imageCell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath)
			
			return imageCell
			
		})
	}
	
	/// Source of truth for tableview.
	func createSnapshot(accountImages : [AccountImages]){
		
		var snapshot = NSDiffableDataSourceSnapshot<Sections,AccountImages>()
		snapshot.appendSections([.images,.comments])
		snapshot.appendItems(accountImages, toSection: .images)
		
		datasource.apply(snapshot, animatingDifferences: true, completion: {})
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 414
	}
}
