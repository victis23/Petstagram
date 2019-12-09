//
//  AuthenticationItems+CoreDataProperties.swift
//  
//
//  Created by Scott Leonard on 12/8/19.
//
//

import Foundation
import CoreData


extension AuthenticationItems {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuthenticationItems> {
        return NSFetchRequest<AuthenticationItems>(entityName: "AuthenticationItems")
    }

    @NSManaged public var username: String?
    @NSManaged public var password: String?
    @NSManaged public var email: String?

}
