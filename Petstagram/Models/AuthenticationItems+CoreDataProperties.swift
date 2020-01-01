//
//  AuthenticationItems+CoreDataProperties.swift
//  Petstagram
//
//  Created by Scott Leonard on 12/25/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//
//

import Foundation
import CoreData


extension AuthenticationItems {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuthenticationItems> {
        return NSFetchRequest<AuthenticationItems>(entityName: "AuthenticationItems")
    }

    @NSManaged public var coreDataCredential: NSObject?
    @NSManaged public var coreDataEmail: String?
    @NSManaged public var coreDataPassword: String?
    @NSManaged public var coreDataUserName: String?

}
