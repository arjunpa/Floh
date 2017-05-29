//
//  Utils.swift
//  Floh
//
//  Created by Arjun P A on 28/05/17.
//  Copyright © 2017 Arjun P A. All rights reserved.
//

import Foundation

func urlEncodeUsingRFC1798(unendodedStr:String) -> String{
    let customAllowedSet =  CharacterSet.init(charactersIn: "$&+,:;=?@").inverted
    let escapedString = unendodedStr.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
    return escapedString!
    
}

extension String{
    func urlencodeWithRFC1798() -> String{
        return urlEncodeUsingRFC1798(unendodedStr: self)
    }
}
