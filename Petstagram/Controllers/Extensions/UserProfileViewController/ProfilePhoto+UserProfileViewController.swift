//
//  ProfilePicture.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/11/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit
import FirebaseStorage

/// Extension that handles image picking from user album.
extension UserProfileViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	
	/// Presents alert controller that provides two options to users.
	/// - Camera : Allows user to utilize device camera to create profile photo.
	/// - Photo Album : Presents Album list for user to select image for profile photo.
	@IBAction func tappedProfileImage(sender : UIButton) {
		
		hapticFeedback()
		
		let imageController = UIImagePickerController()
		imageController.delegate = self
		
		let alertController = UIAlertController(title: "Media Source", message: "Where would you like to get your profile picture from?", preferredStyle: .actionSheet)
		
		let cameraOption = UIAlertAction(title: "Camera", style: .default, handler: { alert in
			imageController.sourceType = .camera
			imageController.allowsEditing = true
			imageController.showsCameraControls = true
			self.present(imageController, animated: true)
		})
		
		let photoAlbumOption = UIAlertAction(title: "Photo Album", style: .default, handler: { alert in
			imageController.sourceType = .photoLibrary
			imageController.allowsEditing = true
			self.present(imageController, animated: true)
		})
		
		let cancelOption = UIAlertAction(title: "Cancel", style: .cancel, handler: { alert in
			
		})
		
		if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
			alertController.addAction(photoAlbumOption)
		}
		
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			alertController.addAction(cameraOption)
		}
		
		alertController.addAction(cancelOption)
		
		present(alertController, animated: true)
	}
	
	/// Sets image selected by user to ImageView that displays the profile image.
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		guard let selectedImage = info[.editedImage] as? UIImage else {return}
		
		userProfilePicture.image = selectedImage
		userProfilePicture.contentMode = .scaleAspectFill
		userProfilePicture.clipsToBounds = true
		
		// Call to method that uploads images to Google Firebase Storage.
		self.uploadProfileImageToStorage(isRetrieve: false)
		
		// Dismiss the image selector.
		dismiss(animated: true)
		
	}
	
	/// Manages upload & download of image data from Google FireStore Storage.
	/// - Important: `isRetrieve`
	/// 	- false: writes
	/// 	- true : reads
	/// 	- both: set profile image value in `UserDefaults` (double write)
	/// - Note: 12.5 mb Limit on image downloads.
	func uploadProfileImageToStorage(isRetrieve: Bool) {
		
		guard let user = userData.user else {return}
		let storage = Storage.storage().reference().child(user).child(Keys.userDefaultsDB.profilePhoto)
		
		switch isRetrieve {
		case false :
			guard let image = userProfilePicture.image?.pngData() else {return}
			defaults.set(image, forKey: Keys.userDefaultsDB.profilePhoto)
			storage.putData(image)
		case true :
			storage.getData(maxSize: 99_999_999) { (data, error) in
				if let error = error {
					print(error.localizedDescription)
					return
				}
				if let data = data {
					guard let image = UIImage(data: data) else {return}
					self.defaults.set(data, forKey: Keys.userDefaultsDB.profilePhoto)
					self.userProfilePicture.image = image
				}
			}
		}
	}
}
