//
//  UsersDB+CoreDataProperties.swift
//  
//
//  Created by Dayan Yonnatan on 27/11/2017.
//
//

import Foundation
import CoreData


extension UsersDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UsersDB> {
        return NSFetchRequest<UsersDB>(entityName: "UsersDB")
    }

    @NSManaged public var about: String?
    @NSManaged public var city: String?
    @NSManaged public var country: String?
    @NSManaged public var dateofbirth: String?
    @NSManaged public var email: String?
    @NSManaged public var looking_for: String?
    @NSManaged public var name: String?
    @NSManaged public var profilePicture: NSData?
    @NSManaged public var profilePicUrl: String?
    @NSManaged public var relationship_status: String?
    @NSManaged public var userID: String?
    @NSManaged public var gender: String?

}
