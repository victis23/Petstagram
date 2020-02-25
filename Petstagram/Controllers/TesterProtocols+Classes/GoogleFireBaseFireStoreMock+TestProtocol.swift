//
//  GoogleFireBaseFireStoreMock+TestProtocol.swift
//  Petstagram
//
//  Created by Scott Leonard on 2/25/20.
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
