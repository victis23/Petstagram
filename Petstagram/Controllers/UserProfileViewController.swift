//
//  UserProfileViewController.swift
//  fakerGram
//
//  Created by Scott Leonard on 12/7/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth // Imported for signout method only.
import CoreData
import Combine

/// Class which controls data displayed on the user's home profile tab.
class UserProfileViewController: UIViewController {

	//MARK: IBOutlets
	
	@IBOutlet weak var accountImages: UICollectionView!
	@IBOutlet weak var userProfilePicture : UIImageView!
	@IBOutlet weak var userNameLabel : UILabel!
	@IBOutlet weak var postCountLabel : UILabel!
	@IBOutlet weak var followerCountLabel : UILabel!
	@IBOutlet weak var followingCountLabel : UILabel!
	@IBOutlet weak var editProfileInfoButton : UIButton!
	@IBOutlet weak var aboutThePetLabel: UILabel!
	
	
	//MARK: CoreData Requiered Properties
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	// Source of truth for our collection view
	var datasource : UICollectionViewDiffableDataSource<Sections,AccountImages>!
	
	//MARK: Singletons
	var userData: UserProfile = UserProfile.shared()
	let defaults = UserDefaults()
	let descriptionRetriever = DescriptionRetriever(userID: UserProfile.shared().user!)
	
	//Main collection type property for our data.
	var images : [AccountImages] = [] {
		didSet {
			postCountLabel.text = "\(images.count)"
			setSnapShot()
			saveItemsToCoreData()
		}
	}
	
	var profileDescriptionViewObject : EditProfileDescription!
	
	//MARK: Combine Subscribers & Publishers
	
	@Published var userProfileItems : [AccountImages] = []
	var dataSubscriber : AnyCancellable!
	
	@Published var isEditingProfileDetails : Bool = false
	var isEditingDetails : AnyPublisher<Bool,Never>!
	var isEditProfileSubscriber : AnyCancellable!
	
	//MARK: - App LifeCycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setDataSource()
		accountImages.delegate = self
		setValuesFromUserDefaults()
		setAesthetics()
		uploadProfileImageToStorage(isRetrieve: true)
		getUserName()
		setNavigationBar()
		fetchDataFromCoreData()
		setImageCount()
		setSubscription()
		disableParentView(isDisabled: isEditingProfileDetails)
		setDisableSubsciber()
		setCollectionViewLayout()
		getFollowerAndFriendCount()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		setImageDataToView()
		setSnapShot()
	}
	
	
	//MARK: View Aesthetics
	
	/// Sets the default appearance of the navigationbar along with bar button functionality.
	func setNavigationBar(){
		self.navigationItem.title = "Petstagram"
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Billabong", size: 34)!]
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.stack.3d.up"), style: .plain, target: self, action: #selector(temporaryMethodForLoggingOut))
		self.navigationController?.navigationBar.tintColor = .label
	}
	
	func setImageCount(){
		
		postCountLabel.text = "\(defaults.integer(forKey: Keys.userDefaultsDB.imageCount))"
	}
	
	
	
	///Sets the appearance of userfacing views.
	func setAesthetics(){
		
		editProfileInfoButton.layer.cornerRadius = 5
		userProfilePicture.layer.borderColor = UIColor.label.cgColor
		userProfilePicture.layer.borderWidth = 2
		userProfilePicture.layer.cornerRadius = 5
		userNameLabel.text = ""
		postCountLabel.text = ""
		getAccountDescription()
		
	}
	
	/// Provides user with tactile feedback when a choice is made.
	func hapticFeedback(){
		let feedback = UIImpactFeedbackGenerator(style: .medium)
		feedback.prepare()
		feedback.impactOccurred()
	}
	
	// MARK: Data Retrieval Methods
	
	/// Retrieves defaults for the user's profile such as the profile photograph and the account username.
	func setValuesFromUserDefaults(){
		
		guard let profileImageData = defaults.data(forKey: Keys.userDefaultsDB.profilePhoto) else {return}
		guard let username = defaults.object(forKey: Keys.userDefaultsDB.username) as? String else {return}
		guard let profileImage = UIImage(data: profileImageData) else {return}
		
		self.userProfilePicture.image = profileImage
		
		self.userNameLabel.text = username
	}
	
	///Retrieves username from firestore database. Refreshes currently displayed username upon `ViewDidLoad()`.
	/// - NOTE: This is also the method that writes the username to the UserDefaults.
	func getUserName(){
		
		descriptionRetriever.getUserName { (username) in
			self.userNameLabel.text = username
			
			self.userNameLabel.font = UIFont.monospacedSystemFont(ofSize: 30, weight: .heavy)
		}
	}
	
	/// Gets details for user's followers and friends...
	func getFollowerAndFriendCount(){
		
		guard let user = userData.user else {return}
		
		FollowerTracker.getFriendCount(user: user, completion: { count in
			self.followingCountLabel.text = "\(count)"
		})
		
		FollowerTracker.getFollowerCount(user: user, completion: { count in
			self.followerCountLabel.text = "\(count)"
		})
	}
	
	/// This method waits until all images are loaded into memory before adding them to the userprofile collection.
	/// - Important: If the delay (debounce) is less than 1 seconds the app will crash because the data is collected in iterative loop **identifiers will not be unique!**
	func setSubscription(){
		dataSubscriber = $userProfileItems
			.eraseToAnyPublisher()
			.debounce(for: 1, scheduler: DispatchQueue.main)
			.sink { profileData in
				
				profileData.forEach { item in
					
					// Checks if object with given id property exists in data collection.
					let contains = self.images.contains { element in
						element.id == item.id
					}
					
					// If result of object check comes back false, append new object with values.
					if !contains {
						if let user = self.userData.user {
							self.images.append(AccountImages(account: user, image: item.image, timeStamp: item.timeStamp, metaData: item.metaData, id: item.id))
							self.sort()
						}
						
						self.images.removeAll(where: { account in
							account.id == Keys.GoogleStorage.profilePhoto
						})
					}
					
				}
				self.defaults.set(self.images.count, forKey: Keys.userDefaultsDB.imageCount)
		}
	}
	
	
	/// Downloads imageData from storage bucket and creates an `AccountImages` object which is appended to `userProfileItems` array.
	/// - Note: `UserProfileItems` is observed by a publisher.
	func setImageDataToView(){
		
		if let user = userData.user {
			
			let imageDownloader = ImageDownloader(account: user)
			
			imageDownloader.downloadImages(downloadedImages: { metaData in
				
				guard let fileName = metaData.name else {return}
				guard let date = metaData.timeCreated else {return}
				guard fileName != Keys.GoogleStorage.profilePhoto else {return}
				
				imageDownloader.downloadImages(for: fileName, imageItem: { image in
					
					self.userProfileItems.append(AccountImages(account: user, image: image, timeStamp: date, metaData: metaData, id: fileName))
				})
			})
		}
	}
	
	/// Sorts the objects in the collection by their metadata timestamp.

	func sort(){
		images.sort { value1, value2 -> Bool in
			value1.timeStamp > value2.timeStamp
		}
	}
	
	/// Saves the last 9 `AccountImage` Objects to coreData for fast loading upon `viewDidLoad`.
	func saveItemsToCoreData(){
		
		// Erases all objects from our persistent data container.
		removeItemsFromCoreData()
		
		// If count is less than 9 display objects corresponding to current count; otherwise only show the last 9 items in the array.
		let limit = images.count > 9 ? 9 : images.count
		
		//Based on the set limit add corresponding elements to coredata.
		for i in 0..<limit {
			let imageCoreDataModel = ProfilePhotos(context: context)
			imageCoreDataModel.photoName = images[i].id
			imageCoreDataModel.date = images[i].timeStamp
			imageCoreDataModel.photo = images[i].image.pngData()
			
		}
		
		appDelegate.saveContext()
	}
	
	/// Fetches saved items from coredata.
	/// - NOTE: This method is called upon `viewDidLoad`.
	func fetchDataFromCoreData(){
		
		var userProfileCoreDataCollection : [ProfilePhotos] = []
		
		let request = NSFetchRequest<ProfilePhotos>(entityName: "ProfilePhotos")
		
		// Sort from latest item to oldest.
		let sort = NSSortDescriptor(key: "date", ascending: false)
		request.sortDescriptors = [sort]
		
		do {
			let object = try context.fetch(request)
			userProfileCoreDataCollection.append(contentsOf: object)
		}catch(let e){
			print(e.localizedDescription)
		}
		
		// Map each element in the data collection retrieved into a new AccountImages Object with a nil metaData property.
		let value = userProfileCoreDataCollection.map { item -> AccountImages in
			
			guard let imageData = item.photo, let image = UIImage(data: imageData), let name = item.photoName, let date = item.date, let user = userData.user else  {fatalError()}
			
			return	AccountImages(account: user, image: image, timeStamp: date, metaData: nil, id: name)
			
		}
		
		images.append(contentsOf: value)
		
		// Remove items from coreData once they are retrieved.
		removeItemsFromCoreData()
	}
	
	/// Scrolls collectionView back to the first item in the collection.
	func returnToFirstItemInCollection(){
		
		guard !images.isEmpty else {return}
		
		if let indexPath = datasource.indexPath(for: images[0]) {
			
			accountImages.scrollToItem(at: indexPath, at: .top, animated: false)
		}
	}
	
	/// Remove items stored in our persistant container.
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
	
	// When tapped presents a UIView users can use to update the description label on their profiles.
	@IBAction func editProfileTapped(_ sender: Any) {
		
		hapticFeedback()
		
		let swipeToDismiss = UIPanGestureRecognizer(target: self, action: #selector(swipeToDismiss(_:)))
	
		guard let editView = createEditProfileDescriptionView() else {return}
		
		// Pass reference to editView
		profileDescriptionViewObject = editView
		
		editView.addGestureRecognizer(swipeToDismiss)
		
		view.addSubview(editView)
		
		disableParentView(isDisabled: true)
		
		editViewAnimations(subView: editView)
		
	}
	
	//MARK: Navigation
	
	/// Temporary Method that will be migrated somewhere else eventually.
	@objc func temporaryMethodForLoggingOut(){
		
		// Removes saved items from Userdefaults().
		defaults.removeObject(forKey: Keys.userDefaultsDB.profilePhoto)
		defaults.removeObject(forKey: Keys.userDefaultsDB.username)
		defaults.removeObject(forKey: Keys.keyChainKeys.email)
		defaults.removeObject(forKey: Keys.userDefaultsDB.imageCount)
		
		// Removes all items from keychain.
		Authentication.removeCredsFromKeyChain()
		
		// Signs user out of Google FireStore Service.
		do {
			try Auth.auth().signOut()
		}catch(let error){
			print(error.localizedDescription)
		}
		
		// Erase data stored in coreData.
		removeItemsFromCoreData()
		
		// Returns user to login screen.
		performSegue(withIdentifier: Keys.Segues.signOut, sender: nil)
		
	}
}
