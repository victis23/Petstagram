//
//  CollectionViewMethods.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/11/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

/// Extension that contains methods that uiCollectionView on `UserProfileViewController`.
extension UserProfileViewController : UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		guard let item = datasource.itemIdentifier(for: indexPath) else {return}
		
		performSegue(withIdentifier: Keys.Segues.imageViewer, sender: item.id)
	}
	
	/// Method tasked with determining the layout of the collection when view loads.
	/// - Note: Current layout consists of 2 rows & 3 columns.
	func setCollectionViewLayout(){
		
		// Group height is 40% the height of the UICollectionView Frame.
		let collectionBuilder = CollectionViewBuilder(cellFractionalHeight: 1, cellFractionalWidth: 1, groupFractionalHeight: 0.4, groupFractionalWidth: 1, columns: 3, evenInsets: 1)
		
		let layout = collectionBuilder.setLayout()
		
		accountImages.collectionViewLayout = layout
	}
	
	/// Generates reusable cells that will be displayed to the user.
	func setDataSource(){
		datasource = UICollectionViewDiffableDataSource<Sections,AccountImages>(collectionView: accountImages, cellProvider: { (collectionView, indexPath, ImageObject) -> UICollectionViewCell? in
			
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as? UserImageCollectionViewCell else {fatalError()}
			
			cell.imageCell.image = ImageObject.image
			cell.imageCell.contentMode = .scaleAspectFill
			cell.imageCell.layer.cornerRadius = 5
			
			return cell
		})
	}
	
	/// Uses source of truth to apply changes to `UICollectionView`.
	/// - Note: Upon completion calls method that scrolls collection view to first encapsuled element. 
	func setSnapShot(){
		var snapShot = NSDiffableDataSourceSnapshot<Sections,AccountImages>()
		snapShot.appendSections([.main])
		snapShot.appendItems(self.images, toSection: .main)
		datasource.apply(snapShot, animatingDifferences: true, completion: {
			
			self.returnToFirstItemInCollection()
		})
	}
	
}
