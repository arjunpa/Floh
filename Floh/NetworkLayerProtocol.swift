//
//  NetworkLayerProtocol.swift
//  Floh
//
//  Created by Arjun P A on 28/05/17.
//  Copyright © 2017 Arjun P A. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift
import ObjectMapper

protocol NetworkLayerProtocol{
  
    func requestWithParameters(url:URLConvertible, method:HTTPMethod, params:[String:Any]?, headers:[String:String]?, parameterEncoding:ParameterEncoding?) -> DataRequest
}


public class NetworkLayer:NetworkLayerProtocol{
  
    init(){
        
    }
}

extension NetworkLayerProtocol{
    
    
    func requestWithParameters(url:URLConvertible, method:HTTPMethod, params:[String:Any]? = nil, headers:[String:String]? = nil, parameterEncoding:ParameterEncoding? = URLEncoding.default) -> DataRequest{
     
   
        return Alamofire
            .request(url, method: method, parameters: params, encoding: parameterEncoding!, headers: headers)
        
    }
    
    func dataWithRequest(url:URLConvertible, method:HTTPMethod,params:[String:Any]? = nil, headers:[String:String]? = nil, parameterEncoding:ParameterEncoding? = URLEncoding.default) -> SignalProducer<Optional<Data>, NSError>{
        
        return SignalProducer{
            (observer:Observer<Optional<Data>, NSError>, _) in
            self.requestWithParameters(url: url, method: method, params: params, headers: headers, parameterEncoding: parameterEncoding)
                .responseData(completionHandler: { (response) in
                    if let someError = response.error{
                        observer.send(error: someError as NSError)
                    }
                    else{
                        observer.send(value: response.data)
                    }
                })
            
        }
    }
    
    func mappableArrayWithRequest<T:Mappable>(url:URLConvertible, method:HTTPMethod,params:[String:Any]? = nil, headers:[String:String]? = nil, parameterEncoding:ParameterEncoding? = URLEncoding.default) -> SignalProducer<Optional<[T]>, NSError>{
        return SignalProducer{
            (observer:Observer<Optional<[T]>, NSError>, _) in
            self.requestWithParameters(url: url, method: method, params: params, headers: headers, parameterEncoding: parameterEncoding)
                .responseJSON(completionHandler: { (response) in
                    if let someError = response.error{
                        observer.send(error: someError as NSError)
                    }
                    else{
                        if let mappedResponse = Mapper<T>().mapArray(JSONObject: response.value){
                            observer.send(value: mappedResponse)
                            
                        }
                        else{
                            observer.send(error: NSError.init(domain: "Data is empty", code: -1, userInfo: nil))
                        }
                    }
                })
        }
    }
    
    
    
    func mappableWithRequest<T:Mappable>(url:URLConvertible, method:HTTPMethod,params:[String:Any]? = nil, headers:[String:String]? = nil, parameterEncoding:ParameterEncoding? = URLEncoding.default) -> SignalProducer<Optional<T>, NSError>{
        return SignalProducer{
            (observer:Observer<Optional<T>, NSError>, _) in
            self.requestWithParameters(url: url, method: method, params: params, headers: headers, parameterEncoding: parameterEncoding)
            .responseJSON(completionHandler: { (response) in
                if let someError = response.error{
                    observer.send(error: someError as NSError)
                }
                else{
                    if let mappedResponse = Mapper<T>().map(JSONObject: response.value){
                        observer.send(value: mappedResponse)
                       
                    }
                    else{
                        observer.send(error: NSError.init(domain: "Data is empty", code: -1, userInfo: nil))
                    }
                }
            })
        }
    }
    
    func jsonWithRequest(url:URLConvertible, method:HTTPMethod,params:[String:Any]? = nil, headers:[String:String]? = nil, parameterEncoding:ParameterEncoding? = URLEncoding.default) -> SignalProducer<Optional<Any>, NSError>{
        return SignalProducer{
            (observer:Observer<Optional<Any>, NSError>, _) in
            self.requestWithParameters(url: url, method: method, params: params, headers: headers, parameterEncoding: parameterEncoding)
            .responseJSON(completionHandler: { (response) in
                if let someError = response.error{
                    observer.send(error: someError as NSError)
                }
                else{
                    observer.send(value: response.value)
                }
            })
        }
    }
}
