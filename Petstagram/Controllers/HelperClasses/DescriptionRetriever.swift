//
//  DescriptionRetriever.swift
//  Petstagram
//
//  Created by Scott Leonard on 2/15/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage


protocol DataBaseTestProtocol {
	associatedtype Type1
	associatedtype Type2
	
	func collection(_ collectionPath: String) -> Type1
	func document(_ documentPath: String) -> Type2
}

class StorageMock : DataBaseTestProtocol {
	
	typealias Type1 = Mock
	typealias Type2 = Mock
	
	func collection(_ collectionPath: String) -> Mock {
		Mock(collectionPath)
	}
	
	func document(_ documentPath: String) -> Mock {
		Mock(documentPath)
	}
	
	struct Mock {
		
		var storageMock : StorageMock?
		var path : String
		
		init(_ path: String){
			self.path = path
		}
		
		func getDocument(completion : @escaping (_ path:String)->Void){
			completion(self.path)
		}
	}
}

extension Firestore : DataBaseTestProtocol {
	
	typealias Type1 = CollectionReference
	
	typealias Type2 = DocumentReference
	
}

protocol TestWrapper {}

class MockDatabaseClass<T> : TestWrapper where T : DataBaseTestProtocol {
	
	var db : T
	
	init?(db : T){
		self.db = db
	}
	
	func mockDataBase() -> some DataBaseTestProtocol {
		let database = db
		return database
	}
}


/// Handles retrieving information about queried users such as username, profile image, and description. 
class DescriptionRetriever {
	
	private let test : DescriptionTestProtocol!
	
	private let db : TestWrapper! //= Firestore.firestore()
	private let storage = Storage.storage()
	private var userID : String
	
	/// Returns instance of `TestDescriptionRetrieverCall` that initialized the Class when used for testing.
	func returnTestProperty() -> DescriptionTestProtocol {
		return test
	}
	
	func getDescription(completion : @escaping (String?)->Void) {
		
		guard let db = db as? MockDatabaseClass<Firestore> else {
			
			let db = self.db as? MockDatabaseClass<StorageMock>
			let database = db?.mockDataBase() as? StorageMock
			database?.collection("Test String").getDocument(completion: { value in
				completion(value)
			})
			
			return
		}
		
		guard let database = db.mockDataBase() as? Firestore else {return}
		
		let query = database.collection(self.userID).document(Keys.GoogleFireStore.accountInfoDocument)
		
		// Call is used only for testing.
		self.test?.execute(query: query)
		
		query.getDocument { (document, error) in
			
			guard error == nil else {
				guard let error = error else {return}
				print(error.localizedDescription)
				return
			}
			
			guard let document = document else {return}
			let description = document["ProfileDescription"] as? String
			completion(description)
		}
	}
	
	/// Retrieves username for queried account ID and sets value for username key in userdefaults.
	/// - Note: Closure captures retrieved username.
	func getUserName(completion: @escaping (String)->Void){
		
		let defaults = UserDefaults()
		
		guard let db = db as? MockDatabaseClass<Firestore>,
			let database = db.mockDataBase() as?  Firestore
			else {return}
		
		let query = database.collection(userID).document(Keys.GoogleFireStore.accountInfoDocument)
		
		// Call is used only for testing.
		self.test?.execute(query: query)
		
		query.getDocument { (usernameDocument, error) in
			if let error = error {
				print(error.localizedDescription)
			}
			guard
				let usernameDocument = usernameDocument,
				let retrievedUserName = usernameDocument[Keys.GoogleFireStore.usernameKey] as? String
				else {fatalError()}
			
			defaults.set(retrievedUserName, forKey: Keys.userDefaultsDB.username)
			
			completion(retrievedUserName)
		}
	}
	
	/// Searches online storage for profile photo that cooresponds to the provided Uid.
	/// - Parameters:
	///   - completion: Captures Image returned from GoogleFirebase Storage.
	func getProfilePhoto( completion : @escaping (UIImage)->Void) {
		
		let query = storage.reference().child(userID).child("profilePhoto")
		
		// Call is used only for testing.
		self.test?.execute(query: query)
		
		query.getData(maxSize: 99_999_999) { (data, error) in
			
			if let error = error {
				print(error.localizedDescription)
			}
			
			guard let data = data, let image = UIImage(data: data) else {return}
			completion(image)
		}
	}
	
	/// Designated Initializer used primarily for testing.
	init(userID:String, test : DescriptionTestProtocol?, db : TestWrapper?){
		self.userID = userID
		self.test = test
		self.db = db
	}
	
	/// Initalizer that will be used throughout the app to retrieve description information.
	convenience init(userID:String) {
		
		let test : DescriptionTestProtocol? = nil
		let provider = MockDatabaseClass(db: Firestore.firestore())
		self.init(userID:userID, test: test, db: provider)
	}
}
