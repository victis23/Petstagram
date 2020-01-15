//
//  CollectionViewExtension+ImageUploadViewController.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/14/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

extension ImageUploadViewController: UICollectionViewDelegate {
	
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
	
	func createSnapshot(images : [ImageAlbum]){
		var snapshot = NSDiffableDataSourceSnapshot<Sections,ImageAlbum>()
		snapshot.appendSections([.main])
		snapshot.appendItems(images, toSection: .main)
		
		datasource.apply(snapshot, animatingDifferences: true, completion: {
			
		})
	}
}
