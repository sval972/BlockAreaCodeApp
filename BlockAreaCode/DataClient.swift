//
//  DataClient.swift
//  BlockAreaCode
//
//  Created by Alexey Altoukhov on 10/28/18.
//  Copyright © 2018 Alexey Altoukhov. All rights reserved.
//

import Foundation

class DataClient
{
    private let sharedContainer = "group.com.sval.BlockAreaCode.container"
    private let folder = "test5"
    
    private let areaBlocksFileName = "areaBlocks.json"
    private let contactsFileName = "contacts.json"
    
    private let jsonCoder = JsonCoder()
    
    func addAreaBlock(areaCode: Int) {
        
        var allAreaBlocks = getAllAreaBlocks()
        
        allAreaBlocks.append(BlockedArea(areaCode: areaCode))
        
        saveToFile(fileName: areaBlocksFileName, object: allAreaBlocks)
    }
    
    func removeAreaBlock(areaCode: Int) {
        
        var allAreaBlocks = getAllAreaBlocks()
        
        if let index = allAreaBlocks.index(where: {$0.areaCode() == areaCode}) {
            
            allAreaBlocks.remove(at: index)
            saveToFile(fileName: areaBlocksFileName, object: allAreaBlocks)
        }
    }
    
    func getAllAreaBlocks()->[BlockedArea] {
        return readAllAreaBlocks() ?? [BlockedArea]()
    }
    
    private func readAllAreaBlocks()->[BlockedArea]? {
        return readFromFile(fileName: areaBlocksFileName)
    }
    
    func saveAllAreaBlocks(allAreaBlocks: [BlockedArea]) {
        saveToFile(fileName: areaBlocksFileName, object: allAreaBlocks)
    }
    
    func updateContacts(contacts: [Contact]) {
        saveToFile(fileName: contactsFileName, object: contacts)
    }
    
    func getContacts()->[Contact] {
        return readContacts() ?? [Contact]()
    }
    
    private func readContacts()->[Contact]? {
        return readFromFile(fileName: contactsFileName)
    }
    
    func updatesAvailable() -> Bool {
        
        let allAreaBlocks = getAllAreaBlocks()
        let contacts = getContacts()
        
        for areaBlock in allAreaBlocks {
            if !areaBlock.isComplete() || areaBlock.updatesAvailable(contacts: contacts) {
                return true
            }
        }
        
        return false
    }
    
    func log(message: String) {
        
        let fileManager = FileManager.default
        if let container = fileManager.containerURL(forSecurityApplicationGroupIdentifier: sharedContainer) {
            
            let dir = container.appendingPathComponent(folder)
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: false, attributes: nil)
            
            let fileURL = dir.appendingPathComponent("log.txt")
            
            do {
                try message.appendLineToURL(fileURL: fileURL as URL)
            }
            catch {
                print("Could not write to file \(error)")
            }
        }
    }
    
    func readLog() -> String {
        
        var result = ""
        
        let fileManager = FileManager.default
        if let container = fileManager.containerURL(forSecurityApplicationGroupIdentifier: sharedContainer) {
            
            let dir = container.appendingPathComponent(folder)
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: false, attributes: nil)
            
            let fileURL = dir.appendingPathComponent("log.txt")
            
            do {
                result = try String(contentsOf: fileURL as URL, encoding: String.Encoding.utf8)
            }
            catch {
                print("Could not read file \(error)")
            }
        }
        
        return result
    }
    
    private func saveToFile<T: Encodable>(fileName: String, object: T)->() {
        
        let content = jsonCoder.toJson(object)
        if content == nil {
            return
        }
        
        let fileManager = FileManager.default
        if let container = fileManager.containerURL(forSecurityApplicationGroupIdentifier: sharedContainer) {
            
            let dir = container.appendingPathComponent(folder)
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: false, attributes: nil)
            
            let fileURL = dir.appendingPathComponent(fileName)
            
            do {
                try content!.write(to: fileURL, options: Data.WritingOptions.atomic)
            }
            catch {
                print ("failed to write to " + fileName)
            }
        }
    }
    
    private func readFromFile<T:Decodable>(fileName: String)->T? {
        
        var object: T? = nil
        
        let fileManager = FileManager.default
        if let container = fileManager.containerURL(forSecurityApplicationGroupIdentifier: sharedContainer) {
            
            let dir = container.appendingPathComponent(folder)
            let fileURL = dir.appendingPathComponent(fileName)
            
            do {
                let content = try Data(contentsOf: fileURL)
                object = self.jsonCoder.fromJson(content)
            }
            catch {
                print ("failed to read from " + fileName)
            }
        }
        
        return object
    }

    private func saveToFile(fileName: String, content: Data)->() {

        let fileManager = FileManager.default
        if let container = fileManager.containerURL(forSecurityApplicationGroupIdentifier: sharedContainer) {
            
            let dir = container.appendingPathComponent(folder)
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: false, attributes: nil)
            
            let fileURL = dir.appendingPathComponent(fileName)
            
            do {
                try content.write(to: fileURL, options: Data.WritingOptions.atomic)
            }
            catch {
                print ("failed to write to " + fileName)
            }
        }
    }
    
    private func readFromFile(fileName: String)->Data? {
        
        var content: Data? = nil
        
        let fileManager = FileManager.default
        if let container = fileManager.containerURL(forSecurityApplicationGroupIdentifier: sharedContainer) {
            
            let dir = container.appendingPathComponent(folder)
            let fileURL = dir.appendingPathComponent(fileName)
            
            do {
                content = try Data(contentsOf: fileURL)
            }
            catch {
                print ("failed to read from " + fileName)
            }
        }
        
        return content
    }
}

extension String {
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }
    
    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
