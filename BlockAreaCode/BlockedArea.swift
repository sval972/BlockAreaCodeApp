//
//  BlockedArea.swift
//  BlockAreaCode
//
//  Created by Alexey Altoukhov on 10/28/18.
//  Copyright © 2018 Alexey Altoukhov. All rights reserved.
//

import Foundation

class BlockedArea : Codable {
    private var _countryCode: Int
    private var _areaCode: Int
    
    private var _numbersProcessed: Int
    private var _numbersExcluded: Set<UInt64>
    private var _isRemoving: Bool
    
    init(areaCode: Int) {
        self._countryCode = 1
        self._areaCode = areaCode
        _numbersProcessed = 0
        _numbersExcluded = Set<UInt64>()
        _isRemoving = false
    }
    
    func countryCode() -> Int {
        return _countryCode
    }
    
    func areaCode() -> Int {
        return _areaCode
    }
    
    func firstNumber() -> UInt64 {
        return UInt64(10000000000) + UInt64(self._areaCode) * UInt64(10000000)
    }
    
    func lastNumber() -> UInt64 {
        return firstNumber() + UInt64(9999999)
    }
    
    func totalNumbers() -> Int {
        return Int(lastNumber() - firstNumber()) + 1
    }
    
    func processedCount() -> Int {
        return _numbersProcessed
    }
    
    func increaseProcessedCount(by: Int) {
        _numbersProcessed += by
    }
    
    func decreaseProcessedCount(by: Int) {
        _numbersProcessed -= by
    }
    
    func isComplete() -> Bool {
        return _isRemoving ? (_numbersProcessed == 0) :  (_numbersProcessed == totalNumbers())
    }
    
    func updatesAvailable(contacts: [Contact]) -> Bool {
        
        let skipSet: Set<UInt64> = self.skipSet(contacts: contacts)
        return skipSet.subtracting(self.getExcludedNumbers()).count > 0 || self.getExcludedNumbers().subtracting(skipSet).count > 0
    }
    
    func isRemoving() -> Bool {
        return _isRemoving
    }
    
    func getExcludedNumbers() -> Set<UInt64> {
        return _numbersExcluded;
    }
    
    func addExcludedNumber(number: UInt64) {
        _numbersExcluded.insert(number)
    }
    
    func removeExcludedNumber(number: UInt64) {
        _numbersExcluded.remove(number)
    }
    
    func setForRemoval() {
        _isRemoving = true
    }
    
    func reset() {
        _numbersProcessed = 0
        _numbersExcluded.removeAll()
        _isRemoving = false
    }
    
    func skipSet(contacts: [Contact]) -> Set<UInt64> {
        
        var skipSet = Set<UInt64>()
        
        let fullNumLength = String(self.firstNumber()).count
        let countryCodeLength = String(self._countryCode).count
        
        for contact in contacts {
            
            if (contact.PhoneNumber.count == fullNumLength && contact.PhoneNumber.starts(with: String(self._countryCode) + String(self._areaCode))) {
                skipSet.insert(UInt64(contact.PhoneNumber)!)
            }
            else if (contact.PhoneNumber.count == fullNumLength - countryCodeLength && contact.PhoneNumber.starts(with: String(self._areaCode))) {
                skipSet.insert(UInt64(String(Config.defaultCountryCode) + contact.PhoneNumber)!)
            }
        }
        
        return skipSet
    }
}
