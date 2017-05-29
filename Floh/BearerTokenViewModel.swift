//
//  BearerTokenViewModel.swift
//  Floh
//
//  Created by Arjun P A on 28/05/17.
//  Copyright © 2017 Arjun P A. All rights reserved.
//

import Foundation
import ReactiveSwift
import ObjectMapper
import Alamofire

class BearerTokenViewModel:BaseViewModel{
    
    func authenticate(){
      
        authenticateWith()
        .observe(on: QueueScheduler.main)
        .flatMapError { (error) -> SignalProducer<Optional<BearerToken>, NSError> in
            print(error)
            return SignalProducer.empty
        }
        .startWithResult { (result) in
            print(result.value ?? "")
            print(result.error ?? "")
        }
    }
    
    fileprivate func authenticateWith() -> SignalProducer<Optional<BearerToken>, NSError>{
        
        return self._networkLayer.mappableWithRequest(url: self._endPoint.bearerTokenURL, method: HTTPMethod.post, params: [
            "grant_type":"client_credentials"], headers: ["Content-Type":"application/x-www-form-urlencoded;charset=UTF-8", "Authorization": "Basic" + " " + Credentials.combinedValue], parameterEncoding: URLEncoding.default)
        
        
    }

}
