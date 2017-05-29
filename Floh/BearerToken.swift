//
//  BearerToken.swift
//  Floh
//
//  Created by Arjun P A on 28/05/17.
//  Copyright © 2017 Arjun P A. All rights reserved.
//

import Foundation
import ObjectMapper

struct BearerToken:Mappable{
    var access_token:String!
    var token_type:String!
    mutating func mapping(map: Map){
        access_token <- map["access_token"]
        token_type <- map["token_type"]
    }
    init?(map: Map){
    
    }
}
