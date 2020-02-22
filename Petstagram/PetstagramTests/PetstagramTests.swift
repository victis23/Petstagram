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
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
		
    }
}
