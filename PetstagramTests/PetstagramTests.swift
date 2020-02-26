//
//  PetstagramTests.swift
//  PetstagramTests
//
//  Created by Scott Leonard on 1/24/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import XCTest
@testable import Petstagram

class PetstagramTests: XCTestCase {
	
	var descriptionReceiver : DescriptionRetriever!
	var defaultDescriptionReceiver : DescriptionRetriever!
	var imageDownloader : ImageDownloader!
	var collectionViewBuilder : CollectionViewBuilder!
	var followerTracker : FollowerTracker!
	var account = "fakeUser"
	var username = "fakeUser"
	var petstagramAccount : PetstagramUsers!
	

    override func setUp() {
		
		descriptionReceiver = DescriptionRetriever(userID: account, test: TesterForDescription(), db: MockDatabaseClass(db: StorageMock()))
		
		defaultDescriptionReceiver = DescriptionRetriever(userID: account, test: TesterForDescription())
		
		imageDownloader = ImageDownloader(account: account, testClass: ImageDownloadTester())
		
		collectionViewBuilder = CollectionViewBuilder(cellFractionalHeight: 1, cellFractionalWidth: 1, groupFractionalHeight: 1, groupFractionalWidth: 1, columns: 1, evenInsets: 1)
		
		petstagramAccount = PetstagramUsers(username, account)
		
		followerTracker = FollowerTracker(follower: petstagramAccount, isFollowing: false)
		
    }

    override func tearDown() {
		
		
    }
	
	// MARK: Test Extension on Optional<Wrapped> where Wrapped == String
	
	func testValidEmail(){
		let email :String? = "test@test.com"
		XCTAssertTrue(email.isValidEmail)
	}
	
	func testEmailIsNotValid(){
		let email : String? = "test.com"
		XCTAssertFalse(email.isValidEmail)
	}
	
	func testEmailIsNotValid2(){
		let email : String? = "test@test,com"
		XCTAssertFalse(email.isValidEmail)
	}
	
	//MARK: - Helper Class Tests
	
	
	
	//MARK: CollectionViewBuilder Tests
	
	/// Test verfies that the correct type has been created using the initializer Since `UICollectionViewLayout` effectivly equals `UICollectionViewCompositionalLayout` there is no need to downcast in this situation, simply test that we are actually getting back a layout.
	/// - Important: This class only had one method, so unit tests are complete.
	func testCollectionWasBuilt(){
		
		let layout = collectionViewBuilder.setLayout()
		
		let layoutType = type(of: layout)
		
		XCTAssertTrue(layoutType == UICollectionViewCompositionalLayout.self)
	}
	
	
	//MARK: DescriptionRetriever Tests
	
	/// Verifes that a network call was made and that the query was not nil using the `defaultDescriptionReceiver`.
	func testGetDescriptionMethod(){
		
		let verifier = defaultDescriptionReceiver.returnTestProperty() as! TesterForDescription
		
		defaultDescriptionReceiver.getDescription(completion: { _ in })
		
		XCTAssertNotNil(verifier.retrieveQuery())
		XCTAssertTrue(verifier.callwasExecuted())
		
	}
	
	/// Verifies that a call was executed to retrieve username using the `defaultDescriptionReceiver`.
	func testGetUserName() {
		
		let verifier = defaultDescriptionReceiver.returnTestProperty() as! TesterForDescription
		
		defaultDescriptionReceiver.getUserName(completion: { _ in })
		
		XCTAssertNotNil(verifier.retrieveQuery())
		XCTAssertTrue(verifier.callwasExecuted())
	}
	
	/// Verifies that a call was executed to retrieve profile image.
	func testGetProfileImage() {
		
		let verifier = descriptionReceiver.returnTestProperty() as! TesterForDescription
		
		descriptionReceiver.getProfilePhoto(completion: { _ in })
		
		XCTAssertNotNil(verifier.retrieveQuery())
		XCTAssertTrue(verifier.callwasExecuted())
	}
	
	
	/// Using a mock to verify if the correct path is being sent to server.
	func testDescriptionPathIsReceived(){
		
		let verifier = descriptionReceiver
		
		verifier?.getDescription(completion: {string in
			XCTAssertEqual("Test Description", string)
		})
	}
	
	/// Using a mock to verify if the username method path is being sent to server.
	func testUserNamePathIsReceived(){
		
		let verifier = descriptionReceiver
		
		verifier?.getUserName(completion: {string in
			XCTAssertEqual("Test Username", string)
		})
	}
	
	// MARK: Image Downloader Tests
	
	/// Checks if method used to retrieve image metadata was executed.
	func testImageMetaDataDownload(){
		
		imageDownloader.downloadImages(downloadedImages: { _ in })
		
		let wasCalled = imageDownloader.returnTestProperty().wasCalled()
		
		XCTAssertTrue(wasCalled)
	}
	
	/// Checks if method used to retrieve images was executed.
	func testImagesDownload(){
		
		imageDownloader.downloadImages(for: account, imageItem: { _ in })
		
		// performed call in one line versus two as above.
		XCTAssertTrue(imageDownloader.returnTestProperty().wasCalled())
	}
	
}
