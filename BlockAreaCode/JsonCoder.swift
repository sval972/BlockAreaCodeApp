//
//  JsonCoder.swift
//  BlockAreaCode
//
//  Created by Alexey Altoukhov on 10/28/18.
//  Copyright © 2018 Alexey Altoukhov. All rights reserved.
//

import Foundation

enum DateError: String, Error {
    case invalidDate
}

class JsonCoder {
    
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    func toJson<T: Encodable>(_ obj: T?) -> Data? {
        
        do {
            let jsonData = try jsonEncoder.encode(obj)
            return jsonData
        }
        catch {
            print("Error serializing JSON: \(error)")
        }
        
        return nil
    }
    
    func fromJson<T: Decodable>(_ data:Data?) -> T? {
        
        let jsonDecoder = JSONDecoder()
        
        jsonDecoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            throw DateError.invalidDate
        })
        
        if let data = data {
            do {
                let obj = try jsonDecoder.decode(T.self, from: data)
                return obj
            }
            catch {
                print("Error deserializing JSON: \(error)")
            }
        }
        return nil
    }
}
