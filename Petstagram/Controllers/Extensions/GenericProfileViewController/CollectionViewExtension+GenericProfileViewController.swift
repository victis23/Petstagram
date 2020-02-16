//
//  CollectionViewExtension+GenericProfileViewController.swift
//  Petstagram
//
//  Created by Scott Leonard on 2/16/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit


/// Methods that handle the collection view.
extension GenericProfileViewController : UICollectionViewDelegate {
	
	func setDataSource(){
		
		dataSource = UICollectionViewDiffableDataSource<Sections,AccountImages>(collectionView: accountImageCollection, cellProvider: { (collectionView, indexPath, images) -> UICollectionViewCell? in
			
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Keys.Cells.accountImages, for: indexPath) as? UserImageCollectionViewCell else {fatalError()}
			
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
	
	/// Sets layout for collectionView.
	func setLayout(){
		
		// Group height is 40% the height of the UICollectionView Frame.
		let collectionBuilder = CollectionViewBuilder(cellFractionalHeight: 1, cellFractionalWidth: 1, groupFractionalHeight: 0.4, groupFractionalWidth: 1, columns: 3, evenInsets: 1)
		
		let layout = collectionBuilder.setLayout()
		accountImageCollection.collectionViewLayout = layout
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		guard let selectedImage = dataSource.itemIdentifier(for: indexPath) else {return}
		
		performSegue(withIdentifier: Keys.Segues.viewOtherUserImages, sender: selectedImage)
	}
}
