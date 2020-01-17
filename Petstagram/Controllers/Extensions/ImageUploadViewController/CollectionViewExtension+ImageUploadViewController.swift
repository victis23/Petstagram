//
//  CollectionViewExtension+ImageUploadViewController.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/14/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

/// Extension contains methods that manage the presentation of images contained in a user's photo album on disk.
extension ImageUploadViewController: UICollectionViewDelegate {
	
	/// Creates visable reusable cells that will hold the images retrieved from disk.
	func setDataSource(){
		datasource = UICollectionViewDiffableDataSource<Sections,ImageAlbum>(collectionView: albumImageCollection, cellProvider: { (collectionView, indexPath, images) -> UICollectionViewCell? in
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? AlbumImagesCollectionViewCell else {fatalError()}
			
			cell.imageFromAlbum.image = images.images
			cell.imageFromAlbum.contentMode = .scaleAspectFill
			cell.clipsToBounds = true
			cell.layer.cornerRadius = 3
			
			return cell
		})
	}
	
	/// Applies our source of truth... adds images to `UICollectionView`.
	func createSnapshot(images : [ImageAlbum]){
		var snapshot = NSDiffableDataSourceSnapshot<Sections,ImageAlbum>()
		snapshot.appendSections([.main])
		snapshot.appendItems(images, toSection: .main)
		
		datasource.apply(snapshot, animatingDifferences: true)
	}
}
