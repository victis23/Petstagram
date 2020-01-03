//
//  ImageUploadViewController.swift
//  fakerGram
//
//  Created by Scott Leonard on 12/7/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

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
	
	
	// Collection that holds Images obtained from user's image assets.
	private lazy var imageArray = [UIImage]()
	@IBOutlet weak var shareView: UIView!
	@IBOutlet weak var shareButton: UIButton!
	@IBOutlet weak var selectedImage: UIImageView!
	@IBOutlet weak var albumImageCollection: UICollectionView!
	
	private var albumImages : [UserImages] = [] {
		didSet {
			createSnapshot(images: albumImages)
		}
	}
	
	private var datasource : UICollectionViewDiffableDataSource<Sections,UserImages>!
	
	var activityIndicator : UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView()
		indicator.hidesWhenStopped = true
		indicator.style = .large
		indicator.color = UIColor.label
		indicator.translatesAutoresizingMaskIntoConstraints = true
		return indicator
	}()
	

	
	override func viewDidLoad() {
		super.viewDidLoad()
		setNavigationBar()
		setIndicator()
		setViewAesthetics()
		albumImageCollection.collectionViewLayout = setCollectionViewLayout() as UICollectionViewLayout
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		setDataSource()
		createSnapshot(images: albumImages)
		self.selectImageWithPicker()
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
	
	func setViewAesthetics(){
		shareButton.setTitle("", for: .normal)
	}
	
	func setIndicator(){
		activityIndicator.center = self.view.center
		self.view.addSubview(activityIndicator)
		activityIndicator.startAnimating()
	}
	
	func setCollectionViewLayout()->UICollectionViewCompositionalLayout{
		
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1), heightDimension: .fractionalWidth(1))
		let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(view.frame.width), heightDimension: .fractionalHeight(0.5))
		
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
		
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 4)
		group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
		
		let section = NSCollectionLayoutSection(group: group)
		let layout = UICollectionViewCompositionalLayout(section: section)
		
		return layout
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
		
		defer {
			activityIndicator.stopAnimating()
			self.shareButton.setTitle("Share to profile", for: .normal)
		}
		
		let imagePickerController = UIImagePickerController()
		imagePickerController.delegate = self
		
		
		if UIImagePickerController.isSourceTypeAvailable(.camera) && UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
			
			if imageArray.isEmpty {
				
				let photoOptions = PHFetchOptions()
				photoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
				
				let allPhotos = PHAsset.fetchAssets(with: photoOptions)
				let fetchOptions = PHImageRequestOptions()
				fetchOptions.deliveryMode = .highQualityFormat
				fetchOptions.resizeMode = .exact
				fetchOptions.normalizedCropRect = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width)
				fetchOptions.isSynchronous = true
				
				allPhotos.enumerateObjects { (assets, index, pointer) in
					
					DispatchQueue.global(qos: .background).sync {
						
						PHImageManager.default().requestImage(for: assets, targetSize: CGSize(width: self.view.frame.width, height: self.view.frame.height), contentMode: .aspectFit, options: fetchOptions) { (image, hashDictionary) in
							guard let image = image else {return}
							self.imageArray.append(image)
						}
					}
				}
				
				
				
				imageArray.forEach { image in
					albumImages.append(UserImages(images: image))
				}
				
				selectedImage.image = imageArray.first
				selectedImage.contentMode = .scaleAspectFill
			}
			
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

