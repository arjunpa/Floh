//
//  TweetViewModel.swift
//  Floh
//
//  Created by Arjun P A on 28/05/17.
//  Copyright © 2017 Arjun P A. All rights reserved.
//

import Foundation
import ObjectMapper
import ReactiveSwift
import Alamofire

class BaseViewModel{
    
    let mention:String = "@FlohNetwork"
        .urlencodeWithRFC1798()
    
    var _endPoint:EndpointProtocol.Type
    var _networkLayer:NetworkLayerProtocol
    required init(endpointPara:EndpointProtocol.Type = ServiceEndpoint.self, networkLayer:NetworkLayerProtocol? = nil) {
        
        
        _endPoint = endpointPara
        
        if let networkLatyerOrNil = networkLayer{
            _networkLayer = networkLatyerOrNil
        }
        else{
            _networkLayer = (UIApplication.shared.delegate as! AppDelegate).globalInstance.networkLayer
        }
    }
}


class TweetMentionViewModel:BaseViewModel{
    
    func getTweets(){
        
            authenticateWith()
            .observe(on: QueueScheduler.main)
            .flatMapError { (error) -> SignalProducer<Optional<BearerToken>, NSError> in
                print(error)
                return SignalProducer.empty
            }
            .flatMap(FlattenStrategy.latest) { (token) -> SignalProducer<Optional<TweetViewModel>, NSError> in
                return self.getTweetsWith(token: token!)
            }
            .flatMapError { (error) -> SignalProducer<Optional<TweetViewModel>, NSError> in
                print(error)
                return SignalProducer.empty
            }
            .startWithResult { (result) in
               print(result.value!)
        }
    }
    
    fileprivate func authenticateWith() -> SignalProducer<Optional<BearerToken>, NSError>{
        
        return self._networkLayer.mappableWithRequest(url: self._endPoint.bearerTokenURL, method: HTTPMethod.post, params: [
            "grant_type":"client_credentials"], headers: ["Content-Type":"application/x-www-form-urlencoded;charset=UTF-8", "Authorization": "Basic" + " " + Credentials.combinedValue], parameterEncoding: URLEncoding.default)
        
    }
    
    
    
    fileprivate func getTweetsWith(token:BearerToken) -> SignalProducer<Optional<TweetViewModel>, NSError>{
        return self._networkLayer.mappableWithRequest(url: self._endPoint.tweetSearchURL, method: HTTPMethod.get, params: ["q": mention], headers: ["Authorization": token.access_token], parameterEncoding: JSONEncoding.default)
    }
    
}
