//
//  Contact.swift
//  BlockAreaCode
//
//  Created by Alexey Altoukhov on 10/28/18.
//  Copyright © 2018 Alexey Altoukhov. All rights reserved.
//

import Foundation
import ContactsUI

class Contact : Equatable, Codable
{
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.PhoneNumber == rhs.PhoneNumber
    }
    
    var PhoneNumber:String
    
    init(phoneNumber: String) {
        self.PhoneNumber = phoneNumber.filter { "01234567890".contains($0) }
    }
    
    static func create(cnContact: CNContact) -> [Contact] {
        var contacts = [Contact]()
        
        for phoneNumber in cnContact.phoneNumbers {
            let contact = Contact(phoneNumber: phoneNumber.value.stringValue)
            contacts.append(contact)
        }
        
        return contacts
    }
}
