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
import CoreData
import Combine

class UserProfileViewController: UIViewController {
	
	// MARK: Items Needed For CoreData
	
	private let applicationDelegate = UIApplication.shared.delegate as! AppDelegate
	
	private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	enum Sections {
		case main
	}
	
	//MARK: IBOutlets
	
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
	//	let coreDataModel = AuthenticationItems(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
	
	var datasource : UICollectionViewDiffableDataSource<Sections,AccountImages>!
	
	//MARK: Singletons
	var userData: UserProfile = UserProfile.shared()
	var userAuth = Auth.auth()
	let defaults = UserDefaults()
	
	var images : [AccountImages] = [] {
		didSet {
			postCountLabel.text = "\(images.count)"
			setSnapShot()
			saveItemsToCoreData()
		}
	}
	
	@Published var userProfileItems : [AccountImages] = []
	var dataSubscriber : AnyCancellable!
	
	//MARK: - App LifeCycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setDataSource()
		setSnapShot()
		setValuesFromUserDefaults()
		setAesthetics()
		uploadProfileImageToStorage(isRetrieve: true)
		getUserName()
		setNavigationBar()
		fetchDataFromCoreData()
		setSubscription()
		setCollectionViewLayout()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		setImageDataToView()
	}
	
	
	//MARK: View Aesthetics
	
	func setNavigationBar(){
		self.navigationItem.title = "Petstagram"
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Billabong", size: 34)!]
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.stack.3d.up"), style: .plain, target: self, action: #selector(temporaryMethodForLoggingOut))
		self.navigationController?.navigationBar.tintColor = .label
	}
	
	func setAesthetics(){
		userProfilePicture.layer.borderColor = UIColor.label.cgColor
		userProfilePicture.layer.borderWidth = 2
		userProfilePicture.layer.cornerRadius = 5
		userNameLabel.text = ""
		postCountLabel.text = ""
		aboutThePetLabel.text = "About \(defaults.object(forKey: Keys.userDefaultsDB.username) as? String ?? ""): Higgsboy has been with the family since a pup. He is now 6 years old. He enjoys long walks on the beach, and casual talks..."
		aboutTheOwnerLabel.text = "About Me: I am a retired Army Marine. Love animals, and I dont know what I would do without Higgsboy."
		
	}
	
	// MARK: Data Retrieval Methods
	
	func setValuesFromUserDefaults(){
		
		guard let profileImageData = defaults.data(forKey: Keys.userDefaultsDB.profilePhoto) else {return}
		guard let username = defaults.object(forKey: Keys.userDefaultsDB.username) as? String else {return}
		guard let profileImage = UIImage(data: profileImageData) else {return}
		self.userProfilePicture.image = profileImage
		self.userNameLabel.text = username
		
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
	
	/// This method waits until all images are loaded into memory before adding them to the userprofile collection.
	/// - Important: If the delay (debounce) is less than 1 seconds the app will crash because the data is collected in iterative loop **identifiers will not be unique!**
	func setSubscription(){
		dataSubscriber = $userProfileItems
			.eraseToAnyPublisher()
			.debounce(for: 1, scheduler: DispatchQueue.main)
			.sink { profileData in
				
				self.images = []
				
				profileData.forEach { item in
					
					self.images.append(AccountImages(image: item.image, timeStamp: item.timeStamp, metaData: item.metaData, id: item.id))
				}
		}
	}
	
	func setImageDataToView(){
		
		if let user = userAuth.currentUser?.uid {
			
			userData.downloadImages { (metaData) in
				metaData.forEach { mData in
					guard let fileName = mData.name else {return}
					guard let date = mData.timeCreated else {return}
					Storage.storage().reference().child(user).child(fileName).getData(maxSize: 99_999_999) { (data, error) in
						
						if let error = error {
							print(error.localizedDescription)
						}
						
						guard
							let data = data,
							let image = UIImage(data: data)
							else {return}
						
						if self.userProfileItems.contains(AccountImages(image: image, timeStamp: date, metaData: mData, id: fileName)) {
							
							self.userProfileItems.removeAll { item -> Bool in
								item.id == fileName || item.id == "profilePhoto"
							}
							if fileName != "profilePhoto" {
								self.userProfileItems.append(AccountImages(image: image, timeStamp: date, metaData: mData, id: fileName))
							}
						}else{
							
							if fileName != "profilePhoto" {
								self.userProfileItems.append(AccountImages(image: image, timeStamp: date, metaData: mData, id: fileName))
							}
						}
						self.sortPhotos()
					}
				}
			}
		}
	}
	
	func sortPhotos(){
		
		// Sort from newest to oldest
		userProfileItems.sort { (value1, value2) -> Bool in
			value1.timeStamp > value2.timeStamp
		}
	}
	
	func saveItemsToCoreData(){
		
		removeItemsFromCoreData()
		
		let limit = images.count > 9 ? 9 : images.count
		

			for i in 0..<limit {
				let imageCoreDataModel = ProfilePhotos(context: context)
				imageCoreDataModel.photoName = images[i].id
				imageCoreDataModel.date = images[i].timeStamp
				imageCoreDataModel.photo = images[i].image.pngData()

			}
		
		appDelegate.saveContext()
	}
	
	func fetchDataFromCoreData(){
		
		var userProfileCoreDataCollection : [ProfilePhotos] = []
		
		let request = NSFetchRequest<ProfilePhotos>(entityName: "ProfilePhotos")
		
		
		do {
			let object = try context.fetch(request)
			userProfileCoreDataCollection.append(contentsOf: object)
		}catch(let e){
			print(e.localizedDescription)
		}
		
		let value = userProfileCoreDataCollection.map { item -> AccountImages in
			
			guard let imageData = item.photo, let image = UIImage(data: imageData), let name = item.photoName, let date = item.date else  {fatalError()}
				
			return	AccountImages(image: image, timeStamp: date, metaData: nil, id: name)
				
		}
		
		images.append(contentsOf: value)
		
		images.sort { value1, value2 in
			value1.timeStamp > value2.timeStamp
		}
		
		userProfileCoreDataCollection.forEach { item in
//			print("Name: \(item.photoName ?? "No photo name!") | \(item.date!)")
		}
		
		// Remove items from coreData once they are retrieved.
		removeItemsFromCoreData()
		
	}
	
	func removeItemsFromCoreData(){
		
		let deleteRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "ProfilePhotos"))
		
		do{
			try context.execute(deleteRequest)
			appDelegate.saveContext()
		}catch(let e){
			print(e.localizedDescription)
		}
	}
	
	
	//MARK: IBActions
	
	@IBAction func editProfileTapped(_ sender: Any) {
		
	}
	
	//MARK: Navigation
	
	@objc func temporaryMethodForLoggingOut(){
		
		// Removes saved items from Userdefaults().
		defaults.removeObject(forKey: Keys.userDefaultsDB.profilePhoto)
		defaults.removeObject(forKey: Keys.userDefaultsDB.username)
		defaults.removeObject(forKey: Keys.keyChainKeys.email)
		
		// Removes all items from keychain.
		Authentication.removeCredsFromKeyChain()
		
		// Signs user out of Google FireStore Service.
		do {
			try Auth.auth().signOut()
		}catch(let error){
			print(error.localizedDescription)
		}
		
		// Returns user to login screen.
		performSegue(withIdentifier: Keys.Segues.signOut, sender: nil)
		
	}
}
