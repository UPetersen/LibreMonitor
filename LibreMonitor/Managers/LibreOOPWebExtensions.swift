//
//  SwiftOOPWebExtensions.swift
//  SwitftOOPWeb
//
//  Created by Bjørn Inge Berg on 08.04.2018.
//  Copyright © 2018 Bjørn Inge Berg. All rights reserved.
//
import Foundation

extension NSMutableURLRequest {
    
    /// Populate the HTTPBody of `application/x-www-form-urlencoded` request
    ///
    /// :param: contentMap A dictionary of keys and values to be added to the request
    
    func setBodyContent(contentMap: [String : String]) {
        let parameters = contentMap.map { (key, value) -> String in
            return "\(key)=\(value.stringByAddingPercentEscapesForQueryValue()!)"
        }
        
        httpBody =  parameters.joined(separator: "&").data(using: .utf8)
    }
}

extension String {
    
    /// Percent escape value to be added to a URL query value as specified in RFC 3986
    ///
    /// This percent-escapes all characters except the alphanumeric character set and "-", ".", "_", and "~".
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: Return precent escaped string.
    
    func stringByAddingPercentEscapesForQueryValue() -> String? {
        let characterSet = NSMutableCharacterSet.alphanumeric()
        characterSet.addCharacters(in: "-._~")
        return self.addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)
    }
}
