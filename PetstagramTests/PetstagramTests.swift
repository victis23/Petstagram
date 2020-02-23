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
	var imageDownloader : ImageDownloader!
	var collectionViewBuilder : CollectionViewBuilder!
	var followerTracker : FollowerTracker!
	var account = "fakeUser"
	var username = "fakeUser"
	var petstagramAccount : PetstagramUsers!
	var appLoginController : AppLogin!

    override func setUp() {
		
        descriptionReceiver = DescriptionRetriever(userID: account, test: TesterForDescription())
		
		imageDownloader = ImageDownloader(account: account)
		
		collectionViewBuilder = CollectionViewBuilder(cellFractionalHeight: 1, cellFractionalWidth: 1, groupFractionalHeight: 1, groupFractionalWidth: 1, columns: 1, evenInsets: 1)
		
		petstagramAccount = PetstagramUsers(username, account)
		
		followerTracker = FollowerTracker(follower: petstagramAccount, isFollowing: false)
		
		appLoginController = AppLogin()
    }

    override func tearDown() {
		
		
    }
	
	/// Test verfies that the correct type has been created using the initializer Since `UICollectionViewLayout` effectivly equals `UICollectionViewCompositionalLayout` there is no need to downcast in this situation, simply test that we are actually getting back a layout.
	/// - Important: This class only had one method, so unit tests are complete.
	func testCollectionWasBuilt(){
		
		let layout = collectionViewBuilder.setLayout()
		
		let layoutType = type(of: layout)
		
		XCTAssertTrue(layoutType == UICollectionViewCompositionalLayout.self)
	}
	
	/// Verifes that a network call was made and that the query was not nil.
	func testGetDescriptionMethod(){
		
		let verifier = descriptionReceiver.returnTestProperty() as! TesterForDescription
		
		descriptionReceiver.getDescription(completion: { _ in })
		
		XCTAssertNotNil(verifier.retrieveQuery())
		XCTAssertTrue(verifier.callwasExecuted())
		
	}
	
	/// Verifies that a call was executed to retrieve username.
	func testGetUserName() {
		
		let verifier = descriptionReceiver.returnTestProperty() as! TesterForDescription
		
		descriptionReceiver.getUserName(completion: { _ in })
		
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
}
