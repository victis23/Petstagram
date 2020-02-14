//
//  SearchControllerViewController.swift
//  fakerGram
//
//  Created by Scott Leonard on 12/7/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import Combine

/// Class allows user to search for other Petstagram Users.
class SearchControllerViewController: UIViewController {
	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	
	// Stored Properties for Google Firebase Authorization & Database.
	var firebaseAuthorization = Auth.auth()
	var db = Firestore.firestore()
	var fbStorage = Storage.storage()
	
	//MARK: Combine Subscribers & Publishers
	
	@Published var searchTerm : String?
	var searchTermSubscriber : AnyCancellable!
	
	var dataSource : UITableViewDiffableDataSource<Section,PetstagramUsers>!
	
	var results : [String] = []
	var userList : [PetstagramUsers] = []
	
	//MARK: State
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setNavigationBar()
		setSearchBarDelegate()
		setSubscription()
		setDataSource()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		tableView.delegate = self
		setSnapShot(users: userList)
	}
	
	//MARK: Methods
	
	/// Set search bar delegate to this controller.
	func setSearchBarDelegate(){
		searchBar.delegate = self
	}
	
	/// Sets up general navigation controller.
	func setNavigationBar(){
		self.navigationItem.title = "Petstagram"
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Billabong", size: 34)!]
		self.navigationController?.navigationBar.tintColor = .label
	}
	
	//MARK: Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == Keys.Segues.otherUsers {
			
			//Changes text that will be displayed on the back button.
			navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
		}
	}
}

//MARK: - Search Bar

/// Extension handles searchbar functions.
extension SearchControllerViewController : UISearchBarDelegate {
	
	/// Assigns user search input to publisher.
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
		// passes search term entered by user to publisher.
		searchTerm = searchText
	}
	
	/// Sets publisher to subscriber
	/// - Note:
	///		- Identical queries are removed.
	///		- 2 second delay implimented inorder to avoid over querying database.
	func setSubscription(){
		searchTermSubscriber = $searchTerm
			.eraseToAnyPublisher()
			.debounce(for: 2, scheduler: DispatchQueue.global(qos: .background), options: nil)
			.removeDuplicates()
			.sink { searchValue in
				self.searchFireBaseDataBaseForUser(searchValue: searchValue)
		}
	}
	
	/// Hits GoogleFireBase for dictionary that contains username:uid key/value pair.
	func searchFireBaseDataBaseForUser(searchValue: String?){
		
		// Transform user search term to lowercased string.
		guard let searchValue = searchValue?.lowercased() else {return}
		
		// Retrieve dictionary containing list of application users from server.
		db.collection(Keys.GoogleFireStore.userCollection).document(Keys.GoogleFireStore.userKeysDocument).getDocument { (document, error) in
			
			if let error = error {
				print(error.localizedDescription)
			}
			
			if let document = document {
				
				// Convert document to dictionary.
				guard let documentDictionary = document.data() else {return}
				
				// Convert key/value pair to PetstagramUser object.
				// If dictionary contains a key that partically matches search term it is returned to user.
				let results = documentDictionary.compactMap({ key, value -> PetstagramUsers? in
					let value = value as! String
					
					if key.contains(searchValue){
						return PetstagramUsers(key, value)
					}
					return nil
				})
				
				// Updates source of truth for tableview with new results data.
				self.setSnapShot(users: results)
			}
		}
	}
	
	
	/// Searches online storage for profile photo that cooresponds to the provided Uid.
	/// - Parameters:
	///   - user: Uid that corresponds to queried account.
	///   - profileImage: Captures Image returned from GoogleFirebase Storage.
	func getProfilePhoto(user: String, profileImage : @escaping (UIImage)->Void) {
		
		fbStorage.reference().child(user).child("profilePhoto").getData(maxSize: 99_999_999) { (data, error) in
			
			if let error = error {
				print(error.localizedDescription)
			}
			
			guard let data = data, let image = UIImage(data: data) else {return}
			profileImage(image)
		}
	}
}


