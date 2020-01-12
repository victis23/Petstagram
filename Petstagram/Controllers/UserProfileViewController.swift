//
//  UserProfileViewController.swift
//  fakerGram
//
//  Created by Scott Leonard on 12/7/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Combine

class UserProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	
	enum Sections {
		case main
	}
	
	@IBOutlet weak var accountImages: UICollectionView!
	@IBOutlet weak var userProfilePicture : UIImageView!
	@IBOutlet weak var userNameLabel : UILabel!
	@IBOutlet weak var postCountLabel : UILabel!
	@IBOutlet weak var followerCountLabel : UILabel!
	@IBOutlet weak var followingCountLabel : UILabel!
	@IBOutlet weak var editProfileInfoButton : UIButton!
	@IBOutlet weak var aboutThePetLabel: UILabel!
	@IBOutlet weak var aboutTheOwnerLabel: UILabel!
	
	
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	let coreDataModel = AuthenticationItems(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
	
	var datasource : UICollectionViewDiffableDataSource<Sections,UserProfileImageCollection>!
	
	//MARK: Singletons
	var userData: UserProfile = UserProfile.shared()
	var userAuth = Auth.auth()
	let defaults = UserDefaults()
	
	var images : [UserProfileImageCollection] = [] {
		didSet {
			postCountLabel.text = "\(images.count)"
			setSnapShot()
		}
	}
	
	@Published var userProfileItems : [UserProfileImageCollection] = []
	var dataSubscriber : AnyCancellable!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setValuesFromUserDefaults()
		setAesthetics()
		uploadProfileImageToStorage(isRetrieve: true)
		getUserName()
		setNavigationBar()
		setDataSource()
		setSnapShot()
		setSubscription()
		setCollectionViewLayout()
	}
	
	func setValuesFromUserDefaults(){
		
		guard let profileImageData = defaults.data(forKey: Keys.userDefaultsDB.profilePhoto) else {return}
		guard let username = defaults.object(forKey: Keys.userDefaultsDB.username) as? String else {return}
		guard let profileImage = UIImage(data: profileImageData) else {return}
		self.userProfilePicture.image = profileImage
		self.userNameLabel.text = username
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		setImageDataToView()
	}
	
	
	@IBAction func editProfileTapped(_ sender: Any) {
		
	}
	
	@IBAction func tappedProfileImage(sender : UIButton) {
		
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
	
	func setAesthetics(){
		userProfilePicture.layer.borderColor = UIColor.label.cgColor
		userProfilePicture.layer.borderWidth = 2
		userProfilePicture.layer.cornerRadius = 5
		userNameLabel.text = ""
		postCountLabel.text = ""
		aboutThePetLabel.text = "About \(defaults.object(forKey: Keys.userDefaultsDB.username) as! String): This is where the user tells us about their pet."
		aboutTheOwnerLabel.text = "About Me: This is where the user tells us about themself."
		
	}
	
	func getUserName(){
		
		let db = Firestore.firestore()
		guard let user = userAuth.currentUser?.uid else {fatalError()}
		
		db.collection(user).document(Keys.GoogleFireStore.accountInfoDocument).getDocument { (usernameDocument, error) in
			if let error = error {
				print(error.localizedDescription)
			}
			guard let usernameDocument = usernameDocument else {fatalError()}
			guard let retrievedUserName = usernameDocument[Keys.GoogleFireStore.usernameKey] as? String else {fatalError()}
			self.userNameLabel.text = retrievedUserName
			self.defaults.set(retrievedUserName, forKey: Keys.userDefaultsDB.username)
		}
		userNameLabel.font = UIFont.monospacedSystemFont(ofSize: 30, weight: .heavy)
	}
	
	func setSubscription(){
		dataSubscriber = $userProfileItems
			.eraseToAnyPublisher()
			.debounce(for: 2, scheduler: DispatchQueue.main)
			.sink { profileData in
				profileData.forEach { item in
					print("Image Pointer \(item.image) | id \(item.id)")
					self.images.append(UserProfileImageCollection(image: item.image, id: item.id))
				}
		}
	}
	
	func setImageDataToView(){
		
		self.images = []
		
		userData.downloadImages(downloadedImages: { imageIDKeys  in
			
			imageIDKeys.forEach { value in
				if self.userProfileItems.contains(UserProfileImageCollection(image: value.value, id: value.key)) {
					self.userProfileItems.removeAll { item -> Bool in
						item.id == value.key || item.id == "profilePhoto"
					}
					if value.key != "profilePhoto" {
						self.userProfileItems.append(UserProfileImageCollection(image: value.value, id: value.key))
					}
				}else{
					if value.key != "profilePhoto" {
						self.userProfileItems.append(UserProfileImageCollection(image: value.value, id: value.key))
					}
				}
			}
		})
	}
	
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
	
	func setNavigationBar(){
		self.navigationItem.title = "Petstagram"
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Billabong", size: 34)!]
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.stack.3d.up"), style: .plain, target: self, action: #selector(temporaryMethodForLoggingOut))
		self.navigationController?.navigationBar.tintColor = .label
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
	
	
	
	@objc func temporaryMethodForLoggingOut(){
		
		coreDataModel.coreDataEmail = nil
		coreDataModel.coreDataPassword = nil
		coreDataModel.coreDataCredential = nil
		coreDataModel.coreDataUserName = nil
		
		appDelegate.saveContext()
		
		defaults.removeObject(forKey: Keys.userDefaultsDB.profilePhoto)
		defaults.removeObject(forKey: Keys.userDefaultsDB.username)
		
		do {
			try Auth.auth().signOut()
		}catch(let error){
			print(error.localizedDescription)
		}
		
		performSegue(withIdentifier: Keys.Segues.signOut, sender: nil)
		
	}
}

extension UserProfileViewController {
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		guard let selectedImage = info[.editedImage] as? UIImage else {return}
		
		userProfilePicture.image = selectedImage
		userProfilePicture.contentMode = .scaleAspectFill
		userProfilePicture.clipsToBounds = true
		self.uploadProfileImageToStorage(isRetrieve: false)
		dismiss(animated: true)
		
	}
	
	func uploadProfileImageToStorage(isRetrieve: Bool) {
		
		guard let user = userAuth.currentUser?.uid else {return}
		let storage = Storage.storage().reference().child(user).child(Keys.userDefaultsDB.profilePhoto)
		
		switch isRetrieve {
		case false :
			guard let image = userProfilePicture.image?.pngData() else {return}
			defaults.set(image, forKey: Keys.userDefaultsDB.profilePhoto)
			storage.putData(image)
		default:
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
