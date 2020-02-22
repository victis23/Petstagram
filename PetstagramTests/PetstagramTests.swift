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

    override func setUp() {
		
        descriptionReceiver = DescriptionRetriever(userID: account)
		
		imageDownloader = ImageDownloader(account: account)
		
		collectionViewBuilder = CollectionViewBuilder(cellFractionalHeight: 1, cellFractionalWidth: 1, groupFractionalHeight: 1, groupFractionalWidth: 1, columns: 1, evenInsets: 1)
		
		petstagramAccount = PetstagramUsers(username, account)
		
		followerTracker = FollowerTracker(follower: petstagramAccount, isFollowing: false)
    }

    override func tearDown() {
		
    }
	
	func testCollectionWasBuilt(){
		
		let layout = collectionViewBuilder.setLayout()
		let layoutType = type(of: layout)
		
		let istypeCorrect = layoutType == UICollectionViewCompositionalLayout.self ? true : false
		XCTAssertTrue(istypeCorrect, "Type is correct.")
	}
}
