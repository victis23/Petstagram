//
//  ImageDownloader.swift
//  Petstagram
//
//  Created by Scott Leonard on 2/15/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import Foundation
import FirebaseStorage


class ImageDownloader {
	
	var test : ImageDownloaderTestProtocol!
	
	private var storage = Storage.storage()
	private var account : String
	
	init(account : String) {
		self.account = account
		self.test = testClass
	}
	
	/// Downloads **Metadata** for each item contained within Google Firebase Storage.
	/// - Parameter downloadedImages: Captures returned metadata array.
	func downloadImages(downloadedImages : @escaping (_ metaData : StorageMetadata)->Void) {
		
		let user = account
		test.hasExecuted(hasExecuted: true)
		
		// Variable holds path to user's storage bucket.
		let filePath = storage.reference().child(user)
		
		filePath.listAll { (list, error) in
			
			if let error = error {
				print(error.localizedDescription)
				return
			}
			
			// For each item in the bucket method downloads its metadata and appends it to the metaDataKeys array.
			list.items.forEach { item in
				Storage.storage().reference(forURL: "\(item)").getMetadata { (metaData, Error) in
					if let error = error {
						print(error.localizedDescription)
						return
					}
					if let metaData = metaData {
						
						// Capture the returned metaData key.
						downloadedImages(metaData)
					}
				}
			}
		}
	}
	
	/// Captures actual image.
	func downloadImages(for file : String?, imageItem : @escaping (UIImage)->Void) {
		
		guard let file = file else {fatalError()}
		
		test.hasExecuted(hasExecuted: true)
		
		let bucket = storage.reference().child(account).child(file)
		
		bucket.getData(maxSize: 99_999_999) { (data, error) in
			
			if let error = error {
				print(error.localizedDescription)
			}
			
			guard let data = data,
			let image = UIImage(data: data)
				else {return}
			imageItem(image)
		}
	}
}
