//
//  FLGlobalInstanceProtocol.swift
//  Floh
//
//  Created by Arjun P A on 28/05/17.
//  Copyright © 2017 Arjun P A. All rights reserved.
//

import Foundation

protocol FLGlobalInstanceProtocol:class{
    var networkLayer:NetworkLayerProtocol{get set}
    var serviceEndpoint:ServiceEndpoint.Type{get}
}

class FLGlobalInstance:FLGlobalInstanceProtocol{
    var networkLayer:NetworkLayerProtocol
    let serviceEndpoint:ServiceEndpoint.Type
    init(networkLayer:NetworkLayerProtocol? = nil, serviceEndpointPara:ServiceEndpoint.Type = ServiceEndpoint.self) {
        if let nLayer = networkLayer{
            self.networkLayer = nLayer
        }
        else{
            self.networkLayer = NetworkLayer.init()
        }
        self.serviceEndpoint = serviceEndpointPara
    }
}
