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
    
    let tweets = MutableProperty<[StatusViewModel]>([StatusViewModel]())
    fileprivate var nextPageURL:String?
    let isSearching = MutableProperty<Bool>(false)
    let isLastPage = MutableProperty<Bool>(false)
    fileprivate var _disposable:Disposable?
    func reset(){
        isSearching.value = false
        isLastPage.value = false
        _disposable?.dispose()
        nextPageURL = nil
        tweets.value.removeAll()
    }
    
    
    
    func getTweets(){
        if isSearching.value || isLastPage.value{
            return
        }
        isSearching.value = true
        _disposable = authenticateWith()
            .observe(on: QueueScheduler.main)
            .flatMapError { (error) -> SignalProducer<Optional<BearerToken>, NSError> in
                print(error)
                self.isSearching.value = false
                return SignalProducer.empty
            }
            .flatMap(FlattenStrategy.latest) { (token) -> SignalProducer<Optional<TweetViewModel>, NSError> in
                
//                if let _ = token?.access_token{
//                    UserDefaults.standard.set(Mapper<BearerToken>().toJSON(token!), forKey: "bearToken")
//                    UserDefaults.standard.synchronize()
//                }
                return self.getTweetsWith(token: token!)
            }
            .flatMapError { (error) -> SignalProducer<Optional<TweetViewModel>, NSError> in
                print(error)
                self.isSearching.value = false
                return SignalProducer.empty
            }
            .startWithResult { (result) in
                print(result.value!)
                self.isSearching.value = false
                if let nextURL:String = result.value!!.nextPageURL{
                    self.nextPageURL = nextURL
                }
                else{
                    self.isLastPage.value = true
                }
                self.tweets.value.append(contentsOf: result.value!!.statuses)
        }
    }
    
    fileprivate func authenticateWith() -> SignalProducer<Optional<BearerToken>, NSError>{
        
        //cache authentication token if required. But then you also have to manage the situation where it might be expired.
        
//        if let tokenObj = UserDefaults.standard.value(forKey: "bearToken"){
//            return SignalProducer{
//                (observer:Observer<Optional<BearerToken>, NSError>, _) in
//                if let mappedProperly = Mapper<BearerToken>().map(JSONObject: tokenObj){
//                    observer.send(value: mappedProperly)
//                }
//                else{
//                    observer.send(error: NSError.init(domain: "Cache not found", code: -1, userInfo: nil))
//                }
//            }
//        }
        
        return self._networkLayer.mappableWithRequest(url: self._endPoint.bearerTokenURL, method: HTTPMethod.post, params: [
            "grant_type":"client_credentials"], headers: ["Content-Type":"application/x-www-form-urlencoded;charset=UTF-8", "Authorization": "Basic" + " " + Credentials.combinedValue], parameterEncoding: URLEncoding.default)
        
    }
    
    
    
    fileprivate func getTweetsWith(token:BearerToken) -> SignalProducer<Optional<TweetViewModel>, NSError>{

        let endpoint = self._endPoint.tweetSearchURL
        var params:[String:Any] = [:]
        
        if nextPageURL == nil{
            params = ["q":mention, "count": 8]
        }
        else{
            if let items = URLComponents(string: self.nextPageURL!)?.queryItems{
                for item in items where item.name != "q"{
                   
                    params[item.name] = item.value!
                }
                
            }
            params["q"] = mention
        }
        return self._networkLayer.mappableWithRequest(url: endpoint, method: HTTPMethod.get, params: params, headers: ["Authorization": "Bearer" + " " + token.access_token], parameterEncoding: URLEncoding.default)
    }
    
}
