//
//  TweetViewModel.swift
//  Floh
//
//  Created by Arjun P A on 29/05/17.
//  Copyright © 2017 Arjun P A. All rights reserved.
//

import Foundation
import ObjectMapper

class TweetViewModel:BaseViewModel, Mappable{
    
    var statuses:[StatusViewModel] = []
    var nextPageURL:String?
    
     func mapping(map: Map){
        
      statuses <- map["statuses"]
      nextPageURL <- map["search_metadata.next_results"]
    }
    required init?(map: Map){
        super.init()
    }
    
    required init(endpointPara: EndpointProtocol.Type, networkLayer: NetworkLayerProtocol?) {
        super.init(endpointPara: endpointPara, networkLayer: networkLayer)
    }
}

class StatusViewModel:BaseViewModel, Mappable{
    
    var tweetText:String!
    var avatarURL:String!
    var userName:String!
    
    func mapping(map: Map){
        
        tweetText <- map["text"]
        avatarURL <- map["user.profile_image_url_https"]
        userName <- map["user.name"]
        
    }
    required init?(map: Map){
        super.init()
    }
    
    required init(endpointPara: EndpointProtocol.Type, networkLayer: NetworkLayerProtocol?) {
        super.init(endpointPara: endpointPara, networkLayer: networkLayer)
    }
}
