//
//  CollectionViewMethods.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/11/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

extension UserProfileViewController {
	
	/// Method tasked with determining the layout of the collection when view loads.
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
	
	func setDataSource(){
		datasource = UICollectionViewDiffableDataSource<Sections,UserProfileImageCollection>(collectionView: accountImages, cellProvider: { (collectionView, indexPath, ImageObject) -> UICollectionViewCell? in
			
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as? UserImageCollectionViewCell else {fatalError()}
			
			cell.imageCell.image = ImageObject.image
			cell.imageCell.contentMode = .scaleAspectFill
			cell.imageCell.layer.cornerRadius = 5
			
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
	
}