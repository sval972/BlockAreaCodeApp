//
//  Utils.swift
//  BlockAreaCode
//
//  Created by Alexey Altoukhov on 10/28/18.
//  Copyright © 2018 Alexey Altoukhov. All rights reserved.
//

import Foundation
import ContactsUI
import CallKit

class Utils {
    
    static func loadContacts() -> [Contact] {
        var contacts = [Contact]()
        
        let contactStore = CNContactStore()
        contactStore.requestAccess(for: .contacts) { (granted, err) in
            if let err = err {
                print("Failed to request access:", err)
                return
            }
            
            if !granted {
                print("Access denied")
            }
        }
        
        let keys = [
            CNContactPhoneNumbersKey
        ]
        
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        do {
            try contactStore.enumerateContacts(with: request) { (contact, stop) in
                
                for c in Contact.create(cnContact: contact) {
                    contacts.append(c)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return contacts
    }
    
    static func reloadCallExtension() {
        
        reloadCallExtension { (success) in }
    }
    
    static func reloadCallExtension(callback: @escaping (_ success: Bool)->()) {
        
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "com.sval.BlockAreaCode.test5.BlockAreaCodeCallExt") { errorOrNil in
            if let error = errorOrNil as? CXErrorCodeCallDirectoryManagerError {
                print("reload failed")
                
                switch error.code {
                case .unknown:
                    print("error is unknown")
                case .noExtensionFound:
                    print("error is noExtensionFound")
                case .loadingInterrupted:
                    print("error is loadingInterrupted")
                case .entriesOutOfOrder:
                    print("error is entriesOutOfOrder")
                case .duplicateEntries:
                    print("error is duplicateEntries")
                case .maximumEntriesExceeded:
                    print("maximumEntriesExceeded")
                case .extensionDisabled:
                    print("extensionDisabled")
                case .currentlyLoading:
                    print("currentlyLoading")
                case .unexpectedIncrementalRemoval:
                    print("unexpectedIncrementalRemoval")
                }
                
                callback(false)
            } else {
                print("reload succeeded")
                
                callback(true)
            }
        }
    }
}
