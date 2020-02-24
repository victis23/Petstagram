//
//  DescriptionRetriever+TestProtocol.swift
//  Petstagram
//
//  Created by Scott Leonard on 2/23/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

protocol descriptionTestProtocol {
	func execute(query : DocumentReference)
	func execute(query : StorageReference)
}

/// Class created strictly for testing Description Retriever class.
class TesterForDescription : descriptionTestProtocol {
	
	private var query : String?
	private var wasExecuted : Bool?
	
	/// Sets value to `query` property and `wasExecuted` when method is called.
	func execute(query: DocumentReference) {
		self.query = query.path
		self.wasExecuted = true
	}
	
	func execute(query: StorageReference) {
		self.query = query.fullPath
		self.wasExecuted = true
	}
	
	/// Returns reference to document if not nil.
	func retrieveQuery()-> String? {
		return query
	}
	
	/// Verifies whether method was called.
	func callwasExecuted()->Bool{
		guard let wasExecuted = wasExecuted else {return false}
		return wasExecuted
	}
	
}
