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
import CoreData
import Combine

class UserProfileViewController: UIViewController {
	
	// MARK: Items Needed For CoreData
	
	private let applicationDelegate = UIApplication.shared.delegate as! AppDelegate
	
	private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	lazy var imagesCoreDataModel = ProfilePhotos(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
	
	
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
	
	//MARK: - App LifeCycle
	
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
	
	func setSubscription(){
		dataSubscriber = $userProfileItems
			.eraseToAnyPublisher()
			.debounce(for: 2, scheduler: DispatchQueue.main)
			.sink { profileData in
				
				profileData.forEach { item in
					
					self.images.append(UserProfileImageCollection(image: item.image, id: item.id))
				}
		}
	}
	
	func setImageDataToView(){
		
		self.images = []
		
		userData.downloadImages(downloadedImages: { imageIDKeys, metaData   in
			
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
