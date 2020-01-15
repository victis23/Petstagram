//
//  ImageSelectorExtension+ImageUploadViewController.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/14/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit
import Photos

extension ImageUploadViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	
	func selectImageWithPicker(isCameraImage: Bool = false){
		
		defer {
			shareView.isHidden = false
			setViewAesthetics()
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
				
				let imageSize : CGSize = CGSize(width: view.frame.width, height: view.frame.height)
				
				allPhotos.enumerateObjects { (assets, index, pointer) in
					
					DispatchQueue.global(qos: .background).sync {
						
						PHImageManager.default().requestImage(for: assets, targetSize: imageSize, contentMode: .aspectFit, options: fetchOptions) { (image, hashDictionary) in
							guard let image = image else {return}
							self.imageArray.append(image)
						}
					}
				}
				
				
				
				imageArray.forEach { image in
					albumImages.append(ImageAlbum(images: image))
				}
				
				selectedImage.image = imageArray.first
				selectedImage.contentMode = .scaleAspectFill
			}
			
			if isCameraImage {
				imagePickerController.sourceType = .camera
				imagePickerController.cameraCaptureMode = .photo
				imagePickerController.showsCameraControls = true
				imagePickerController.allowsEditing = true
				present(imagePickerController, animated: true)
			}
		}
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		guard let rectangleImage = info[.editedImage] as? UIImage else {return}
		
		selectedImage.image = rectangleImage
		selectedImage.contentMode = .scaleAspectFill
		albumImages.append(ImageAlbum(images: rectangleImage))
		dismiss(animated: true, completion: {})
		
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		selectedImage.image = datasource.itemIdentifier(for: indexPath)?.images
	}
	
	
}


