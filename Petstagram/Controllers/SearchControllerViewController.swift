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
	
	// Stored Properties for Google Firebase Authorization & Database.
	var firebaseAuthorization = Auth.auth()
	var db = Firestore.firestore()
	
	
	@Published var searchTerm : String?
	var searchTermSubscriber : AnyCancellable!
	
	var results : [String] = []
	
	//MARK: State
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setNavigationBar()
		setSearchBarDelegate()
		setSubscription()
	}
	
	func setSearchBarDelegate(){
		searchBar.delegate = self
	}
	
	func setNavigationBar(){
		self.navigationItem.title = "Petstagram"
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Billabong", size: 34)!]
		self.navigationController?.navigationBar.tintColor = .label
	}
	
	func setSubscription(){
		searchTermSubscriber = $searchTerm
		.eraseToAnyPublisher()
			.debounce(for: 2, scheduler: DispatchQueue.global(qos: .background), options: nil)
		.removeDuplicates()
			.sink { searchValue in
				self.searchFireBaseDataBaseForUser(searchValue: searchValue)
		}
	}
	
	func searchFireBaseDataBaseForUser(searchValue: String?){
		guard let searchValue = searchValue?.lowercased() else {return}
//		guard let user = firebaseAuthorization.currentUser?.uid else {return}
		
		db.collection(Keys.GoogleFireStore.userCollection).document(Keys.GoogleFireStore.userKeysDocument).getDocument { (document, error) in
			if let error = error {
				print(error.localizedDescription)
			}
			if let document = document {
				let profileID = document[searchValue] as? String
				print(profileID ?? "None")
			}
		}
	}
}

extension SearchControllerViewController : UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
		searchTerm = searchText
	}
}
