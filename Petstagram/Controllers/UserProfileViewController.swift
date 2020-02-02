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

/// Class which controls data displayed on the user's home profile tab.
class UserProfileViewController: UIViewController {
	
	
	// Sections Enum that will be used in the collectionView's DataSource.
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
	
	
	//MARK: CoreData Requiered Properties
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	// Source of truth for our collection view
	var datasource : UICollectionViewDiffableDataSource<Sections,AccountImages>!
	
	//MARK: Singletons
	var userData: UserProfile = UserProfile.shared()
	var userAuth = Auth.auth()
	let defaults = UserDefaults()
	
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
		setSnapShot()
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
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		setImageDataToView()
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
				
				profileData.forEach { item in
					
					// Checks if object with given id property exists in data collection.
					let contains = self.images.contains { element in
						element.id == item.id
					}
					
					// If result of object check comes back false, append new object with values.
					if !contains {
						self.images.append(AccountImages(image: item.image, timeStamp: item.timeStamp, metaData: item.metaData, id: item.id))
						self.sort()
					}
					
				}
				self.defaults.set(self.images.count, forKey: Keys.userDefaultsDB.imageCount)
		}
	}
	
	//FIXME: This method removes items from collection for no reason.
	/// Downloads imageData from storage bucket and creates an `AccountImages` object which is appended to `userProfileItems` array.
	/// - Note: `UserProfileItems` is observed by a publisher.
	func setImageDataToView(){
		
		if let user = userAuth.currentUser?.uid {
			
			userData.downloadImages { (metaData) in
				
				guard let fileName = metaData.name else {return}
				guard let date = metaData.timeCreated else {return}
				
				Storage.storage().reference().child(user).child(fileName).getData(maxSize: 99_999_999) { (data, error) in
					
					if let error = error {
						print(error.localizedDescription)
					}
					
					guard
					let data = data,
					let image = UIImage(data: data)
						else {return}
					
					self.userProfileItems.append(AccountImages(image: image, timeStamp: date, metaData: metaData, id: fileName))
				}
			}
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
			
			guard let imageData = item.photo, let image = UIImage(data: imageData), let name = item.photoName, let date = item.date else  {fatalError()}
			
			return	AccountImages(image: image, timeStamp: date, metaData: nil, id: name)
			
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

/// Sets Publisher and Subscriber that controls when the parent view is disabled.
extension UserProfileViewController {
	
	/// Method sets subscribers for view.
	/// - NOTE: Controls whether user can interact with collectionview and edit profile button while profile editing dialog box is presented.
	func setDisableSubsciber(){
		
		isEditProfileSubscriber = isEditingDetails
			.assign(to: \UIButton.isEnabled, on: editProfileInfoButton)

		isEditProfileSubscriber = isEditingDetails
			.assign(to: \UICollectionView.isUserInteractionEnabled, on: accountImages)
	}
	
	/// Sets value recieved by publisher when user taps on the edit profile button.
	/// - Note: Changes opacity of Edit Button and CollectionView.
	func disableParentView(isDisabled:Bool){
		
		let views :[UIView] = [editProfileInfoButton,accountImages,aboutThePetLabel]
		
		isEditingProfileDetails = isDisabled
		
		isEditingDetails = $isEditingProfileDetails
			.map({ bool -> Bool in
				// You are IN Edit mode. View Enabled = False
				if bool == true {
					self.changeViewOpacity(with: views, alphaIsNotLowered: bool)
					return false
				}
				// Default: You are NOT in edit mode. View Enabled = True
				self.changeViewOpacity(with: views, alphaIsNotLowered: bool)
				return true
			})
			.eraseToAnyPublisher()
	}
	
	func changeViewOpacity(with uiViews : [UIView], alphaIsNotLowered:Bool){
		
		var alpha : CGFloat = 1.0
		
		// The view opacity is not lowered.
		if alphaIsNotLowered {
			alpha = 0.2
		}
		
		uiViews.forEach { view in
			view.alpha = alpha
		}
	}
}
