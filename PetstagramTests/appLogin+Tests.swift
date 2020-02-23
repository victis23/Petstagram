//
//  appLogin+Tests.swift
//  PetstagramTests
//
//  Created by Scott Leonard on 2/23/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import XCTest
@testable import Petstagram

class appLogin_Tests: XCTestCase {
	
	var appLoginController : AppLogin!

    override func setUpWithError() throws {
		
       appLoginController = AppLogin()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

}
