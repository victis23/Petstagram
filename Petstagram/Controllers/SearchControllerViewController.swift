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
	
	var firebaseAuthorization = Auth.auth()
	var db = Firestore.firestore()
	
	@Published var searchTerm : String?
	
	var results : [String] = []
	
	//MARK: State
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setNavigationBar()
	}
	
	func setNavigationBar(){
		self.navigationItem.title = "Petstagram"
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Billabong", size: 34)!]
		self.navigationController?.navigationBar.tintColor = .label
	}
	
}

extension SearchControllerViewController : UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
		searchTerm = searchText
	}
}
