//
//  ImageUploadViewController.swift
//  fakerGram
//
//  Created by Scott Leonard on 12/7/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit
import Photos

struct UserImages : Hashable, Identifiable {
	var images : UIImage = UIImage()
	var id = UUID().uuidString
	
	func hash(into hasher :inout Hasher){
		hasher.combine(id)
	}
}

class ImageUploadViewController: UIViewController {
	
	enum Sections {
		case main
	}
	
	@IBOutlet weak var selectedImage: UIImageView!
	@IBOutlet weak var albumImageCollection: UICollectionView!
	
	private var albumImages : [UserImages] = [] {
		didSet {
			createSnapshot(images: albumImages)
		}
	}
	
	private var datasource : UICollectionViewDiffableDataSource<Sections,UserImages>!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setNavigationBar()
		
//		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1), heightDimension: .fractionalWidth(1))
//		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.25))
//		
//		let item = NSCollectionLayoutItem(layoutSize: itemSize)
//		item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
//		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 5)
//		group.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0)
//		let section = NSCollectionLayoutSection(group: group)
//		albumImageCollection.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		setDataSource()
		createSnapshot(images: albumImages)
		selectImageWithPicker()
		albumImageCollection.delegate = self
	}
	
	func setNavigationBar(){
		self.navigationItem.title = "Petstagram"
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Billabong", size: 35)!]
		self.navigationController?.navigationBar.tintColor = .label
		self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage.init(systemName: "camera.circle"), style: .plain, target: self, action: #selector(cameraButtonSelected))]
	}
	
	@objc func cameraButtonSelected(){
		selectImageWithPicker(isCameraImage: true)
	}
	
}

extension ImageUploadViewController: UICollectionViewDelegate {
	
	func setDataSource(){
		datasource = UICollectionViewDiffableDataSource<Sections,UserImages>(collectionView: albumImageCollection, cellProvider: { (collectionView, indexPath, images) -> UICollectionViewCell? in
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ImagesCollectionViewCell else {fatalError()}
			
			cell.imageFromAlbum.image = images.images
			cell.imageFromAlbum.contentMode = .scaleAspectFill
			
			return cell
		})
	}
	
	func createSnapshot(images : [UserImages]){
		var snapshot = NSDiffableDataSourceSnapshot<Sections,UserImages>()
		snapshot.appendSections([.main])
		snapshot.appendItems(images, toSection: .main)
		
		datasource.apply(snapshot, animatingDifferences: true, completion: {
			
		})
	}
}

extension ImageUploadViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	
	func selectImageWithPicker(isCameraImage: Bool = false){
		
		let imagePickerController = UIImagePickerController()
		imagePickerController.delegate = self
		
		
		if UIImagePickerController.isSourceTypeAvailable(.camera) && UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
			//			imagePickerController.sourceType = .photoLibrary
			//			imagePickerController.allowsEditing = true
			
			
			var photoAsset: PHFetchResult<PHAsset>?
			
			
			let photoOptions = PHFetchOptions()
			
			let collectionRequested : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: photoOptions)
			
			//			guard let assetCollection :PHAssetCollection = collectionRequested.firstObject  else {return}
			
			var imageArray = [UIImage]()
			
			collectionRequested.enumerateObjects { (collection, index, pointer) in
				
				
				photoAsset = PHAsset.fetchAssets(in: collection, options: nil)
				guard let images = photoAsset else {fatalError()}
				
				for i in 0..<images.count {
					
					PHImageManager.default().requestImage(for: images[i], targetSize: CGSize(width: 900, height: 900), contentMode: .aspectFit, options: nil) { (image, imageDictionary) in
						guard let image = image else {return}
						imageArray.append(image)
					}
				}
				
			}
			
			imageArray.forEach { image in
				albumImages.append(UserImages(images: image))
			}
			
			selectedImage.image = imageArray.first
			selectedImage.contentMode = .scaleAspectFill
			
			if isCameraImage {
				imagePickerController.sourceType = .camera
				imagePickerController.cameraCaptureMode = .photo
				imagePickerController.showsCameraControls = true
				present(imagePickerController, animated: true)
			}
		}
		
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		guard let rectangleImage = info[.editedImage] as? UIImage else {return}
		
		selectedImage.image = rectangleImage
		selectedImage.contentMode = .scaleAspectFill
		albumImages.append(UserImages(images: rectangleImage))
		dismiss(animated: true, completion: {})
		
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		selectedImage.image = datasource.itemIdentifier(for: indexPath)?.images
	}
	
	
}

