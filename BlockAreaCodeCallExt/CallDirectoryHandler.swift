//
//  CallDirectoryHandler.swift
//  BlockAreaCodeCallExt
//
//  Created by Alexey Altoukhov on 10/21/18.
//  Copyright © 2018 Alexey Altoukhov. All rights reserved.
//

import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {

    private let _dataClient: DataClient = DataClient()
    
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self

        var totalOpCount : Int = 0
        
        let allAreaBlocks = _dataClient.getAllAreaBlocks()
        let contacts = _dataClient.getContacts()

        log("CallDirectoryHandler.beginRequest: areaBlocks: \(allAreaBlocks.count), contacts: \(contacts.count)")
        
        if (!context.isIncremental) {
            log("CallDirectoryHandler.beginRequest: received non-incremental request!")
            
            for areaCode in allAreaBlocks {
                areaCode.reset()
            }
            
            _dataClient.saveAllAreaBlocks(allAreaBlocks: allAreaBlocks)
        }
        
        for areaCode in allAreaBlocks {
 
            let opsLeft: Int = Config.maxUpdatesCount - totalOpCount
            let skipSet: Set<UInt64> = areaCode.skipSet(contacts: contacts)
            let areaOpCount = areaCode.isRemoving()
                ? removeAreaCode(context: context, areaCode: areaCode, opLimit: opsLeft)
                : processAreaCode(context: context, areaCode: areaCode, skipSet: skipSet, opLimit: opsLeft)

            totalOpCount += areaOpCount
            
            log("CallDirectoryHandler.beginRequest: processed for \(areaCode.areaCode()): \(areaOpCount), skipSet: \(skipSet.count)")
            
            if (totalOpCount >= Config.maxUpdatesCount) {
                break
            }
        }
        
        _dataClient.saveAllAreaBlocks(allAreaBlocks: allAreaBlocks)
        log("CallDirectoryHandler.beginRequest: saved")
        
        context.completeRequest()
    }
    
    private func processAreaCode(context: CXCallDirectoryExtensionContext, areaCode: BlockedArea, skipSet: Set<UInt64>, opLimit: Int) -> Int {
        
        var opCount : Int = 0
        var number: UInt64 = areaCode.firstNumber() + UInt64(areaCode.processedCount())
        
        log("CallDirectoryHandler.processAreaCode: from \(number)")
        
        while (number <= areaCode.lastNumber() && opCount < opLimit) {
            
            if (skipSet.contains(number)) {
                areaCode.addExcludedNumber(number: number)
            }
            else {
                context.addBlockingEntry(withNextSequentialPhoneNumber: CXCallDirectoryPhoneNumber(number))
                opCount += 1
            }
            
            areaCode.increaseProcessedCount(by: 1)
            number += 1
        }
        
        log("CallDirectoryHandler.processAreaCode: to \(number - 1)")
        
        // Release contacts that were previously blocked
        for number in skipSet.subtracting(areaCode.getExcludedNumbers()) {
            
            if (opCount >= opLimit) {
                break
            }
            
            context.removeBlockingEntry(withPhoneNumber: CXCallDirectoryPhoneNumber(number))
            areaCode.addExcludedNumber(number: number)
            opCount += 1
        }
        
        // Block previously excluded number
        for number in areaCode.getExcludedNumbers().subtracting(skipSet).sorted() {
            
            if (opCount >= opLimit) {
                break
            }
            
            context.addBlockingEntry(withNextSequentialPhoneNumber: CXCallDirectoryPhoneNumber(number))
            areaCode.removeExcludedNumber(number: number)
            opCount += 1
        }
        
        return opCount
    }
    
    private func removeAreaCode(context: CXCallDirectoryExtensionContext, areaCode: BlockedArea, opLimit: Int) -> Int {
        
        var opCount : Int = 0
        var number: UInt64 = areaCode.firstNumber() + UInt64(areaCode.processedCount()) - 1
        
        log("CallDirectoryHandler.removeAreaCode: from \(number)")
        
        while (number >= areaCode.firstNumber() && opCount < opLimit) {
            
            if (areaCode.getExcludedNumbers().contains(number)) {
                areaCode.removeExcludedNumber(number: number)
            }
            else {
                context.removeBlockingEntry(withPhoneNumber: CXCallDirectoryPhoneNumber(number))
                opCount += 1
            }
            
            areaCode.decreaseProcessedCount(by: 1)
            number -= 1
        }
        
        log("CallDirectoryHandler.removeAreaCode: to \(number + 1)")

        return opCount
    }
    
    private func log(_ message: String) {
        _dataClient.log(message: message)
    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        // An error occurred while adding blocking or identification entries, check the NSError for details.
        // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
        //
        // This may be used to store the error details in a location accessible by the extension's containing app, so that the
        // app may be notified about errors which occured while loading data even if the request to load data was initiated by
        // the user in Settings instead of via the app itself.
        
        print("Error: \(error)")
    }
}
