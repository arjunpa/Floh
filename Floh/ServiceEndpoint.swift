//
//  ServiceEndpoint.swift
//  Floh
//
//  Created by Arjun P A on 28/05/17.
//  Copyright © 2017 Arjun P A. All rights reserved.
//

import Foundation

struct Credentials{
    static let consumerSecret = "ffX1rhJMjejNZn9UTf64TCm5JZg06hVHFJ1TfaCdfhksJBppwK"
    static let consumerKey = "qwAO5MDyHut5uQkD31r6wCBpX"
    
    static let combinedValue = { () -> String in 
        let encodedConsumerSecret = urlEncodeUsingRFC1798(unendodedStr: Credentials.consumerSecret)
        let encodedConsumerKey = urlEncodeUsingRFC1798(unendodedStr: Credentials.consumerKey)
        let combined = encodedConsumerKey + ":" + encodedConsumerSecret
        let base64Version = combined.data(using: .utf8)!.base64EncodedString()
        return base64Version
    }()
}

protocol EndpointProtocol{
    static var bearerTokenURL:String{get}
    static var tweetSearchURL:String{get}
}

struct ServiceEndpoint:EndpointProtocol{
    
    static let bearerTokenURL = "https://api.twitter.com/oauth2/token"
    static let tweetSearchURL = "https://api.twitter.com/1.1/search/tweets.json"
    

}
